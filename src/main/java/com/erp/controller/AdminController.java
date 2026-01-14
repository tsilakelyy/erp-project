package com.erp.controller;

import com.erp.domain.*;
import com.erp.service.*;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;

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
            return "redirect:/admin/users";
        } catch (Exception e) {
            return "redirect:/admin/users/new?error=" + e.getMessage();
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

        return "admin/warehouses-list";
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
            return "redirect:/admin/units";
        } catch (Exception e) {
            return "redirect:/admin/units?error=" + e.getMessage();
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
            return "redirect:/admin/taxes";
        } catch (Exception e) {
            return "redirect:/admin/taxes?error=" + e.getMessage();
        }
    }
}
