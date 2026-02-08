package com.erp.controller;

import com.erp.domain.Inventory;
import com.erp.service.InventoryService;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
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
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<Inventory> inventories = inventoryService.getAllInventories();
        model.addAttribute("inventories", inventories);
        return "inventories/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Inventory> inventory = inventoryService.getInventory(id);
        if (inventory.isPresent()) {
            model.addAttribute("inventory", inventory.get());
            return "inventories/detail";
        }
        return "redirect:/inventories";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("inventory", new Inventory());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "inventories/form";
    }

    @PostMapping
    public String create(@ModelAttribute Inventory inventory, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            Inventory saved = inventoryService.createInventory(inventory, username);
            return "redirect:/inventories?success=1";
        } catch (Exception e) {
            return "redirect:/inventories/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Inventory> createApi(@RequestBody Inventory inventory, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        try {
            Inventory saved = inventoryService.createInventory(inventory, username);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PostMapping("/{id}/complete")
    public String complete(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            inventoryService.completeInventory(id, username);
            return "redirect:/inventories/" + id;
        } catch (Exception e) {
            return "redirect:/inventories/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/validate")
    public String validate(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            inventoryService.validateInventory(id, username);
            return "redirect:/inventories/" + id;
        } catch (Exception e) {
            return "redirect:/inventories/" + id + "?error=" + e.getMessage();
        }
    }

    // REST API
    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<List<Inventory>> getAllInventories() {
        return ResponseEntity.ok(inventoryService.getAllInventories());
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Inventory> getInventory(@PathVariable Long id) {
        Optional<Inventory> inventory = inventoryService.getInventory(id);
        return inventory.map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
