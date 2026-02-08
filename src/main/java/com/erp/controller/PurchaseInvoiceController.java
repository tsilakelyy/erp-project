package com.erp.controller;

import com.erp.domain.Invoice;
import com.erp.domain.Supplier;
import com.erp.repository.InvoiceRepository;
import com.erp.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/purchases/invoices")
public class PurchaseInvoiceController {

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        List<Invoice> invoices = invoiceRepository.findByTypeFactureIgnoreCase("ACHAT");
        model.addAttribute("invoices", invoices);

        Map<Long, String> supplierNames = new HashMap<>();
        for (Supplier s : supplierService.findAll()) {
            supplierNames.put(s.getId(), s.getNomEntreprise());
        }
        model.addAttribute("supplierNames", supplierNames);

        return "purchases/invoices-list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        Optional<Invoice> invoice = invoiceRepository.findById(id);
        if (invoice.isEmpty()) {
            return "redirect:/purchases/invoices?error=Facture+introuvable";
        }
        model.addAttribute("invoice", invoice.get());
        supplierService.findById(invoice.get().getTiersId())
            .ifPresent(s -> model.addAttribute("supplier", s));

        return "purchases/invoice-detail";
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        Optional<Invoice> invoiceOpt = invoiceRepository.findById(id);
        if (invoiceOpt.isEmpty()) {
            return "redirect:/purchases/invoices?error=Facture+introuvable";
        }
        Invoice invoice = invoiceOpt.get();
        if ("PAYEE".equalsIgnoreCase(invoice.getStatut())) {
            return "redirect:/purchases/invoices?error=Facture+deja+payee";
        }
        invoice.setStatut("ANNULEE");
        invoiceRepository.save(invoice);
        return "redirect:/purchases/invoices?success=1";
    }
}
