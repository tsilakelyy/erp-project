package com.erp.controller;

import com.erp.domain.Supplier;
import com.erp.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/suppliers")
public class SupplierController {
    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public String list(Model model, Authentication auth) {
        List<Supplier> suppliers = supplierService.findAll();
        model.addAttribute("suppliers", suppliers);
        model.addAttribute("username", auth.getName());
        return "suppliers/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth) {
        Optional<Supplier> supplier = supplierService.findById(id);
        if (supplier.isPresent()) {
            model.addAttribute("supplier", supplier.get());
            model.addAttribute("username", auth.getName());
            return "suppliers/detail";
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth) {
        model.addAttribute("supplier", new Supplier());
        model.addAttribute("username", auth.getName());
        return "suppliers/form";
    }

    @PostMapping
    public String create(@ModelAttribute Supplier supplier, Authentication auth) {
        try {
            supplierService.createSupplier(supplier, auth.getName());
            return "redirect:/suppliers";
        } catch (Exception e) {
            return "redirect:/suppliers/new?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id, @ModelAttribute Supplier supplier, Authentication auth) {
        supplier.setId(id);
        try {
            supplierService.updateSupplier(supplier, auth.getName());
            return "redirect:/suppliers";
        } catch (Exception e) {
            return "redirect:/suppliers/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/deactivate")
    public String deactivate(@PathVariable Long id, Authentication auth) {
        supplierService.deactivateSupplier(id, auth.getName());
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
