package com.erp.service;

import com.erp.domain.Customer;
import com.erp.domain.Invoice;
import com.erp.domain.InvoiceLine;
import com.erp.domain.Supplier;
import com.erp.repository.InvoiceRepository;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.awt.Color;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class InvoicePdfService {

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private SupplierService supplierService;

    @Autowired
    private CustomerService customerService;

    public byte[] generatePdf(Long invoiceId) {
        Invoice invoice = invoiceRepository.findByIdWithLines(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Facture introuvable"));

        String tiersLabel = resolveTiersLabel(invoice);

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4, 36, 36, 36, 36);

        try {
            PdfWriter.getInstance(doc, out);
            doc.open();

            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
            Font hFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
            Font normal = FontFactory.getFont(FontFactory.HELVETICA, 10);

            Paragraph title = new Paragraph("FACTURE " + safe(invoice.getNumero()), titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            doc.add(title);
            doc.add(Chunk.NEWLINE);

            PdfPTable meta = new PdfPTable(2);
            meta.setWidthPercentage(100);
            meta.setWidths(new float[]{1.2f, 2.8f});
            meta.addCell(metaCell("Type", hFont));
            meta.addCell(metaCell(safe(invoice.getTypeFacture()), normal));
            meta.addCell(metaCell("Statut", hFont));
            meta.addCell(metaCell(safe(invoice.getStatut()), normal));
            meta.addCell(metaCell("Date", hFont));
            meta.addCell(metaCell(formatDate(invoice), normal));
            meta.addCell(metaCell("Tiers", hFont));
            meta.addCell(metaCell(tiersLabel, normal));
            doc.add(meta);

            doc.add(Chunk.NEWLINE);

            // Lines
            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{1.2f, 3.0f, 0.8f, 1.2f, 1.3f});

            table.addCell(th("Code", hFont));
            table.addCell(th("Article", hFont));
            table.addCell(th("Qte", hFont));
            table.addCell(th("PU (Ar)", hFont));
            table.addCell(th("Montant (Ar)", hFont));

            if (invoice.getLines() != null && !invoice.getLines().isEmpty()) {
                for (InvoiceLine line : invoice.getLines()) {
                    String code = line.getArticle() != null ? safe(line.getArticle().getCode()) : "-";
                    String lib = line.getArticle() != null ? safe(line.getArticle().getLibelle()) : "-";
                    table.addCell(td(code, normal));
                    table.addCell(td(lib, normal));
                    table.addCell(td(String.valueOf(line.getQuantite() != null ? line.getQuantite() : 0), normal, Element.ALIGN_RIGHT));
                    table.addCell(td(money(line.getPrixUnitaire()), normal, Element.ALIGN_RIGHT));
                    table.addCell(td(money(line.getMontant()), normal, Element.ALIGN_RIGHT));
                }
            } else {
                PdfPCell empty = new PdfPCell(new Phrase("Aucune ligne", normal));
                empty.setColspan(5);
                empty.setPadding(8);
                table.addCell(empty);
            }

            doc.add(table);

            doc.add(Chunk.NEWLINE);

            PdfPTable totals = new PdfPTable(2);
            totals.setWidthPercentage(40);
            totals.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totals.setWidths(new float[]{1.4f, 1.0f});
            totals.addCell(metaCell("Montant HT (Ar)", hFont));
            totals.addCell(metaCell(money(invoice.getMontantHt()), normal, Element.ALIGN_RIGHT));
            totals.addCell(metaCell("TVA (Ar)", hFont));
            totals.addCell(metaCell(money(invoice.getMontantTva()), normal, Element.ALIGN_RIGHT));
            totals.addCell(metaCell("Total TTC (Ar)", hFont));
            totals.addCell(metaCell(money(invoice.getMontantTtc()), normal, Element.ALIGN_RIGHT));
            doc.add(totals);

            doc.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new IllegalStateException("Impossible de generer le PDF: " + e.getMessage(), e);
        } finally {
            if (doc.isOpen()) {
                doc.close();
            }
        }
    }

    private PdfPCell th(String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new Color(245, 245, 245));
        cell.setPadding(6);
        return cell;
    }

    private PdfPCell td(String text, Font font) {
        return td(text, font, Element.ALIGN_LEFT);
    }

    private PdfPCell td(String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setHorizontalAlignment(align);
        cell.setPadding(6);
        return cell;
    }

    private PdfPCell metaCell(String label, Font font) {
        return metaCell(label, font, Element.ALIGN_LEFT);
    }

    private PdfPCell metaCell(String label, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(label, font));
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setPadding(3);
        cell.setHorizontalAlignment(align);
        return cell;
    }

    private String resolveTiersLabel(Invoice invoice) {
        Long id = invoice.getTiersId();
        String type = invoice.getTypeTiers() != null ? invoice.getTypeTiers() : "";

        if (id == null) return "-";

        if ("FOURNISSEUR".equalsIgnoreCase(type)) {
            Optional<Supplier> s = supplierService.findById(id);
            return s.map(Supplier::getNomEntreprise).orElse("Fournisseur #" + id);
        }
        if ("CLIENT".equalsIgnoreCase(type)) {
            Optional<Customer> c = customerService.findById(id);
            return c.map(Customer::getNomEntreprise).orElse("Client #" + id);
        }
        return "Tiers #" + id;
    }

    private String formatDate(Invoice invoice) {
        if (invoice.getDateFacture() != null) {
            return invoice.getDateFacture().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        }
        if (invoice.getDateCreation() != null) {
            return invoice.getDateCreation().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        }
        return "-";
    }

    private String safe(String value) {
        return value != null ? value : "-";
    }

    private String money(BigDecimal value) {
        if (value == null) return "0.00";
        return value.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }
}
