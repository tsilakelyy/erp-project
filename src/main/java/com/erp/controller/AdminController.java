package com.erp.controller;

import com.erp.domain.*;
import com.erp.service.*;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;
import java.util.Map;

@Controller
@RequestMapping("/admin")
public class AdminController {
    @Autowired
    private UserService userService;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private SiteRepository siteRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private TaxRepository taxRepository;

    // Méthode utilitaire pour vérifier la session
    private String checkSession(Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }
        if (user.getRoles() == null || user.getRoles().stream().noneMatch(r -> "ADMIN".equalsIgnoreCase(r.getCode()))) {
            return "redirect:/dashboard";
        }
        model.addAttribute("username", user.getLogin());
        return null;
    }

    @GetMapping


    public String dashboard(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        return "admin/dashboard";
    }

    // ===== Users Management =====
    @GetMapping("/users")

    public String listUsers(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        List<User> users = userService.findAll();
        model.addAttribute("users", users);

        return "admin/users-list";
    }

    @GetMapping("/users/{id}")

    public String detailUser(@PathVariable Long id, Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        Optional<User> user = userService.findById(id);
        if (user.isPresent()) {
            model.addAttribute("user", user.get());

            return "admin/user-detail";
        }
        return "redirect:/admin/users";
    }

    @GetMapping("/users/new")

    public String createUserForm(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        model.addAttribute("user", new User());
        model.addAttribute("roles", roleRepository.findAll());
        model.addAttribute("sites", siteRepository.findAll());

        return "admin/user-form";
    }

    @PostMapping("/users")

    public String createUser(@ModelAttribute User user, HttpSession session) {
        try {

            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null) return "redirect:/login";
            
            userService.createUser(user, currentUser.getLogin());
            return "redirect:/admin/users?success=1";
        } catch (Exception e) {
            return "redirect:/admin/users/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Sites Management =====
    @GetMapping("/sites")

    public String listSites(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        List<Site> sites = siteRepository.findAll();
        model.addAttribute("sites", sites);

        return "admin/sites-list";
    }

    // ===== Warehouses Management =====
    @GetMapping("/warehouses")

    public String listWarehouses(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        List<Warehouse> warehouses = warehouseRepository.findAll();
        model.addAttribute("warehouses", warehouses);
        model.addAttribute("sites", siteRepository.findAll());

        return "warehouses/list";
    }

    // ===== Units Management =====
    @GetMapping("/units")

    public String listUnits(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        List<Unit> units = unitRepository.findAll();
        model.addAttribute("units", units);

        return "admin/units-list";
    }

    @PostMapping("/units")

    public String createUnit(@ModelAttribute Unit unit, HttpSession session) {
        try {
            unitRepository.save(unit);
            return "redirect:/admin/units?success=1";
        } catch (Exception e) {
            return "redirect:/admin/units?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Taxes Management =====
    @GetMapping("/taxes")

    public String listTaxes(Model model, HttpSession session) {
        String redirect = checkSession(model, session);
        if (redirect != null) return redirect;
        
        List<Tax> taxes = taxRepository.findAll();
        model.addAttribute("taxes", taxes);

        return "admin/taxes-list";
    }

    @PostMapping("/taxes")

    public String createTax(@ModelAttribute Tax tax, HttpSession session) {
        try {
            taxRepository.save(tax);
            return "redirect:/admin/taxes?success=1";
        } catch (Exception e) {
            return "redirect:/admin/taxes?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== REST API Warehouses =====
    @GetMapping("/api/warehouses")
    @ResponseBody
    public ResponseEntity<List<Warehouse>> getAllWarehouses() {
        try {
            List<Warehouse> warehouses = warehouseRepository.findAll();
            return ResponseEntity.ok(warehouses);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/api/warehouses/{id}")
    @ResponseBody
    public ResponseEntity<Warehouse> getWarehouseById(@PathVariable Long id) {
        try {
            Optional<Warehouse> warehouse = warehouseRepository.findById(id);
            if (warehouse.isPresent()) {
                return ResponseEntity.ok(warehouse.get());
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/api/warehouses")
    @ResponseBody
    public ResponseEntity<Warehouse> createWarehouse(@RequestBody Warehouse warehouse) {
        try {
            Warehouse saved = warehouseRepository.save(warehouse);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/api/warehouses/{id}")
    @ResponseBody
    public ResponseEntity<Warehouse> updateWarehouse(@PathVariable Long id, @RequestBody Warehouse warehouse) {
        try {
            Optional<Warehouse> existing = warehouseRepository.findById(id);
            if (existing.isPresent()) {
                warehouse.setId(id);
                Warehouse updated = warehouseRepository.save(warehouse);
                return ResponseEntity.ok(updated);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/api/warehouses/{id}")
    @ResponseBody
    public ResponseEntity<?> deleteWarehouse(@PathVariable Long id) {
        try {
            if (warehouseRepository.existsById(id)) {
                warehouseRepository.deleteById(id);
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
