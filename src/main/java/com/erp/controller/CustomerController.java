package com.erp.controller;

import com.erp.domain.Customer;
import com.erp.service.CustomerService;
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
@RequestMapping("/customers")
public class CustomerController {
    @Autowired
    private CustomerService customerService;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<Customer> customers = customerService.findAll();
        model.addAttribute("customers", customers);
        return "customers/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Customer> customer = customerService.findById(id);
        if (customer.isPresent()) {
            model.addAttribute("customer", customer.get());
            return "customers/detail";
        }
        return "redirect:/customers";
    }

    @GetMapping("/new")
    public String createForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("customer", new Customer());
        return "customers/form";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Customer> customer = customerService.findById(id);
        if (customer.isPresent()) {
            model.addAttribute("customer", customer.get());
            return "customers/form";
        }
        return "redirect:/customers";
    }

    @PostMapping
    public String create(@ModelAttribute Customer customer, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            customerService.createCustomer(customer, username);
            return "redirect:/customers?success=1";
        } catch (Exception e) {
            return "redirect:/customers/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id, @ModelAttribute Customer customer, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        customer.setId(id);
        try {
            customerService.updateCustomer(customer, username);
            return "redirect:/customers";
        } catch (Exception e) {
            return "redirect:/customers/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/{id}/deactivate")
    public String deactivate(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        customerService.deactivateCustomer(id, username);
        return "redirect:/customers";
    }

    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<List<Customer>> getAllCustomers() {
        return ResponseEntity.ok(customerService.findAllActif());
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Customer> getCustomer(@PathVariable Long id) {
        Optional<Customer> customer = customerService.findById(id);
        return customer.map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
