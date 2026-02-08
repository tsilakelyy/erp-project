package com.erp.controller;

import com.erp.domain.Customer;
import com.erp.domain.Supplier;
import com.erp.service.CustomerService;
import com.erp.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class PublicLookupController {

    @Autowired
    private SupplierService supplierService;

    @Autowired
    private CustomerService customerService;

    @GetMapping("/suppliers")
    public List<Map<String, Object>> getSuppliers() {
        List<Supplier> suppliers = supplierService.findAllActive();
        return suppliers.stream().map(s -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", s.getId());
            map.put("code", s.getCode());
            map.put("libelle", s.getNomEntreprise());
            return map;
        }).collect(Collectors.toList());
    }

    @GetMapping("/customers")
    public List<Map<String, Object>> getCustomers() {
        List<Customer> customers = customerService.findAllActif();
        return customers.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("code", c.getCode());
            map.put("libelle", c.getNomEntreprise());
            return map;
        }).collect(Collectors.toList());
    }
}
