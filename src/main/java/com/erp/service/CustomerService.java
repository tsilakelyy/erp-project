package com.erp.service;

import com.erp.domain.Customer;
import com.erp.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CustomerService {
    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private AuditService auditService;

    public Optional<Customer> findById(Long id) {
        return customerRepository.findById(id);
    }

    public Optional<Customer> findByCode(String code) {
        return customerRepository.findByCode(code);
    }

    public List<Customer> findAll() {
        return customerRepository.findAll();
    }

    public List<Customer> findAllActive() {
        return customerRepository.findByActifTrue();
    }

    public Customer createCustomer(Customer customer, String currentUsername) {
        if (customerRepository.findByCode(customer.getCode()).isPresent()) {
            throw new IllegalArgumentException("Customer code already exists: " + customer.getCode());
        }
        customer.setUtilisateurCreation(currentUsername);
        customer.setActif(true);
        Customer saved = customerRepository.save(customer);
        auditService.logAction("Customer", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Customer updateCustomer(Customer customer, String currentUsername) {
        Optional<Customer> existing = customerRepository.findById(customer.getId());
        if (existing.isPresent()) {
            Customer c = existing.get();
            c.setNomEntreprise(customer.getNomEntreprise());
            c.setAdresse(customer.getAdresse());
            c.setVille(customer.getVille());
            c.setCodePostal(customer.getCodePostal());
            c.setTelephone(customer.getTelephone());
            c.setEmail(customer.getEmail());
            c.setContactPrincipal(customer.getContactPrincipal());
            c.setDelaiPaiementJours(customer.getDelaiPaiementJours());
            c.setUtilisateurModification(currentUsername);
            c.setDateModification(java.time.LocalDateTime.now());
            Customer updated = customerRepository.save(c);
            auditService.logAction("Customer", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public void deactivateCustomer(Long id, String currentUsername) {
        Optional<Customer> customer = customerRepository.findById(id);
        if (customer.isPresent()) {
            Customer c = customer.get();
            c.setActif(false);
            c.setUtilisateurModification(currentUsername);
            c.setDateModification(java.time.LocalDateTime.now());
            customerRepository.save(c);
            auditService.logAction("Customer", c.getId(), "DEACTIVATE", currentUsername);
        }
    }
}
