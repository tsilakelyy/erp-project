package com.erp.controller;

import com.erp.domain.Invoice;
import com.erp.repository.InvoiceRepository;
import com.erp.service.InvoicePdfService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import javax.servlet.http.HttpSession;
import java.util.Optional;

@Controller
public class InvoiceExportController {

    @Autowired
    private InvoicePdfService invoicePdfService;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @GetMapping("/invoices/{id}/pdf")
    public ResponseEntity<byte[]> exportPdf(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return ResponseEntity.status(401).build();
        }

        Optional<Invoice> invoice = invoiceRepository.findById(id);
        if (invoice.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        byte[] pdf = invoicePdfService.generatePdf(id);
        String filename = "facture-" + (invoice.get().getNumero() != null ? invoice.get().getNumero() : id) + ".pdf";

        return ResponseEntity.ok()
            .contentType(MediaType.APPLICATION_PDF)
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename.replace('\"', '_') + "\"")
            .body(pdf);
    }
}

