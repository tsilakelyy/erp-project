package com.erp.controller;

import com.erp.domain.Supplier;
import com.erp.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/suppliers")
public class SupplierController {
    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<Supplier> suppliers = supplierService.findAll();
        model.addAttribute("suppliers", suppliers);
        return "suppliers/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Supplier> supplier = supplierService.findById(id);
        if (supplier.isPresent()) {
            model.addAttribute("supplier", supplier.get());
            return "suppliers/detail";
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("supplier", new Supplier());
        return "suppliers/form";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Supplier> supplier = supplierService.findById(id);
        if (supplier.isPresent()) {
            model.addAttribute("supplier", supplier.get());
            return "suppliers/form";
        }
        return "redirect:/suppliers";
    }

    @PostMapping
    public String create(@ModelAttribute Supplier supplier, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            supplierService.createSupplier(supplier, username);
            return "redirect:/suppliers?success=1";
        } catch (Exception e) {
            return "redirect:/suppliers/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id, @ModelAttribute Supplier supplier, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        supplier.setId(id);
        try {
            supplierService.updateSupplier(supplier, username);
            return "redirect:/suppliers";
        } catch (Exception e) {
            return "redirect:/suppliers/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/deactivate")
    public String deactivate(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        supplierService.deactivateSupplier(id, username);
        return "redirect:/suppliers";
    }

    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<List<Supplier>> getAllSuppliers() {
        return ResponseEntity.ok(supplierService.findAllActive());
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Supplier> getSupplier(@PathVariable Long id) {
        Optional<Supplier> supplier = supplierService.findById(id);
        return supplier.map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
