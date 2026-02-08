package com.erp.controller;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/reports")
public class ReportsController {
    @GetMapping
    public String index(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";
        return "reports/index";
    }

    @GetMapping("/purchases")
    public String purchases(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";
        return "reports/purchases-analytics";
    }

    @GetMapping("/sales")
    public String sales(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";
        return "reports/sales-analytics";
    }

    @GetMapping("/financial")
    public String financial(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";
        return "reports/financial-report";
    }

    @GetMapping("/inventory")
    public String inventory(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";
        return "reports/inventory-report";
    }

    @GetMapping("/validations")
    public String validations(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";
        return "reports/validation-tracking";
    }
}
