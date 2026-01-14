package com.erp.controller;

import com.erp.domain.Inventory;
import com.erp.service.InventoryService;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/inventories")
public class InventoryController {
    @Autowired
    private InventoryService inventoryService;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @GetMapping
    public String list(Model model, Authentication auth) {
        List<Inventory> inventories = inventoryService.getInventoriesByStatus("VALIDATED");
        model.addAttribute("inventories", inventories);
        model.addAttribute("username", auth.getName());
        return "inventories/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth) {
        Optional<Inventory> inventory = inventoryService.getInventory(id);
        if (inventory.isPresent()) {
            model.addAttribute("inventory", inventory.get());
            model.addAttribute("username", auth.getName());
            return "inventories/detail";
        }
        return "redirect:/inventories";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth) {
        model.addAttribute("inventory", new Inventory());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        model.addAttribute("username", auth.getName());
        return "inventories/form";
    }

    @PostMapping
    public String create(@ModelAttribute Inventory inventory, Authentication auth) {
        try {
            Inventory saved = inventoryService.createInventory(inventory, auth.getName());
            return "redirect:/inventories/" + saved.getId();
        } catch (Exception e) {
            return "redirect:/inventories/new?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/complete")
    public String complete(@PathVariable Long id, Authentication auth) {
        try {
            inventoryService.completeInventory(id, auth.getName());
            return "redirect:/inventories/" + id;
        } catch (Exception e) {
            return "redirect:/inventories/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/validate")
    public String validate(@PathVariable Long id, Authentication auth) {
        try {
            inventoryService.validateInventory(id, auth.getName());
            return "redirect:/inventories/" + id;
        } catch (Exception e) {
            return "redirect:/inventories/" + id + "?error=" + e.getMessage();
        }
    }

    // REST API
    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<List<Inventory>> getAllInventories() {
        return ResponseEntity.ok(inventoryService.getInventoriesByStatus("VALIDATED"));
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Inventory> getInventory(@PathVariable Long id) {
        Optional<Inventory> inventory = inventoryService.getInventory(id);
        return inventory.map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
