package com.erp.service;

import com.erp.domain.*;
import com.erp.dto.KpiDTO;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

/**
 * KpiService - Service centralisé pour calculer tous les KPIs par rôle
 * 
 * Gère les KPIs pour:
 * - Direction Générale / Comité de Direction
 * - Responsable Achats / Supply Chain
 * - Magasin / Responsable Stock
 * - Ventes / Responsable Commercial
 * - Finance / DAF
 * 
 * TODO: Complexifier les calculs avec des paramètres de période
 * TODO: Ajouter des formules plus avancées avec statistiques
 * TODO: Implémenter la caching des résultats KPI
 * TODO: Ajouter des graphiques de tendance (trend analysis)
 */
@Service
@Transactional(readOnly = true)
public class KpiService {

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private PurchaseRequestRepository purchaseRequestRepository;

    @Autowired
    private SalesOrderRepository salesOrderRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private StockLevelRepository stockLevelRepository;

    @Autowired
    private StockMovementRepository stockMovementRepository;

    @Autowired
    private SupplierRepository supplierRepository;

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private GoodReceiptRepository goodReceiptRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private ArticleService articleService;

    @Autowired
    private InventoryService inventoryService;

    // ==================== DIRECTION GÉNÉRALE / COMITÉ DE DIRECTION ====================

    /**
     * Récupère tous les KPIs pour la Direction Générale
     * KPIs: CA, marge brute, marge %, stock value, rotation stock, surstocks, écarts inventaire
     */
    public Map<String, KpiDTO> getDirectionKpis() {
        Map<String, KpiDTO> kpis = new LinkedHashMap<>();
        
        kpis.put("ca_total", getCATotal());
        kpis.put("marge_brute", getMargeBrute());
        kpis.put("marge_pourcentage", getMargePourcentage());
        kpis.put("stock_value_total", getStockValueTotal());
        kpis.put("stock_evolution_m1", getStockEvolutionM1());
        kpis.put("stock_evolution_m12", getStockEvolutionM12());
        kpis.put("stock_turnover", getStockTurnover());
        kpis.put("top_surstocks", getTopSurstocks());
        kpis.put("taux_ecarts_inventaire_valeur", getTauxEcartsInventaireValeur());
        kpis.put("taux_ecarts_inventaire_pourcentage", getTauxEcartsInventairePourcentage());
        
        return kpis;
    }

    // Direction KPI: Chiffre d'Affaires Total
    private KpiDTO getCATotal() {
        // TODO: Récupérer le CA total des factures du mois en cours
        List<Invoice> invoices = invoiceRepository.findByDateFactureBetween(
            LocalDateTime.now().with(TemporalAdjusters.firstDayOfMonth()),
            LocalDateTime.now().with(TemporalAdjusters.lastDayOfMonth())
        );
        
        BigDecimal caTotal = invoices.stream()
            .map(Invoice::getMontantTtc)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return KpiDTO.builder()
            .kpiName("Chiffre d'Affaires Total")
            .value(caTotal)
            .unit("€")
            .period("month")
            .trend(getTrendFromHistorical(caTotal))
            .target(BigDecimal.valueOf(1000000))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Marge Brute
    private KpiDTO getMargeBrute() {
        // TODO: Calculer la marge brute réelle avec coûts d'achat
        BigDecimal margeBrute = BigDecimal.ZERO;
        
        List<Invoice> invoices = invoiceRepository.findAll();
        for (Invoice invoice : invoices) {
            // Calcul simplifié - à améliorer
            if (invoice.getMontantTtc() != null) {
                margeBrute = margeBrute.add(invoice.getMontantTtc().multiply(new BigDecimal("0.35")));
            }
        }
        
        return KpiDTO.builder()
            .kpiName("Marge Brute")
            .value(margeBrute)
            .unit("€")
            .period("month")
            .trend("stable")
            .target(BigDecimal.valueOf(500000))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Marge en Pourcentage
    private KpiDTO getMargePourcentage() {
        // TODO: Calculer marge % = (CA - coût) / CA
        BigDecimal ca = BigDecimal.valueOf(1000000);
        BigDecimal marge = BigDecimal.valueOf(35);
        
        return KpiDTO.builder()
            .kpiName("Marge %")
            .value(marge)
            .unit("%")
            .period("month")
            .trend("increasing")
            .target(new BigDecimal("40"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Valeur Stock Total
    private KpiDTO getStockValueTotal() {
        // TODO: Additionner valeur stock pour tous les entrepôts
        List<StockLevel> stockLevels = stockLevelRepository.findAll();
        BigDecimal stockValue = stockLevels.stream()
            .map(sl -> {
                if (sl.getArticle() != null && sl.getArticle().getPrixUnitaire() != null) {
                    return sl.getArticle().getPrixUnitaire()
                        .multiply(new BigDecimal(sl.getQuantiteDisponible()));
                }
                return BigDecimal.ZERO;
            })
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return KpiDTO.builder()
            .kpiName("Valeur Stock Total")
            .value(stockValue)
            .unit("€")
            .period("current")
            .trend("stable")
            .target(BigDecimal.valueOf(5000000))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Évolution Stock M-1
    private KpiDTO getStockEvolutionM1() {
        // TODO: Comparer stock actuel avec stock d'il y a 1 mois
        BigDecimal evolution = new BigDecimal("5.2");
        
        return KpiDTO.builder()
            .kpiName("Évolution Stock M-1")
            .value(evolution)
            .unit("%")
            .period("month")
            .trend("decreasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Évolution Stock M-12
    private KpiDTO getStockEvolutionM12() {
        // TODO: Comparer stock actuel avec stock d'il y a 12 mois
        BigDecimal evolution = new BigDecimal("12.5");
        
        return KpiDTO.builder()
            .kpiName("Évolution Stock M-12")
            .value(evolution)
            .unit("%")
            .period("year")
            .trend("increasing")
            .target(new BigDecimal("10"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Rotation Stock (Turnover)
    private KpiDTO getStockTurnover() {
        // TODO: Rotation stock = CA / valeur stock moyen
        // Nombre de fois que le stock est renouvelé
        BigDecimal turnover = new BigDecimal("4.5");
        
        return KpiDTO.builder()
            .kpiName("Rotation Stock (Turnover)")
            .value(turnover)
            .unit("fois/an")
            .period("year")
            .trend("stable")
            .target(new BigDecimal("5"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Top 5 Surstocks / Obsolescence
    private KpiDTO getTopSurstocks() {
        // TODO: Identifier les articles avec stock > quantité maximale
        List<StockLevel> surstocks = stockLevelRepository.findAll().stream()
            .filter(sl -> sl.getQuantiteDisponible() > 0 
                    && sl.getArticle() != null 
                    && sl.getArticle().getQuantiteMaximale() != null
                    && sl.getQuantiteDisponible() > sl.getArticle().getQuantiteMaximale())
            .sorted((a, b) -> Long.compare(b.getQuantiteDisponible(), a.getQuantiteDisponible()))
            .limit(5)
            .collect(Collectors.toList());
        
        BigDecimal surstockValue = surstocks.stream()
            .map(sl -> {
                if (sl.getArticle() != null && sl.getArticle().getPrixUnitaire() != null) {
                    long excessQty = sl.getQuantiteDisponible() - sl.getArticle().getQuantiteMaximale();
                    return sl.getArticle().getPrixUnitaire().multiply(new BigDecimal(excessQty));
                }
                return BigDecimal.ZERO;
            })
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return KpiDTO.builder()
            .kpiName("Top 5 Surstocks (valeur immobilisée)")
            .value(surstockValue)
            .unit("€")
            .period("current")
            .trend("increasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Taux d'Écarts Inventaire (Valeur)
    private KpiDTO getTauxEcartsInventaireValeur() {
        // TODO: Calculer les écarts entre stock théorique et physique en valeur
        BigDecimal ecartValeur = BigDecimal.ZERO;
        
        List<Inventory> inventories = inventoryService.getAllInventories();
        for (Inventory inv : inventories) {
            if (inv.getLines() != null) {
                for (InventoryLine line : inv.getLines()) {
                    if (line.getArticle() != null && line.getArticle().getPrixUnitaire() != null) {
                        long theorie = line.getQuantiteTheorique() != null ? line.getQuantiteTheorique() : 0;
                        long comptee = line.getQuantiteComptee() != null ? line.getQuantiteComptee() : 0;
                        long ecart = Math.abs(theorie - comptee);
                        ecartValeur = ecartValeur.add(
                            line.getArticle().getPrixUnitaire().multiply(new BigDecimal(ecart))
                        );
                    }
                }
            }
        }
        
        return KpiDTO.builder()
            .kpiName("Écarts Inventaire (Valeur)")
            .value(ecartValeur)
            .unit("€")
            .period("current")
            .trend("stable")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Direction KPI: Taux d'Écarts Inventaire (Pourcentage)
    private KpiDTO getTauxEcartsInventairePourcentage() {
        // TODO: Calculer le % d'écarts par rapport au stock total
        BigDecimal tauxEcarts = new BigDecimal("2.3");
        
        return KpiDTO.builder()
            .kpiName("Taux Écarts Inventaire (%)")
            .value(tauxEcarts)
            .unit("%")
            .period("current")
            .trend("decreasing")
            .target(new BigDecimal("1"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // ==================== RESPONSABLE ACHATS / SUPPLY CHAIN ====================

    /**
     * Récupère tous les KPIs pour le Responsable Achats
     */
    public Map<String, KpiDTO> getPurchaseKpis() {
        Map<String, KpiDTO> kpis = new LinkedHashMap<>();
        
        kpis.put("cycle_time_da_bc_median", getCycleTimeDABCMedian());
        kpis.put("cycle_time_da_bc_p90", getCycleTimeDABCP90());
        kpis.put("otd_supplier", getOTDSupplier());
        kpis.put("reception_conform", getReceptionConform());
        kpis.put("taux_litiges_facture", getTauxLitigesFacture());
        kpis.put("concentration_fournisseurs", getConcentrationFournisseurs());
        kpis.put("evolution_prix_achat", getEvolutionPrixAchat());
        kpis.put("taux_commandes_urgentes", getTauxCommandesUrgentes());
        
        return kpis;
    }

    // Achats KPI: Cycle Time DA→BC (Médiane)
    private KpiDTO getCycleTimeDABCMedian() {
        // TODO: Calculer temps médian entre DA creation et BC confirmation
        List<PurchaseOrder> pos = purchaseOrderRepository.findAll();
        
        List<Long> cycleTimes = pos.stream()
            .filter(po -> po.getDateCreation() != null && po.getDateCommande() != null)
            .map(po -> java.time.temporal.ChronoUnit.DAYS.between(po.getDateCreation(), po.getDateCommande()))
            .sorted()
            .collect(Collectors.toList());
        
        Long medianCycleTime = cycleTimes.isEmpty() ? 0 : cycleTimes.get(cycleTimes.size() / 2);
        
        return KpiDTO.builder()
            .kpiName("Cycle Time DA→BC (Médiane)")
            .value(medianCycleTime)
            .unit("jours")
            .period("current")
            .trend("stable")
            .target(BigDecimal.valueOf(14))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Cycle Time DA→BC (P90)
    private KpiDTO getCycleTimeDABCP90() {
        // TODO: Calculer le P90 (90e percentile) du cycle time
        List<PurchaseOrder> pos = purchaseOrderRepository.findAll();
        
        List<Long> cycleTimes = pos.stream()
            .filter(po -> po.getDateCreation() != null && po.getDateCommande() != null)
            .map(po -> java.time.temporal.ChronoUnit.DAYS.between(po.getDateCreation(), po.getDateCommande()))
            .sorted()
            .collect(Collectors.toList());
        
        Long p90CycleTime = cycleTimes.isEmpty() ? 0 
            : cycleTimes.get((int)(cycleTimes.size() * 0.9));
        
        return KpiDTO.builder()
            .kpiName("Cycle Time DA→BC (P90)")
            .value(p90CycleTime)
            .unit("jours")
            .period("current")
            .trend("stable")
            .target(BigDecimal.valueOf(21))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Respect Délais Fournisseurs (OTD Supplier)
    private KpiDTO getOTDSupplier() {
        // TODO: % de commandes reçues à temps
        List<GoodReceipt> receipts = goodReceiptRepository.findAll();
        
        long onTimeCount = receipts.stream()
            .filter(gr -> gr.getDateReception() != null && gr.getDateCreation() != null
                    && gr.getDateReception().isBefore(gr.getDateCreation().plusDays(30)))
            .count();
        
        BigDecimal otdPercentage = receipts.isEmpty() ? BigDecimal.ZERO 
            : new BigDecimal(onTimeCount * 100).divide(new BigDecimal(receipts.size()), 2, RoundingMode.HALF_UP);
        
        return KpiDTO.builder()
            .kpiName("Respect Délais Fournisseurs (OTD)")
            .value(otdPercentage)
            .unit("%")
            .period("month")
            .trend("increasing")
            .target(new BigDecimal("95"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Taux Réception Conforme
    private KpiDTO getReceptionConform() {
        // TODO: % de réceptions conformes (qualité + quantité)
        List<GoodReceipt> receipts = goodReceiptRepository.findAll();
        
        long conformCount = receipts.stream()
            .filter(gr -> "CONFORME".equals(gr.getStatut()))
            .count();
        
        BigDecimal conformPercentage = receipts.isEmpty() ? BigDecimal.ZERO 
            : new BigDecimal(conformCount * 100).divide(new BigDecimal(receipts.size()), 2, RoundingMode.HALF_UP);
        
        return KpiDTO.builder()
            .kpiName("Taux Réception Conforme")
            .value(conformPercentage)
            .unit("%")
            .period("month")
            .trend("increasing")
            .target(new BigDecimal("98"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Taux Litiges Facture
    private KpiDTO getTauxLitigesFacture() {
        // TODO: % de factures avec anomalies 3-way match
        List<Invoice> invoices = invoiceRepository.findAll();
        
        long litigeCount = invoices.stream()
            .filter(inv -> "LITIGE".equals(inv.getStatut()) || "EN_ATTENTE".equals(inv.getStatut()))
            .count();
        
        BigDecimal litigePercentage = invoices.isEmpty() ? BigDecimal.ZERO 
            : new BigDecimal(litigeCount * 100).divide(new BigDecimal(invoices.size()), 2, RoundingMode.HALF_UP);
        
        return KpiDTO.builder()
            .kpiName("Taux Litiges Facture (3-way mismatch)")
            .value(litigePercentage)
            .unit("%")
            .period("month")
            .trend("decreasing")
            .target(new BigDecimal("2"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Concentration Fournisseurs
    private KpiDTO getConcentrationFournisseurs() {
        // TODO: % du volume d'achats concentré sur les top 3 suppliers
        List<Supplier> suppliers = supplierRepository.findAll();
        
        // Top 3 suppliers par volume d'achats
        BigDecimal totalPurchasse = BigDecimal.ZERO;
        BigDecimal top3Volume = BigDecimal.ZERO;
        
        // TODO: Implémenter la logique complète
        
        return KpiDTO.builder()
            .kpiName("Concentration Fournisseurs (Top 3)")
            .value(new BigDecimal("45.5"))
            .unit("%")
            .period("month")
            .trend("increasing")
            .target(new BigDecimal("40"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Évolution Prix d'Achat
    private KpiDTO getEvolutionPrixAchat() {
        // TODO: Index d'évolution prix par article clé
        BigDecimal priceEvolution = new BigDecimal("3.2");
        
        return KpiDTO.builder()
            .kpiName("Évolution Prix d'Achat (Index)")
            .value(priceEvolution)
            .unit("%")
            .period("month")
            .trend("increasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Achats KPI: Taux Commandes Urgentes
    private KpiDTO getTauxCommandesUrgentes() {
        // TODO: % de commandes créées en mode urgence (hors processus standard)
        List<PurchaseOrder> pos = purchaseOrderRepository.findAll();
        
        long urgentCount = pos.stream()
            .filter(po -> po.getDateCommande() != null && po.getDateCreation() != null
                    && java.time.temporal.ChronoUnit.DAYS.between(
                        po.getDateCreation(), po.getDateCommande()) < 2)
            .count();
        
        BigDecimal urgentPercentage = pos.isEmpty() ? BigDecimal.ZERO 
            : new BigDecimal(urgentCount * 100).divide(new BigDecimal(pos.size()), 2, RoundingMode.HALF_UP);
        
        return KpiDTO.builder()
            .kpiName("Taux Commandes Urgentes")
            .value(urgentPercentage)
            .unit("%")
            .period("month")
            .trend("decreasing")
            .target(new BigDecimal("5"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // ==================== MAGASIN / RESPONSABLE STOCK ====================

    /**
     * Récupère tous les KPIs pour le Magasinier
     */
    public Map<String, KpiDTO> getWarehouseKpis() {
        Map<String, KpiDTO> kpis = new LinkedHashMap<>();
        
        kpis.put("precision_stock_theorique_physique", getPrecisionStockTheoricoPhysique());
        kpis.put("obsolescence_peremption_valeur", getObsolescencePeremptionValeur());
        kpis.put("lots_risque", getLotsRisque());
        kpis.put("productivite_picking", getProductivitePickingLignesHeure());
        kpis.put("erreurs_picking", getErreursPicking());
        kpis.put("temps_dock_to_stock", getTempsDockToStock());
        
        return kpis;
    }

    // Stock KPI: Taux Précision Stock
    private KpiDTO getPrecisionStockTheoricoPhysique() {
        // TODO: % de lignes de stock où théorique = physique
        List<StockLevel> stockLevels = stockLevelRepository.findAll();
        
        long preciseCount = stockLevels.stream()
            .filter(sl -> sl.getQuantiteDisponible() >= 0)
            .count();
        
        BigDecimal precisionRate = stockLevels.isEmpty() ? BigDecimal.ZERO 
            : new BigDecimal(preciseCount * 100).divide(new BigDecimal(stockLevels.size()), 2, RoundingMode.HALF_UP);
        
        return KpiDTO.builder()
            .kpiName("Taux Précision Stock (Théorique vs Physique)")
            .value(precisionRate)
            .unit("%")
            .period("month")
            .trend("increasing")
            .target(new BigDecimal("99"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Stock KPI: Obsolescence / Péremption (Valeur)
    private KpiDTO getObsolescencePeremptionValeur() {
        // TODO: Valeur des articles obsolètes ou proches de péremption
        BigDecimal obsoleteValue = BigDecimal.ZERO;
        
        List<StockLevel> stockLevels = stockLevelRepository.findAll();
        for (StockLevel sl : stockLevels) {
            if (sl.getArticle() != null && sl.getArticle().getPrixUnitaire() != null && sl.getQuantiteDisponible() > 0) {
                // Articles avec très faible mouvement
                obsoleteValue = obsoleteValue.add(
                    sl.getArticle().getPrixUnitaire().multiply(new BigDecimal(sl.getQuantiteDisponible() / 10))
                );
            }
        }
        
        return KpiDTO.builder()
            .kpiName("Obsolescence/Péremption (Valeur)")
            .value(obsoleteValue)
            .unit("€")
            .period("current")
            .trend("stable")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Stock KPI: Lots à Risque
    private KpiDTO getLotsRisque() {
        // TODO: Nombre de lots proches de péremption ou avec date limite dépassée
        long lotsAtRisk = 0;
        
        // À implémenter en fonction de la table de lot
        
        return KpiDTO.builder()
            .kpiName("Lots à Risque")
            .value(lotsAtRisk)
            .unit("lots")
            .period("current")
            .trend("stable")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Stock KPI: Productivité Picking (Lignes/Heure)
    private KpiDTO getProductivitePickingLignesHeure() {
        // TODO: Nombre de lignes de picking traitées par heure
        BigDecimal productivityLinesPerHour = new BigDecimal("45.5");
        
        return KpiDTO.builder()
            .kpiName("Productivité Picking (Lignes/Heure)")
            .value(productivityLinesPerHour)
            .unit("lignes/h")
            .period("day")
            .trend("stable")
            .target(new BigDecimal("40"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Stock KPI: Erreurs Picking
    private KpiDTO getErreursPicking() {
        // TODO: Nombre et taux d'erreurs de picking
        BigDecimal errorRate = new BigDecimal("0.8");
        
        return KpiDTO.builder()
            .kpiName("Taux Erreurs Picking")
            .value(errorRate)
            .unit("%")
            .period("month")
            .trend("decreasing")
            .target(new BigDecimal("0.5"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Stock KPI: Temps Dock-to-Stock
    private KpiDTO getTempsDockToStock() {
        // TODO: Temps moyen de traitement de la réception (du dock au stock)
        List<GoodReceipt> receipts = goodReceiptRepository.findAll();
        
        long totalMinutes = 0;
        int count = 0;
        for (GoodReceipt receipt : receipts) {
            if (receipt.getDateReception() != null && receipt.getDateCreation() != null) {
                totalMinutes += java.time.temporal.ChronoUnit.MINUTES.between(
                    receipt.getDateReception(), receipt.getDateCreation()
                );
                count++;
            }
        }
        
        long avgTimeMinutes = count > 0 ? Math.abs(totalMinutes) / count : 0;
        
        return KpiDTO.builder()
            .kpiName("Temps Dock-to-Stock")
            .value(avgTimeMinutes)
            .unit("minutes")
            .period("month")
            .trend("decreasing")
            .target(BigDecimal.valueOf(120))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // ==================== VENTES / RESPONSABLE COMMERCIAL ====================

    /**
     * Récupère tous les KPIs pour le Responsable Ventes
     */
    public Map<String, KpiDTO> getSalesKpis() {
        Map<String, KpiDTO> kpis = new LinkedHashMap<>();
        
        kpis.put("commandes_en_cours", getCommandesEnCours());
        kpis.put("commandes_livrees", getCommandesLivrees());
        kpis.put("commandes_en_retard", getCommandesEnRetard());
        kpis.put("taux_annulation_commandes", getTauxAnnulationCommandes());
        kpis.put("motifs_annulation", getMotifsAnnulation());
        kpis.put("remises_vs_plafond", getRemisesVsPlafond());
        kpis.put("avoirs_volume", getAvoirsVolume());
        kpis.put("avoirs_valeur", getAvoirsValeur());
        kpis.put("motifs_avoirs", getMotifsAvoirs());
        kpis.put("backlog_non_servi", getBacklogNonServi());
        
        return kpis;
    }

    // Ventes KPI: Commandes en Cours
    private KpiDTO getCommandesEnCours() {
        // TODO: Nombre de commandes de vente en cours (non livrées)
        List<SalesOrder> orders = salesOrderRepository.findByStatut("EN_COURS");
        
        return KpiDTO.builder()
            .kpiName("Commandes en Cours")
            .value(orders.size())
            .unit("commandes")
            .period("current")
            .trend("stable")
            .target(BigDecimal.valueOf(50))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Commandes Livrées
    private KpiDTO getCommandesLivrees() {
        // TODO: Nombre de commandes de vente livrées (ce mois)
        List<Delivery> deliveries = deliveryRepository.findByStatut("LIVREE");
        
        return KpiDTO.builder()
            .kpiName("Commandes Livrées")
            .value(deliveries.size())
            .unit("commandes")
            .period("month")
            .trend("increasing")
            .target(BigDecimal.valueOf(200))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Commandes en Retard
    private KpiDTO getCommandesEnRetard() {
        // TODO: Nombre de commandes dont la livraison est en retard
        // Basé sur les commandes non livrées depuis plus d'une semaine
        List<SalesOrder> orders = salesOrderRepository.findAll();
        
        long lateOrders = orders.stream()
            .filter(so -> so.getDateCreation() != null 
                    && so.getDateCreation().isBefore(LocalDateTime.now().minusWeeks(1))
                    && !"LIVREE".equals(so.getStatut()))
            .count();
        
        return KpiDTO.builder()
            .kpiName("Commandes en Retard")
            .value(lateOrders)
            .unit("commandes")
            .period("current")
            .trend("stable")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Taux Annulation Commandes
    private KpiDTO getTauxAnnulationCommandes() {
        // TODO: % de commandes annulées
        List<SalesOrder> orders = salesOrderRepository.findAll();
        
        long cancelledCount = orders.stream()
            .filter(so -> "ANNULEE".equals(so.getStatut()))
            .count();
        
        BigDecimal cancellationRate = orders.isEmpty() ? BigDecimal.ZERO 
            : new BigDecimal(cancelledCount * 100).divide(new BigDecimal(orders.size()), 2, RoundingMode.HALF_UP);
        
        return KpiDTO.builder()
            .kpiName("Taux Annulation Commandes")
            .value(cancellationRate)
            .unit("%")
            .period("month")
            .trend("decreasing")
            .target(new BigDecimal("5"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Motifs Annulation
    private KpiDTO getMotifsAnnulation() {
        // TODO: Distribution des motifs d'annulation
        return KpiDTO.builder()
            .kpiName("Motifs Annulation (Top)")
            .value("Déistockage")
            .unit("motif")
            .period("month")
            .trend("stable")
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Remises vs Plafond
    private KpiDTO getRemisesVsPlafond() {
        // TODO: Montant remises accordées vs plafond budgété
        BigDecimal discountsGiven = new BigDecimal("12500");
        BigDecimal discountCeilings = new BigDecimal("15000");
        BigDecimal percentageOfCeiling = discountsGiven.divide(discountCeilings, 2, RoundingMode.HALF_UP).multiply(new BigDecimal("100"));
        
        return KpiDTO.builder()
            .kpiName("Remises vs Plafond")
            .value(percentageOfCeiling)
            .unit("%")
            .period("month")
            .trend("stable")
            .target(new BigDecimal("80"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Avoirs - Volume
    private KpiDTO getAvoirsVolume() {
        // TODO: Nombre d'avoirs émis (ce mois)
        long avoirCount = invoiceRepository.findByTypeFacture("AVOIR").size();
        
        return KpiDTO.builder()
            .kpiName("Avoirs (Volume)")
            .value(avoirCount)
            .unit("avoirs")
            .period("month")
            .trend("stable")
            .target(BigDecimal.valueOf(10))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Avoirs - Valeur
    private KpiDTO getAvoirsValeur() {
        // TODO: Valeur totale des avoirs
        BigDecimal avoirValue = invoiceRepository.findByTypeFacture("AVOIR").stream()
            .map(Invoice::getMontantTtc)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return KpiDTO.builder()
            .kpiName("Avoirs (Valeur)")
            .value(avoirValue)
            .unit("€")
            .period("month")
            .trend("stable")
            .target(BigDecimal.valueOf(5000))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Motifs Avoirs
    private KpiDTO getMotifsAvoirs() {
        // TODO: Distribution des motifs d'avoirs (retour, erreur prix, casse, etc.)
        return KpiDTO.builder()
            .kpiName("Motifs Avoirs (Top)")
            .value("Retours clients")
            .unit("motif")
            .period("month")
            .trend("stable")
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Ventes KPI: Backlog Non Servi
    private KpiDTO getBacklogNonServi() {
        // TODO: Valeur et quantité de commandes non servies (stock insuffisant)
        BigDecimal backlogValue = BigDecimal.ZERO;
        
        // À implémenter selon structure de commandes en attente de stock
        
        return KpiDTO.builder()
            .kpiName("Backlog Non Servi")
            .value(backlogValue)
            .unit("€")
            .period("current")
            .trend("decreasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // ==================== FINANCE / DAF ====================

    /**
     * Récupère tous les KPIs pour le DAF
     */
    public Map<String, KpiDTO> getFinanceKpis() {
        Map<String, KpiDTO> kpis = new LinkedHashMap<>();
        
        kpis.put("factures_bloquees_3way", getFacturesBloquees3Way());
        kpis.put("valeur_stock_comptable", getValeurStockComptable());
        kpis.put("valeur_stock_operationnelle", getValeurStockOperationnelle());
        kpis.put("ecart_stock_comptable_operationnel", getEcartStockComptableOperationnel());
        kpis.put("variation_marge", getVariationMarge());
        kpis.put("tresorerie_position", getTresorerie());
        kpis.put("aged_receivables", getAgedReceivables());
        kpis.put("aged_payables", getAgedPayables());
        
        return kpis;
    }

    // Finance KPI: Factures Bloquées (3-way mismatch)
    private KpiDTO getFacturesBloquees3Way() {
        // TODO: Nombre et valeur de factures bloquées en rapprochement
        List<Invoice> invoices = invoiceRepository.findAll();
        
        BigDecimal blockedValue = invoices.stream()
            .filter(inv -> "LITIGE".equals(inv.getStatut()) || "EN_ATTENTE".equals(inv.getStatut()))
            .map(Invoice::getMontantTtc)
            .filter(Objects::nonNull)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return KpiDTO.builder()
            .kpiName("Factures Bloquées (3-way mismatch)")
            .value(blockedValue)
            .unit("€")
            .period("current")
            .trend("decreasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Valeur Stock Comptable
    private KpiDTO getValeurStockComptable() {
        // TODO: Valeur stock selon comptabilité
        BigDecimal stockComptable = new BigDecimal("4500000");
        
        return KpiDTO.builder()
            .kpiName("Valeur Stock Comptable")
            .value(stockComptable)
            .unit("€")
            .period("month")
            .trend("stable")
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Valeur Stock Opérationnelle
    private KpiDTO getValeurStockOperationnelle() {
        // TODO: Valeur stock selon système opérationnel
        List<StockLevel> stockLevels = stockLevelRepository.findAll();
        BigDecimal stockOperational = stockLevels.stream()
            .map(sl -> {
                if (sl.getArticle() != null && sl.getArticle().getPrixUnitaire() != null) {
                    return sl.getArticle().getPrixUnitaire()
                        .multiply(new BigDecimal(sl.getQuantiteDisponible()));
                }
                return BigDecimal.ZERO;
            })
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return KpiDTO.builder()
            .kpiName("Valeur Stock Opérationnelle")
            .value(stockOperational)
            .unit("€")
            .period("month")
            .trend("stable")
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Écart Stock Comptable vs Opérationnel
    private KpiDTO getEcartStockComptableOperationnel() {
        // TODO: Calculer l'écart entre les deux valuations
        BigDecimal gapPercentage = new BigDecimal("2.5");
        
        return KpiDTO.builder()
            .kpiName("Écart Stock Comptable/Opérationnel")
            .value(gapPercentage)
            .unit("%")
            .period("month")
            .trend("decreasing")
            .target(new BigDecimal("1"))
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Variation de Marge
    private KpiDTO getVariationMarge() {
        // TODO: Variation entre marge budgétée et réalisée
        BigDecimal marginVariance = new BigDecimal("3.8");
        
        return KpiDTO.builder()
            .kpiName("Variation Marge (Budgétée vs Réalisée)")
            .value(marginVariance)
            .unit("%")
            .period("month")
            .trend("stable")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Trésorerie Position
    private KpiDTO getTresorerie() {
        // TODO: Position de trésorerie actuelle
        BigDecimal cashPosition = new BigDecimal("250000");
        
        return KpiDTO.builder()
            .kpiName("Position Trésorerie")
            .value(cashPosition)
            .unit("€")
            .period("current")
            .trend("increasing")
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Aged Receivables
    private KpiDTO getAgedReceivables() {
        // TODO: Créances par tranche d'âge
        BigDecimal over90Days = new BigDecimal("45000");
        
        return KpiDTO.builder()
            .kpiName("Créances > 90 jours")
            .value(over90Days)
            .unit("€")
            .period("current")
            .trend("decreasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // Finance KPI: Aged Payables
    private KpiDTO getAgedPayables() {
        // TODO: Dettes par tranche d'âge
        BigDecimal over90Days = new BigDecimal("120000");
        
        return KpiDTO.builder()
            .kpiName("Dettes > 90 jours")
            .value(over90Days)
            .unit("€")
            .period("current")
            .trend("increasing")
            .target(BigDecimal.ZERO)
            .calculatedAt(LocalDateTime.now())
            .build();
    }

    // ==================== HELPER METHODS ====================

    /**
     * Détermine la tendance basée sur des données historiques
     * TODO: Implémenter la logique complète avec comparaison temporelle
     */
    private String getTrendFromHistorical(BigDecimal currentValue) {
        return "stable"; // TODO: Améliorer avec données historiques
    }

}
