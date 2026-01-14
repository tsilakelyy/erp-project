package com.erp.converter;

import com.erp.domain.*;
import com.erp.dto.*;
import org.springframework.stereotype.Component;

/**
 * DTO Converter - Converts between domain entities and DTOs
 * Uses all DTO classes to ensure they are utilized in the application
 */
@Component
public class DTOConverter {

    /**
     * Convert Article entity to ArticleDTO
     */
    public ArticleDTO articleToDTO(Article article) {
        if (article == null) return null;
        
        return ArticleDTO.builder()
            .id(article.getId())
            .code(article.getCode())
            .libelle(article.getName())
            .description(article.getDescription())
            .uniteMesure(article.getUnit() != null ? article.getUnit().getCode() : null)
            .prixUnitaire(article.getSellingPrice())
            .tauxTva(article.getTax() != null ? article.getTax().getRate() : null)
            .quantiteMinimale((long) article.getMinStock())
            .quantiteMaximale((long) article.getMaxStock())
            .actif(article.getActif())
            .build();
    }

    /**
     * Convert ArticleDTO to Article entity
     */
    public Article dtoToArticle(ArticleDTO dto) {
        if (dto == null) return null;
        
        return Article.builder()
            .id(dto.getId())
            .code(dto.getCode())
            .name(dto.getLibelle())
            .description(dto.getDescription())
            .sellingPrice(dto.getPrixUnitaire())
            .minStock(dto.getQuantiteMinimale() != null ? dto.getQuantiteMinimale().intValue() : 0)
            .maxStock(dto.getQuantiteMaximale() != null ? dto.getQuantiteMaximale().intValue() : 0)
            .ActifgetActif(dto.getActif() != null ? dto.getActif() : true)
            .build();
    }

    /**
     * Convert Customer entity to CustomerDTO
     */
    public CustomerDTO customerToDTO(Customer customer) {
        if (customer == null) return null;
        
        return CustomerDTO.builder()
            .id(customer.getId())
            .code(customer.getCode())
            .nomEntreprise(customer.getName())
            .email(customer.getEmail())
            .telephone(customer.getPhone())
            .adresse(customer.getAddress())
            .ville(customer.getCity())
            .codePostal(customer.getZipCode())
            .contactPrincipal(customer.getCountry())
            .actif(customer.getActif())
            .build();
    }

    /**
     * Convert CustomerDTO to Customer entity
     */
    public Customer dtoToCustomer(CustomerDTO dto) {
        if (dto == null) return null;
        
        return Customer.builder()
            .id(dto.getId())
            .code(dto.getCode())
            .name(dto.getNomEntreprise())
            .email(dto.getEmail())
            .phone(dto.getTelephone())
            .address(dto.getAdresse())
            .city(dto.getVille())
            .zipCode(dto.getCodePostal())
            .country(dto.getContactPrincipal())
            .actif(dto.getActif())
            .build();
    }

    /**
     * Convert Supplier entity to SupplierDTO
     */
    public SupplierDTO supplierToDTO(Supplier supplier) {
        if (supplier == null) return null;
        
        return SupplierDTO.builder()
            .id(supplier.getId())
            .code(supplier.getCode())
            .nomEntreprise(supplier.getName())
            .email(supplier.getEmail())
            .telephone(supplier.getPhone())
            .adresse(supplier.getAddress())
            .ville(supplier.getCity())
            .codePostal(supplier.getZipCode())
            .contactPrincipal(supplier.getCountry())
            .actif(supplier.getActif())
            .build();
    }

    /**
     * Convert SupplierDTO to Supplier entity
     */
    public Supplier dtoToSupplier(SupplierDTO dto) {
        if (dto == null) return null;
        
        return Supplier.builder()
            .id(dto.getId())
            .code(dto.getCode())
            .name(dto.getNomEntreprise())
            .email(dto.getEmail())
            .phone(dto.getTelephone())
            .address(dto.getAdresse())
            .city(dto.getVille())
            .zipCode(dto.getCodePostal())
            .country(dto.getContactPrincipal())
            .ActifgetActif(dto.getActif())
            .build();
    }

    /**
     * Convert Warehouse entity to WarehouseDTO
     */
    public WarehouseDTO warehouseToDTO(Warehouse warehouse) {
        if (warehouse == null) return null;
        
        return WarehouseDTO.builder()
            .id(warehouse.getId())
            .code(warehouse.getCode())
            .nomDepot(warehouse.getName())
            .adresse(warehouse.getAddress())
            .actif(warehouse.getActif())
            .build();
    }

    /**
     * Convert WarehouseDTO to Warehouse entity
     */
    public Warehouse dtoToWarehouse(WarehouseDTO dto) {
        if (dto == null) return null;
        
        return Warehouse.builder()
            .id(dto.getId())
            .code(dto.getCode())
            .name(dto.getNomDepot())
            .address(dto.getAdresse())
            .ActifgetActif(dto.getActif())
            .build();
    }

    /**
     * Convert User entity to UserDTO
     */
    public UserDTO userToDTO(User user) {
        if (user == null) return null;
        
        return UserDTO.builder()
            .id(user.getId())
            .login(user.getUsername())
            .email(user.getEmail())
            .nom(user.getLastName())
            .prenom(user.getFirstName())
            .actif(user.getActif())
            .build();
    }

    /**
     * Convert UserDTO to User entity
     */
    public User dtoToUser(UserDTO dto) {
        if (dto == null) return null;
        
        return User.builder()
            .id(dto.getId())
            .username(dto.getLogin())
            .email(dto.getEmail())
            .firstName(dto.getPrenom())
            .lastName(dto.getNom())
            .ActifgetActif(dto.getActif())
            .build();
    }

    /**
     * Build a KPI from service data
     */
    public KpiDTO buildKpi(String name, Object value, String unit, String trend) {
        return KpiDTO.builder()
            .kpiName(name)
            .value(value)
            .unit(unit)
            .period("current")
            .trend(trend)
            .calculatedAt(java.time.LocalDateTime.now())
            .build();
    }
}
