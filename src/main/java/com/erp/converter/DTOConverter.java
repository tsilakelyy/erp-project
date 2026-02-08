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
            .libelle(article.getLibelle())
            .description(article.getDescription())
            .uniteMesure(article.getUniteMesure())
            .prixUnitaire(article.getPrixUnitaire())
            .tauxTva(article.getTauxTva())
            .quantiteMinimale(article.getQuantiteMinimale())
            .quantiteMaximale(article.getQuantiteMaximale())
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
            .libelle(dto.getLibelle())
            .description(dto.getDescription())
            .uniteMesure(dto.getUniteMesure())
            .prixUnitaire(dto.getPrixUnitaire())
            .tauxTva(dto.getTauxTva())
            .quantiteMinimale(dto.getQuantiteMinimale())
            .quantiteMaximale(dto.getQuantiteMaximale())
            .actif(dto.getActif() != null ? dto.getActif() : true)
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
            .nomEntreprise(customer.getNomEntreprise())
            .email(customer.getEmail())
            .telephone(customer.getTelephone())
            .adresse(customer.getAdresse())
            .ville(customer.getVille())
            .codePostal(customer.getCodePostal())
            .contactPrincipal(customer.getContactPrincipal())
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
            .nomEntreprise(dto.getNomEntreprise())
            .email(dto.getEmail())
            .telephone(dto.getTelephone())
            .adresse(dto.getAdresse())
            .ville(dto.getVille())
            .codePostal(dto.getCodePostal())
            .contactPrincipal(dto.getContactPrincipal())
            .actif(dto.getActif() != null ? dto.getActif() : true)
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
            .nomEntreprise(supplier.getNomEntreprise())
            .email(supplier.getEmail())
            .telephone(supplier.getTelephone())
            .adresse(supplier.getAdresse())
            .ville(supplier.getVille())
            .codePostal(supplier.getCodePostal())
            .contactPrincipal(supplier.getContactPrincipal())
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
            .nomEntreprise(dto.getNomEntreprise())
            .email(dto.getEmail())
            .telephone(dto.getTelephone())
            .adresse(dto.getAdresse())
            .ville(dto.getVille())
            .codePostal(dto.getCodePostal())
            .contactPrincipal(dto.getContactPrincipal())
            .actif(dto.getActif() != null ? dto.getActif() : true)
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
            .nomDepot(warehouse.getNomDepot())
            .adresse(warehouse.getAdresse())
            .codePostal(warehouse.getCodePostal())
            .ville(warehouse.getVille())
            .responsableId(warehouse.getResponsableId())
            .capaciteMaximale(warehouse.getCapaciteMaximale())
            .niveauStockSecurite(warehouse.getNiveauStockSecurite())
            .niveauStockAlerte(warehouse.getNiveauStockAlerte())
            .typeDepot(warehouse.getTypeDepot())
            .actif(warehouse.getActif())
            .dateCreation(warehouse.getDateCreation())
            .dateModification(warehouse.getDateModification())
            .utilisateurCreation(warehouse.getUtilisateurCreation())
            .utilisateurModification(warehouse.getUtilisateurModification())
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
            .nomDepot(dto.getNomDepot())
            .adresse(dto.getAdresse())
            .codePostal(dto.getCodePostal())
            .ville(dto.getVille())
            .responsableId(dto.getResponsableId())
            .capaciteMaximale(dto.getCapaciteMaximale())
            .niveauStockSecurite(dto.getNiveauStockSecurite())
            .niveauStockAlerte(dto.getNiveauStockAlerte())
            .typeDepot(dto.getTypeDepot())
            .actif(dto.getActif() != null ? dto.getActif() : true)
            .dateCreation(dto.getDateCreation())
            .dateModification(dto.getDateModification())
            .utilisateurCreation(dto.getUtilisateurCreation())
            .utilisateurModification(dto.getUtilisateurModification())
            .build();
    }

    /**
     * Convert User entity to UserDTO
     */
    public UserDTO userToDTO(User user) {
        if (user == null) return null;
        
        return UserDTO.builder()
            .id(user.getId())
            .login(user.getLogin())
            .email(user.getEmail())
            .nom(user.getNom())
            .prenom(user.getPrenom())
            .actif(user.getActive())
            .build();
    }

    /**
     * Convert UserDTO to User entity
     */
    public User dtoToUser(UserDTO dto) {
        if (dto == null) return null;
        
        User user = new User();
        user.setId(dto.getId());
        user.setLogin(dto.getLogin());
        user.setEmail(dto.getEmail());
        user.setNom(dto.getNom());
        user.setPrenom(dto.getPrenom());
        user.setActive(dto.getActif() != null ? dto.getActif() : true);
        
        return user;
    }

    /**
     * Convert PurchaseRequest entity to PurchaseRequestDTO
     */
    public PurchaseRequestDTO purchaseRequestToDTO(PurchaseRequest request) {
        if (request == null) return null;
        
        return PurchaseRequestDTO.builder()
            .id(request.getId())
            .numero(request.getNumero())
            .statut(request.getStatut())
            .dateCreation(request.getDateCreation())
            .dateSubmission(request.getDateSubmission())
            .dateValidity(request.getDateValidity())
            .entrepotId(request.getEntrepotId())
            .montantEstime(request.getMontantEstime())
            .utilisateurCreation(request.getUtilisateurCreation())
            .utilisateurApprobation(request.getUtilisateurApprobation())
            .motifRejet(request.getMotifRejet())
            .build();
    }

    /**
     * Convert PurchaseRequestDTO to PurchaseRequest entity
     */
    public PurchaseRequest dtoToPurchaseRequest(PurchaseRequestDTO dto) {
        if (dto == null) return null;
        
        return PurchaseRequest.builder()
            .id(dto.getId())
            .numero(dto.getNumero())
            .statut(dto.getStatut())
            .dateCreation(dto.getDateCreation())
            .dateSubmission(dto.getDateSubmission())
            .dateValidity(dto.getDateValidity())
            .entrepotId(dto.getEntrepotId())
            .montantEstime(dto.getMontantEstime())
            .utilisateurCreation(dto.getUtilisateurCreation())
            .utilisateurApprobation(dto.getUtilisateurApprobation())
            .motifRejet(dto.getMotifRejet())
            .build();
    }

    /**
     * Convert PurchaseOrder entity to PurchaseOrderDTO
     */
    public PurchaseOrderDTO purchaseOrderToDTO(PurchaseOrder order) {
        if (order == null) return null;
        
        return PurchaseOrderDTO.builder()
            .id(order.getId())
            .numero(order.getNumero())
            .statut(order.getStatut())
            .dateCreation(order.getDateCreation())
            .dateCommande(order.getDateCommande())
            .dateEcheanceEstimee(order.getDateEcheanceEstimee())
            .fournisseurId(order.getFournisseurId())
            .entrepotId(order.getEntrepotId())
            .montantHt(order.getMontantHt())
            .montantTva(order.getMontantTva())
            .montantTtc(order.getMontantTtc())
            .tauxTva(order.getTauxTva())
            .utilisateurCreation(order.getUtilisateurCreation())
            .utilisateurApprobation(order.getUtilisateurApprobation())
            .build();
    }

    /**
     * Convert PurchaseOrderDTO to PurchaseOrder entity
     */
    public PurchaseOrder dtoToPurchaseOrder(PurchaseOrderDTO dto) {
        if (dto == null) return null;
        
        return PurchaseOrder.builder()
            .id(dto.getId())
            .numero(dto.getNumero())
            .statut(dto.getStatut())
            .dateCreation(dto.getDateCreation())
            .dateCommande(dto.getDateCommande())
            .dateEcheanceEstimee(dto.getDateEcheanceEstimee())
            .fournisseurId(dto.getFournisseurId())
            .entrepotId(dto.getEntrepotId())
            .montantHt(dto.getMontantHt())
            .montantTva(dto.getMontantTva())
            .montantTtc(dto.getMontantTtc())
            .tauxTva(dto.getTauxTva())
            .utilisateurCreation(dto.getUtilisateurCreation())
            .utilisateurApprobation(dto.getUtilisateurApprobation())
            .build();
    }

    /**
     * Convert SalesOrder entity to SalesOrderDTO
     */
    public SalesOrderDTO salesOrderToDTO(SalesOrder order) {
        if (order == null) return null;
        
        return SalesOrderDTO.builder()
            .id(order.getId())
            .numero(order.getNumero())
            .statut(order.getStatut())
            .dateCreation(order.getDateCreation())
            .dateCommande(order.getDateCommande())
            .clientId(order.getClientId())
            .entrepotId(order.getEntrepotId())
            .clientRequestId(order.getClientRequestId())
            .proformaId(order.getProformaId())
            .montantHt(order.getMontantHt())
            .montantTva(order.getMontantTva())
            .montantTtc(order.getMontantTtc())
            .tauxTva(order.getTauxTva())
            .utilisateurCreation(order.getUtilisateurCreation())
            .utilisateurApprobation(order.getUtilisateurApprobation())
            .build();
    }

    /**
     * Convert SalesOrderDTO to SalesOrder entity
     */
    public SalesOrder dtoToSalesOrder(SalesOrderDTO dto) {
        if (dto == null) return null;
        
        return SalesOrder.builder()
            .id(dto.getId())
            .numero(dto.getNumero())
            .statut(dto.getStatut())
            .dateCreation(dto.getDateCreation())
            .dateCommande(dto.getDateCommande())
            .clientId(dto.getClientId())
            .entrepotId(dto.getEntrepotId())
            .clientRequestId(dto.getClientRequestId())
            .proformaId(dto.getProformaId())
            .montantHt(dto.getMontantHt())
            .montantTva(dto.getMontantTva())
            .montantTtc(dto.getMontantTtc())
            .tauxTva(dto.getTauxTva())
            .utilisateurCreation(dto.getUtilisateurCreation())
            .utilisateurApprobation(dto.getUtilisateurApprobation())
            .build();
    }

    /**
     * Convert Delivery entity to DeliveryDTO
     */
    public DeliveryDTO deliveryToDTO(Delivery delivery) {
        if (delivery == null) return null;
        
        return DeliveryDTO.builder()
            .id(delivery.getId())
            .numero(delivery.getNumero())
            .statut(delivery.getStatut())
            .dateCreation(delivery.getDateCreation())
            .dateLivraison(delivery.getDateLivraison())
            .commandeClientId(delivery.getCommandeClientId())
            .entrepotId(delivery.getEntrepotId())
            .utilisateurPicking(delivery.getUtilisateurPicking())
            .utilisateurExpedition(delivery.getUtilisateurExpedition())
            .build();
    }

    /**
     * Convert DeliveryDTO to Delivery entity
     */
    public Delivery dtoToDelivery(DeliveryDTO dto) {
        if (dto == null) return null;
        
        return Delivery.builder()
            .id(dto.getId())
            .numero(dto.getNumero())
            .statut(dto.getStatut())
            .dateCreation(dto.getDateCreation())
            .dateLivraison(dto.getDateLivraison())
            .commandeClientId(dto.getCommandeClientId())
            .entrepotId(dto.getEntrepotId())
            .utilisateurPicking(dto.getUtilisateurPicking())
            .utilisateurExpedition(dto.getUtilisateurExpedition())
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
