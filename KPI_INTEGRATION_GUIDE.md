# KPI Integration - Complete Implementation Guide

## Overview
This document describes the integration of comprehensive KPI (Key Performance Indicators) functionality across all departments/roles in the ERP system.

## Architecture Overview

### New Components Created

#### 1. **KpiService** (Service Layer)
**Location**: `src/main/java/com/erp/service/KpiService.java`

**Purpose**: Centralized service that calculates and provides all KPIs for each role.

**Responsibilities**:
- Aggregates data from repositories and other services
- Calculates KPI values based on business logic
- Provides KPIs grouped by role

**Key Methods**:
```java
// Direction Générale / Comité de Direction KPIs
Map<String, KpiDTO> getDirectionKpis()

// Responsable Achats / Supply Chain KPIs
Map<String, KpiDTO> getPurchaseKpis()

// Magasin / Responsable Stock KPIs
Map<String, KpiDTO> getWarehouseKpis()

// Ventes / Responsable Commercial KPIs
Map<String, KpiDTO> getSalesKpis()

// Finance / DAF KPIs
Map<String, KpiDTO> getFinanceKpis()
```

**KPIs by Role**:

##### Direction Générale / Comité de Direction (10 KPIs)
- `ca_total` - Chiffre d'Affaires Total (€)
- `marge_brute` - Marge Brute (€)
- `marge_pourcentage` - Marge % (%)
- `stock_value_total` - Valeur Stock Total (€)
- `stock_evolution_m1` - Évolution Stock M-1 (%)
- `stock_evolution_m12` - Évolution Stock M-12 (%)
- `stock_turnover` - Rotation Stock/Turnover (fois/an)
- `top_surstocks` - Top 5 Surstocks/Obsolescence (€)
- `taux_ecarts_inventaire_valeur` - Écarts Inventaire (Valeur) (€)
- `taux_ecarts_inventaire_pourcentage` - Écarts Inventaire (%) (%)

##### Responsable Achats / Supply Chain (8 KPIs)
- `cycle_time_da_bc_median` - Cycle Time DA→BC Médiane (jours)
- `cycle_time_da_bc_p90` - Cycle Time DA→BC P90 (jours)
- `otd_supplier` - OTD Fournisseurs (%)
- `reception_conform` - Taux Réception Conforme (%)
- `taux_litiges_facture` - Taux Litiges Facture/3-way (%)
- `concentration_fournisseurs` - Concentration Fournisseurs Top 3 (%)
- `evolution_prix_achat` - Évolution Prix d'Achat (Index) (%)
- `taux_commandes_urgentes` - Taux Commandes Urgentes (%)

##### Magasin / Responsable Stock (6 KPIs)
- `precision_stock_theorique_physique` - Taux Précision Stock (%)
- `obsolescence_peremption_valeur` - Obsolescence/Péremption (€)
- `lots_risque` - Lots à Risque (nombre)
- `productivite_picking` - Productivité Picking (lignes/heure)
- `erreurs_picking` - Taux Erreurs Picking (%)
- `temps_dock_to_stock` - Temps Dock-to-Stock (minutes)

##### Ventes / Responsable Commercial (10 KPIs)
- `commandes_en_cours` - Commandes en Cours (nombre)
- `commandes_livrees` - Commandes Livrées (nombre)
- `commandes_en_retard` - Commandes en Retard (nombre)
- `taux_annulation_commandes` - Taux Annulation (%)
- `motifs_annulation` - Motifs Annulation (texte)
- `remises_vs_plafond` - Remises vs Plafond (%)
- `avoirs_volume` - Avoirs Volume (nombre)
- `avoirs_valeur` - Avoirs Valeur (€)
- `motifs_avoirs` - Motifs Avoirs (texte)
- `backlog_non_servi` - Backlog Non Servi (€)

##### Finance / DAF (8 KPIs)
- `factures_bloquees_3way` - Factures Bloquées 3-way (€)
- `valeur_stock_comptable` - Valeur Stock Comptable (€)
- `valeur_stock_operationnelle` - Valeur Stock Opérationnelle (€)
- `ecart_stock_comptable_operationnel` - Écart Stock (%)
- `variation_marge` - Variation Marge (%)
- `tresorerie_position` - Position Trésorerie (€)
- `aged_receivables` - Créances > 90 jours (€)
- `aged_payables` - Dettes > 90 jours (€)

---

#### 2. **RoleBasedKpiManager** (Service Layer)
**Location**: `src/main/java/com/erp/service/RoleBasedKpiManager.java`

**Purpose**: Manages role-based access control and filtering of KPIs.

**Responsibilities**:
- Filters KPIs based on user role
- Provides role-specific KPI containers
- Validates user access to KPIs
- Aggregates KPI statistics

**Key Methods**:
```java
// Get all KPIs for user based on role
RoleKpiContainerDTO getKpisForUser(User user)

// Check if user has access to specific KPI
boolean userHasAccessToKpi(User user, String kpiCode)

// Get all available KPIs (all roles)
Map<String, KpiDTO> getAllAvailableKpis()
```

**Role Mapping**:
- `DIRECTION` - Full direction KPIs
- `ACHETEUR` / `SUPPLY_CHAIN` - Purchase KPIs
- `MAGASINIER` / `RESPONSABLE_STOCK` - Warehouse KPIs
- `COMMERCIAL` / `RESPONSABLE_VENTES` - Sales KPIs
- `FINANCE` / `DAF` - Finance KPIs
- `ADMIN` - All KPIs (unrestricted access)

---

#### 3. **KpiController** (API Layer)
**Location**: `src/main/java/com/erp/controller/KpiController.java`

**Purpose**: REST API endpoints for accessing KPI data.

**Endpoints**:
```
GET  /api/kpis/user              - KPIs for current user (role-based)
GET  /api/kpis/direction         - All Direction KPIs
GET  /api/kpis/achats            - All Purchase KPIs
GET  /api/kpis/stock             - All Warehouse KPIs
GET  /api/kpis/ventes            - All Sales KPIs
GET  /api/kpis/finance           - All Finance KPIs
GET  /api/kpis/{kpiCode}         - Specific KPI by code
GET  /api/kpis                   - All available KPIs
GET  /api/kpis/stats/global      - Global KPI statistics
```

---

#### 4. **RoleKpiContainerDTO** (DTO Layer)
**Location**: `src/main/java/com/erp/dto/RoleKpiContainerDTO.java`

**Purpose**: Wraps user KPIs with metadata and statistics.

**Fields**:
```java
String roleCode              // Role identifier
String roleLabel             // Role display name
String userName              // Current user login
Long userId                  // User ID
Map<String, KpiDTO> kpis     // Map of KPI code → KpiDTO
long kpiCount                // Number of KPIs
String period                // Reporting period
String generatedAt           // Generation timestamp
int kpisOnTarget             // KPIs meeting targets
int kpisAtRisk               // KPIs at risk
int kpisInAlert              // KPIs in alert status
```

---

### Modified Components

#### 1. **DashboardController**
**Location**: `src/main/java/com/erp/controller/DashboardController.java`

**Changes**:
- Added `@Autowired private KpiService kpiService;`
- Added `@Autowired private RoleBasedKpiManager roleBasedKpiManager;`
- Updated `/dashboard/direction` to use KpiService
- Updated `/dashboard/achats` to use KpiService
- Updated `/dashboard/stocks` to use KpiService
- Updated `/dashboard/ventes` to use KpiService
- Updated `/dashboard/finance` to use KpiService

**Backward Compatibility**: All existing methods are preserved; KPIs are added as additional attributes.

**Example**:
```java
@GetMapping("/direction")
public String directionDashboard(Model model, HttpSession session, Authentication auth) {
    // ... existing authentication ...
    
    // New: Fetch KPIs from service
    Map<String, KpiDTO> directionKpis = kpiService.getDirectionKpis();
    model.addAttribute("kpis", directionKpis);
    model.addAttribute("kpiCount", directionKpis.size());
    
    // ... backward compatible attributes ...
    return "dashboard-direction";
}
```

---

#### 2. **InvoiceRepository**
**Location**: `src/main/java/com/erp/repository/InvoiceRepository.java`

**New Methods**:
```java
List<Invoice> findByType(String type);
List<Invoice> findByDateFactureBetween(LocalDateTime startDate, LocalDateTime endDate);
```

---

## Integration Points

### Database Queries
The KpiService uses the following repositories:
- `PurchaseOrderRepository`
- `PurchaseRequestRepository`
- `SalesOrderRepository`
- `DeliveryRepository`
- `InvoiceRepository`
- `StockLevelRepository`
- `StockMovementRepository`
- `SupplierRepository`
- `ArticleRepository`
- `PaymentRepository`
- `GoodReceiptRepository`
- `CustomerRepository`

### Service Dependencies
The KpiService depends on:
- `ArticleService`
- `InventoryService`

---

## UI Integration

### JSP Pages (Existing)
The following JSP pages receive additional KPI data via Model attributes:
- `src/main/webapp/WEB-INF/jsp/dashboard-direction.jsp` - Direction KPIs
- `src/main/webapp/WEB-INF/jsp/dashboard-acheteur.jsp` - Purchase KPIs
- `src/main/webapp/WEB-INF/jsp/dashboard-magasinier.jsp` - Warehouse KPIs
- `src/main/webapp/WEB-INF/jsp/dashboard-commercial.jsp` - Sales KPIs
- `src/main/webapp/WEB-INF/jsp/dashboard-finance.jsp` - Finance KPIs

### Model Attributes Passed
```java
// For all role dashboards:
model.addAttribute("kpis", Map<String, KpiDTO>);  // All role KPIs
model.addAttribute("kpiCount", Long);              // Number of KPIs
model.addAttribute("roleBasedMessage", String);    // Role description

// Plus role-specific backward-compatible attributes (unchanged)
```

### Example JSP Template Code
```jsp
<!-- Display all KPIs for the role -->
<c:forEach items="${kpis}" var="kpiEntry">
    <div class="kpi-card">
        <h4>${kpiEntry.value.kpiName}</h4>
        <div class="kpi-value">${kpiEntry.value.value} ${kpiEntry.value.unit}</div>
        <div class="kpi-trend ${kpiEntry.value.trend}">${kpiEntry.value.trend}</div>
        <div class="kpi-target">Target: ${kpiEntry.value.target}</div>
    </div>
</c:forEach>
```

---

## Security Model

### Role-Based Access Control
The system implements RBAC at multiple levels:

1. **Controller Level**: Authentication required via Spring Security
2. **Service Level**: `RoleBasedKpiManager` checks role permissions
3. **API Level**: `/api/kpis/{kpiCode}` validates access before returning data

### User Role Hierarchy
```
ADMIN (unrestricted access)
├── DIRECTION / COMITE_DIRECTION
├── ACHETEUR / SUPPLY_CHAIN
├── MAGASINIER / RESPONSABLE_STOCK
├── COMMERCIAL / RESPONSABLE_VENTES
└── FINANCE / DAF
```

---

## Implementation Details

### KPI Calculation Strategy

Each KPI calculation follows this pattern:
1. **Data Aggregation**: Fetch relevant data from repositories
2. **Processing**: Apply business logic and formulas
3. **Normalization**: Format values with units and trends
4. **Packaging**: Wrap in KpiDTO for consumption

### Example: Cycle Time Calculation
```java
private KpiDTO getCycleTimeDABCMedian() {
    List<PurchaseOrder> pos = purchaseOrderRepository.findAll();
    
    List<Long> cycleTimes = pos.stream()
        .filter(po -> po.getDateCreation() != null && po.getDateCommande() != null)
        .map(po -> java.time.temporal.ChronoUnit.DAYS.between(
            po.getDateCreation(), po.getDateCommande()))
        .sorted()
        .collect(Collectors.toList());
    
    Long medianCycleTime = cycleTimes.isEmpty() ? 0 : 
        cycleTimes.get(cycleTimes.size() / 2);
    
    return KpiDTO.builder()
        .kpiName("Cycle Time DA→BC (Médiane)")
        .value(medianCycleTime)
        .unit("jours")
        .trend("stable")
        .target(BigDecimal.valueOf(14))
        .calculatedAt(LocalDateTime.now())
        .build();
}
```

---

## TODO Items & Future Enhancements

### High Priority
- [ ] **Period Filtering**: Add support for date range filters (jour, semaine, mois, année)
- [ ] **KPI Caching**: Implement Redis caching with TTL for performance
- [ ] **Trend Analysis**: Calculate actual trends based on historical data vs hardcoded values
- [ ] **Row-Level Security**: Implement granular security per site/warehouse

### Medium Priority
- [ ] **Multi-Site Support**: Filter KPIs by site/warehouse for distributed operations
- [ ] **Custom Thresholds**: Allow admins to configure KPI targets per role
- [ ] **Alerts & Notifications**: Trigger alerts when KPIs exceed thresholds
- [ ] **Export Functionality**: CSV/Excel/PDF export for reports

### Lower Priority
- [ ] **KPI Forecasting**: ML-based trend prediction
- [ ] **Benchmarking**: Compare KPIs against industry standards
- [ ] **Dashboard Customization**: Allow users to personalize KPI display
- [ ] **Mobile App Integration**: Expose KPIs via mobile API

---

## Testing Recommendations

### Unit Tests
```java
@SpringBootTest
public class KpiServiceTest {
    
    @Test
    public void testDirectionKpisCalculation() {
        // Test that all direction KPIs are generated
    }
    
    @Test
    public void testKpiRoleBasedFiltering() {
        // Test that only appropriate KPIs are returned per role
    }
}
```

### Integration Tests
```java
@SpringBootTest
public class KpiControllerIntegrationTest {
    
    @Test
    public void testKpiEndpoints() {
        // Test all API endpoints
    }
}
```

---

## Performance Considerations

### Current Approach
- Direct queries for each KPI calculation
- No caching (recalculated on each request)
- Good for late-binding data accuracy

### Recommended Optimizations
1. **Caching**: Cache KPI results with 5-15 minute TTL
2. **Batch Queries**: Use SQL JOIN queries instead of stream processing
3. **Materialized Views**: Create database views for complex calculations
4. **Async Processing**: Calculate KPIs in background jobs

---

## Troubleshooting

### Issue: NullPointerException in KPI calculation
**Solution**: Verify that all required repositories are properly injected and that database contains test data.

### Issue: KPIs returning incomplete data
**Solution**: Check that all `findBy*` repository methods are implemented correctly.

### Issue: User not seeing expected KPIs
**Solution**: Verify role assignment in database (`habilitations_utilisateur` table).

---

## Code Quality Notes

### Completed
✅ No breaking changes to existing code
✅ All new classes properly annotated with Spring annotations
✅ DTOs use Lombok for boilerplate reduction
✅ Clear separation of concerns (Service → DTO → Controller)

### Areas for Improvement
- [ ] Add JavaDoc comments to all public methods
- [ ] Add unit tests for KPI calculations
- [ ] Add logging for KPI generation
- [ ] Add exception handling for repository failures

---

## Deployment Checklist

- [ ] Run `mvn clean compile` to verify no compilation errors
- [ ] Run `mvn clean test` to run all tests
- [ ] Verify database contains necessary tables
- [ ] Test each dashboard endpoint in development
- [ ] Verify KPI API endpoints work correctly
- [ ] Check logs for any exceptions
- [ ] Deploy to production with monitoring enabled

---

## Support & Documentation

For questions or issues regarding KPI implementation:
1. Check the TODO comments in KpiService.java for pending enhancements
2. Review the endpoint documentation in KpiController.java
3. Check the role mapping in RoleBasedKpiManager.java
4. Run tests to verify functionality

