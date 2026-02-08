package com.erp.controller;

import com.erp.domain.Customer;
import com.erp.domain.Invoice;
import com.erp.domain.PurchaseOrder;
import com.erp.domain.SalesOrder;
import com.erp.domain.Supplier;
import com.erp.repository.CustomerRepository;
import com.erp.repository.InvoiceRepository;
import com.erp.repository.PurchaseOrderRepository;
import com.erp.repository.SalesOrderRepository;
import com.erp.repository.StockLevelRepository;
import com.erp.repository.StockMovementRepository;
import com.erp.repository.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@SuppressWarnings("unchecked")
@RestController
@RequestMapping("/api")
public class DashboardApiController {

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private SalesOrderRepository salesOrderRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private SupplierRepository supplierRepository;

    @Autowired
    private CustomerRepository customerRepository;


    @Autowired
    private StockMovementRepository stockMovementRepository;

    @Autowired
    private StockLevelRepository stockLevelRepository;

    @GetMapping("/purchase-orders/metrics")
    public Map<String, Object> getPurchaseMetrics(@RequestParam(required = false) String from,
                                                  @RequestParam(required = false) String to,
                                                  @RequestParam(required = false) String status) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<PurchaseOrder> orders = filterPurchaseOrders(purchaseOrderRepository.findAll(), fromDate, toDate, status);

        BigDecimal total = sumOrders(orders);
        long pendingCount = countByStatus(orders, Arrays.asList("BROUILLON", "EN_COURS", "EN_ATTENTE", "DRAFT", "SUBMITTED"));

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("totalOrders", orders.size());
        metrics.put("totalSpend", total);
        metrics.put("pendingCount", pendingCount);
        metrics.put("avgDeliveryDays", averageDeliveryDays(orders));
        metrics.put("avgOrderValue", orders.isEmpty()
            ? BigDecimal.ZERO
            : total.divide(BigDecimal.valueOf(orders.size()), 2, RoundingMode.HALF_UP));
        return metrics;
    }

    @GetMapping("/purchase-orders")
    public List<Map<String, Object>> getPurchaseOrders(@RequestParam(required = false) Integer size,
                                                       @RequestParam(required = false) String from,
                                                       @RequestParam(required = false) String to,
                                                       @RequestParam(required = false) String status) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<PurchaseOrder> orders = filterPurchaseOrders(purchaseOrderRepository.findAll(), fromDate, toDate, status);
        orders.sort(Comparator.comparing(PurchaseOrder::getDateCreation,
            Comparator.nullsLast(Comparator.naturalOrder())).reversed());

        int limit = size != null ? Math.min(size, orders.size()) : orders.size();
        return orders.stream().limit(limit).map(this::toPurchaseOrderDto).collect(Collectors.toList());
    }

    @GetMapping("/sales-orders/metrics")
    public Map<String, Object> getSalesMetrics(@RequestParam(required = false) String from,
                                               @RequestParam(required = false) String to,
                                               @RequestParam(required = false) String status) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<SalesOrder> orders = filterSalesOrders(salesOrderRepository.findAll(), fromDate, toDate, status);

        BigDecimal totalRevenue = sumSalesOrders(orders);
        long pendingCount = countByStatus(orders, Arrays.asList("BROUILLON", "EN_COURS", "EN_ATTENTE", "DRAFT", "SUBMITTED"));

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("totalOrders", orders.size());
        metrics.put("totalRevenue", totalRevenue);
        metrics.put("pendingCount", pendingCount);
        metrics.put("avgDeliveryDays", 0);
        metrics.put("totalSales", totalRevenue);
        metrics.put("ordersCount", orders.size());
        metrics.put("pendingOrders", pendingCount);
        metrics.put("avgOrderValue", orders.isEmpty()
            ? BigDecimal.ZERO
            : totalRevenue.divide(BigDecimal.valueOf(orders.size()), 2, RoundingMode.HALF_UP));
        return metrics;
    }

    @GetMapping("/sales-orders")
    public List<Map<String, Object>> getSalesOrders(@RequestParam(required = false) Integer size,
                                                    @RequestParam(required = false) String from,
                                                    @RequestParam(required = false) String to,
                                                    @RequestParam(required = false) String status) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<SalesOrder> orders = filterSalesOrders(salesOrderRepository.findAll(), fromDate, toDate, status);
        orders.sort(Comparator.comparing(SalesOrder::getDateCreation,
            Comparator.nullsLast(Comparator.naturalOrder())).reversed());

        int limit = size != null ? Math.min(size, orders.size()) : orders.size();
        return orders.stream().limit(limit).map(this::toSalesOrderDto).collect(Collectors.toList());
    }

    @GetMapping("/invoices/metrics")
    public Map<String, Object> getInvoiceMetrics(@RequestParam(required = false) String from,
                                                 @RequestParam(required = false) String to,
                                                 @RequestParam(required = false) String status,
                                                 @RequestParam(required = false) String type) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<Invoice> invoices = filterInvoices(invoiceRepository.findAll(), fromDate, toDate, status, type);

        BigDecimal revenue = sumInvoicesByType(invoices, "VENTE");
        BigDecimal expenses = sumInvoicesByType(invoices, "ACHAT");
        BigDecimal outstanding = invoices.stream()
            .filter(inv -> inv.getStatut() == null || !(inv.getStatut().equalsIgnoreCase("PAID") || inv.getStatut().equalsIgnoreCase("PAYEE")))
            .map(inv -> inv.getMontantTtc() != null ? inv.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("totalRevenue", revenue);
        metrics.put("totalExpenses", expenses);
        metrics.put("profitMargin", revenue.compareTo(BigDecimal.ZERO) > 0
            ? revenue.subtract(expenses).multiply(BigDecimal.valueOf(100)).divide(revenue, 2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO);
        metrics.put("outstanding", outstanding);
        return metrics;
    }

    @GetMapping("/invoices")
    public List<Map<String, Object>> getInvoices(@RequestParam(required = false) Integer size,
                                                 @RequestParam(required = false) String from,
                                                 @RequestParam(required = false) String to,
                                                 @RequestParam(required = false) String status,
                                                 @RequestParam(required = false) String type) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<Invoice> invoices = filterInvoices(invoiceRepository.findAll(), fromDate, toDate, status, type);
        invoices.sort(Comparator.comparing(Invoice::getDateCreation,
            Comparator.nullsLast(Comparator.naturalOrder())).reversed());

        int limit = size != null ? Math.min(size, invoices.size()) : invoices.size();
        return invoices.stream().limit(limit).map(this::toInvoiceDto).collect(Collectors.toList());
    }

    @GetMapping("/kpis/{role}")
    public List<Map<String, Object>> getKpis(@PathVariable String role,
                                             @RequestParam(required = false) String from,
                                             @RequestParam(required = false) String to) {
        String normalizedRole = role == null ? "" : role.toUpperCase(Locale.ROOT);

        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);

        List<Invoice> filteredInvoices = filterInvoices(invoiceRepository.findAll(), fromDate, toDate, null, null);
        List<SalesOrder> filteredSales = filterSalesOrders(salesOrderRepository.findAll(), fromDate, toDate, null);
        List<PurchaseOrder> filteredPurchases = filterPurchaseOrders(purchaseOrderRepository.findAll(), fromDate, toDate, null);

        BigDecimal revenue = sumInvoicesByType(filteredInvoices, "VENTE");
        BigDecimal expenses = sumInvoicesByType(filteredInvoices, "ACHAT");
        BigDecimal profit = revenue.subtract(expenses);
        BigDecimal margin = revenue.compareTo(BigDecimal.ZERO) > 0
            ? profit.multiply(BigDecimal.valueOf(100)).divide(revenue, 2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO;

        List<Map<String, Object>> kpis = new ArrayList<>();

        if ("DIRECTION".equals(normalizedRole)) {
            kpis.add(kpi("revenue", "Chiffre d'affaires", revenue, "Ar", "UP", 12));
            kpis.add(kpi("expenses", "Depenses", expenses, "Ar", "DOWN", -3));
            kpis.add(kpi("profit", "Benefice net", profit, "Ar", "UP", 8));
            kpis.add(kpi("margin", "Marge beneficiaire", margin, "%", "UP", 2));
            return kpis;
        }

        kpis.add(kpi("orders", "Commandes en attente", countByStatus(filteredPurchases, Arrays.asList("BROUILLON", "EN_COURS", "EN_ATTENTE", "DRAFT", "SUBMITTED")), "commandes", "UP", 5));
        kpis.add(kpi("sales", "Ventes", sumSalesOrders(filteredSales), "Ar", "UP", 7));
        kpis.add(kpi("stock", "Articles en stock", stockCount(), "articles", "DOWN", -2));
        return kpis;
    }

    @GetMapping("/reports/performance")
    public List<Map<String, Object>> getPerformanceReport(@RequestParam(required = false) String from,
                                                          @RequestParam(required = false) String to) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime currentStart = parseDate(from, false);
        LocalDateTime currentEnd = parseDate(to, true);
        if (currentStart == null) {
            currentStart = now.minusDays(30);
        }
        if (currentEnd == null || currentEnd.isBefore(currentStart)) {
            currentEnd = now;
        }

        long days = java.time.Duration.between(currentStart, currentEnd).toDays();
        if (days <= 0) {
            days = 30;
        }
        LocalDateTime previousStart = currentStart.minusDays(days);
        LocalDateTime previousEnd = currentStart;

        List<SalesOrder> salesOrders = salesOrderRepository.findAll();
        List<PurchaseOrder> purchaseOrders = purchaseOrderRepository.findAll();
        List<Invoice> invoices = invoiceRepository.findAll();

        long salesCurrent = countByDate(salesOrders, currentStart, currentEnd);
        long salesPrevious = countByDate(salesOrders, previousStart, previousEnd);
        long purchasesCurrent = countByDate(purchaseOrders, currentStart, currentEnd);
        long purchasesPrevious = countByDate(purchaseOrders, previousStart, previousEnd);
        long invoicesCurrent = countByDate(invoices, currentStart, currentEnd);
        long invoicesPrevious = countByDate(invoices, previousStart, previousEnd);

        long customersCurrent = customerRepository.count();
        long suppliersCurrent = supplierRepository.count();

        List<Map<String, Object>> metrics = new ArrayList<>();
        metrics.add(metric("Commandes de vente", salesCurrent, salesPrevious));
        metrics.add(metric("Commandes d'achat", purchasesCurrent, purchasesPrevious));
        metrics.add(metric("Factures", invoicesCurrent, invoicesPrevious));
        metrics.add(metric("Clients", customersCurrent, customersCurrent));
        metrics.add(metric("Fournisseurs", suppliersCurrent, suppliersCurrent));
        return metrics;
    }

    @GetMapping("/charts/purchases")
    public Map<String, Object> getPurchaseCharts(@RequestParam(required = false) String from,
                                                 @RequestParam(required = false) String to,
                                                 @RequestParam(required = false) String status) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<PurchaseOrder> orders = filterPurchaseOrders(purchaseOrderRepository.findAll(), fromDate, toDate, status);

        Map<String, BigDecimal> bySupplier = new HashMap<>();
        for (PurchaseOrder order : orders) {
            String name = supplierName(order.getFournisseurId());
            if (name == null) {
                name = "Inconnu";
            }
            BigDecimal amount = order.getMontantTtc() != null ? order.getMontantTtc() : BigDecimal.ZERO;
            bySupplier.merge(name, amount, BigDecimal::add);
        }

        Map<String, Long> byStatus = orders.stream()
            .collect(Collectors.groupingBy(o -> o.getStatut() != null ? o.getStatut() : "INCONNU", Collectors.counting()));

        Map<String, Object> monthlySpending = buildMonthlySeries(aggregatePurchaseTotals(orders));

        Map<String, Object> data = new HashMap<>();
        data.put("bySupplier", toChartData(bySupplier, 6));
        data.put("byStatus", toChartData(byStatus));
        data.put("monthlySpending", monthlySpending);
        return data;
    }

    @GetMapping("/charts/sales")
    public Map<String, Object> getSalesCharts(@RequestParam(required = false) String from,
                                              @RequestParam(required = false) String to,
                                              @RequestParam(required = false) String status) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<SalesOrder> orders = filterSalesOrders(salesOrderRepository.findAll(), fromDate, toDate, status);

        Map<String, BigDecimal> byCustomer = new HashMap<>();
        for (SalesOrder order : orders) {
            String name = customerName(order.getClientId());
            if (name == null) {
                name = "Inconnu";
            }
            BigDecimal amount = order.getMontantTtc() != null ? order.getMontantTtc() : BigDecimal.ZERO;
            byCustomer.merge(name, amount, BigDecimal::add);
        }

        Map<String, Long> byStatus = orders.stream()
            .collect(Collectors.groupingBy(o -> o.getStatut() != null ? o.getStatut() : "INCONNU", Collectors.counting()));

        Map<String, Object> monthlyRevenue = buildMonthlySeries(aggregateSalesTotals(orders));

        Map<String, Object> data = new HashMap<>();
        data.put("byCustomer", toChartData(byCustomer, 6));
        data.put("byStatus", toChartData(byStatus));
        data.put("monthlyRevenue", monthlyRevenue);
        return data;
    }

    @GetMapping("/charts/finance")
    public Map<String, Object> getFinanceCharts(@RequestParam(required = false) String from,
                                                @RequestParam(required = false) String to,
                                                @RequestParam(required = false) String status,
                                                @RequestParam(required = false) String type) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<Invoice> invoices = filterInvoices(invoiceRepository.findAll(), fromDate, toDate, status, type);

        Map<YearMonth, BigDecimal> revenue = aggregateInvoiceTotals(invoices, "VENTE");
        Map<YearMonth, BigDecimal> expenses = aggregateInvoiceTotals(invoices, "ACHAT");

        Map<String, Object> revenueSeries = buildMonthlySeries(revenue);
        Map<String, Object> expenseSeries = buildMonthlySeries(expenses);

        List<String> labels = toStringList(revenueSeries.get("labels"));
        List<BigDecimal> revenueData = toBigDecimalList(revenueSeries.get("data"));
        List<BigDecimal> expenseData = toBigDecimalList(expenseSeries.get("data"));
        List<BigDecimal> cashFlow = new ArrayList<>();
        for (int i = 0; i < labels.size(); i++) {
            BigDecimal rev = i < revenueData.size() ? revenueData.get(i) : BigDecimal.ZERO;
            BigDecimal exp = i < expenseData.size() ? expenseData.get(i) : BigDecimal.ZERO;
            cashFlow.add(rev.subtract(exp));
        }

        Map<String, Long> statusCounts = invoices.stream()
            .collect(Collectors.groupingBy(inv -> inv.getStatut() != null ? inv.getStatut() : "INCONNU", Collectors.counting()));

        Map<String, Object> data = new HashMap<>();
        data.put("revenue", revenueSeries);
        data.put("expenses", expenseSeries);
        data.put("cashFlow", toChartData(labels, cashFlow));
        data.put("paymentStatus", toChartData(statusCounts));
        return data;
    }

    @GetMapping("/charts/executive")
    public Map<String, Object> getExecutiveCharts(@RequestParam(required = false) String from,
                                                  @RequestParam(required = false) String to) {
        LocalDateTime fromDate = parseDate(from, false);
        LocalDateTime toDate = parseDate(to, true);
        List<Invoice> invoices = filterInvoices(invoiceRepository.findAll(), fromDate, toDate, null, null);
        List<SalesOrder> salesOrders = filterSalesOrders(salesOrderRepository.findAll(), fromDate, toDate, null);
        List<PurchaseOrder> purchaseOrders = filterPurchaseOrders(purchaseOrderRepository.findAll(), fromDate, toDate, null);

        Map<String, Object> revenueSeries = buildMonthlySeries(aggregateInvoiceTotals(invoices, "VENTE"));
        Map<String, Object> expenseSeries = buildMonthlySeries(aggregateInvoiceTotals(invoices, "ACHAT"));

        Map<String, Object> salesSeries = buildMonthlySeries(aggregateSalesTotals(salesOrders));
        Map<String, Object> purchaseSeries = buildMonthlySeries(aggregatePurchaseTotals(purchaseOrders));

        long clients = customerRepository.count();
        long suppliers = supplierRepository.count();
        long articles = stockLevelRepository.count();
        long deliveries = stockMovementRepository.count();
        long orders = salesOrders.size();

        List<String> perfLabels = Arrays.asList("Clients", "Fournisseurs", "Articles", "Commandes", "Mouvements");
        List<Long> perfRaw = Arrays.asList(clients, suppliers, articles, orders, deliveries);
        long max = perfRaw.stream().max(Long::compareTo).orElse(1L);
        List<BigDecimal> perfData = perfRaw.stream()
            .map(v -> BigDecimal.valueOf(max == 0 ? 0 : (v * 100.0 / max)))
            .collect(Collectors.toList());

        Map<String, Object> data = new HashMap<>();
        data.put("revenue", revenueSeries);
        data.put("expenses", expenseSeries);
        data.put("sales", salesSeries);
        data.put("purchases", purchaseSeries);
        data.put("performance", toChartData(perfLabels, perfData));
        return data;
    }

    private LocalDateTime parseDate(String value, boolean endOfDay) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            LocalDate date = LocalDate.parse(value.trim());
            return endOfDay ? date.atTime(23, 59, 59) : date.atStartOfDay();
        } catch (Exception e) {
            return null;
        }
    }

    private boolean within(LocalDateTime date, LocalDateTime from, LocalDateTime to) {
        if (date == null) return false;
        if (from != null && date.isBefore(from)) return false;
        if (to != null && date.isAfter(to)) return false;
        return true;
    }

    private boolean statusMatches(String currentStatus, String statusParam) {
        if (statusParam == null || statusParam.trim().isEmpty()) {
            return true;
        }
        if (currentStatus == null) return false;
        String[] parts = statusParam.split(",");
        for (String part : parts) {
            String normalized = part != null ? part.trim().toUpperCase(Locale.ROOT) : "";
            if (!normalized.isEmpty() && currentStatus.toUpperCase(Locale.ROOT).equals(normalized)) {
                return true;
            }
        }
        return false;
    }

    private boolean typeMatches(String currentType, String typeParam) {
        if (typeParam == null || typeParam.trim().isEmpty()) {
            return true;
        }
        if (currentType == null) return false;
        String[] parts = typeParam.split(",");
        for (String part : parts) {
            String normalized = part != null ? part.trim().toUpperCase(Locale.ROOT) : "";
            if (!normalized.isEmpty() && currentType.toUpperCase(Locale.ROOT).equals(normalized)) {
                return true;
            }
        }
        return false;
    }

    private List<PurchaseOrder> filterPurchaseOrders(List<PurchaseOrder> orders,
                                                     LocalDateTime from,
                                                     LocalDateTime to,
                                                     String status) {
        if (orders == null) return Collections.emptyList();
        return orders.stream()
            .filter(o -> {
                LocalDateTime date = o.getDateCommande() != null ? o.getDateCommande() : o.getDateCreation();
                if ((from != null || to != null) && !within(date, from, to)) return false;
                return statusMatches(o.getStatut(), status);
            })
            .collect(Collectors.toList());
    }

    private List<SalesOrder> filterSalesOrders(List<SalesOrder> orders,
                                               LocalDateTime from,
                                               LocalDateTime to,
                                               String status) {
        if (orders == null) return Collections.emptyList();
        return orders.stream()
            .filter(o -> {
                LocalDateTime date = o.getDateCommande() != null ? o.getDateCommande() : o.getDateCreation();
                if ((from != null || to != null) && !within(date, from, to)) return false;
                return statusMatches(o.getStatut(), status);
            })
            .collect(Collectors.toList());
    }

    private List<Invoice> filterInvoices(List<Invoice> invoices,
                                         LocalDateTime from,
                                         LocalDateTime to,
                                         String status,
                                         String type) {
        if (invoices == null) return Collections.emptyList();
        return invoices.stream()
            .filter(inv -> {
                LocalDateTime date = inv.getDateFacture() != null ? inv.getDateFacture() : inv.getDateCreation();
                if ((from != null || to != null) && !within(date, from, to)) return false;
                if (!statusMatches(inv.getStatut(), status)) return false;
                return typeMatches(inv.getTypeFacture(), type);
            })
            .collect(Collectors.toList());
    }

    private Map<String, Object> kpi(String id, String libelle, Object value, String unit, String trend, int variance) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", id);
        map.put("libelle", libelle);
        map.put("value", value);
        map.put("unit", unit);
        map.put("trend", trend);
        map.put("variance", variance);
        map.put("target", null);
        return map;
    }

    private BigDecimal sumOrders(List<PurchaseOrder> orders) {
        return orders.stream()
            .map(order -> order.getMontantTtc() != null ? order.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal sumSalesOrders(List<SalesOrder> orders) {
        return orders.stream()
            .map(order -> order.getMontantTtc() != null ? order.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal sumInvoices(List<Invoice> invoices) {
        return invoices.stream()
            .map(inv -> inv.getMontantTtc() != null ? inv.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal sumInvoicesByType(List<Invoice> invoices, String type) {
        if (invoices == null) return BigDecimal.ZERO;
        return invoices.stream()
            .filter(inv -> inv.getTypeFacture() != null && type != null && inv.getTypeFacture().equalsIgnoreCase(type))
            .map(inv -> inv.getMontantTtc() != null ? inv.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private long countByStatus(List<?> items, List<String> statuses) {
        if (items == null || statuses == null || statuses.isEmpty()) {
            return 0;
        }
        Set<String> normalized = statuses.stream()
            .filter(Objects::nonNull)
            .map(s -> s.toUpperCase(Locale.ROOT))
            .collect(Collectors.toSet());
        return items.stream()
            .filter(item -> {
                if (item instanceof PurchaseOrder) {
                    String status = ((PurchaseOrder) item).getStatut();
                    return status != null && normalized.contains(status.toUpperCase(Locale.ROOT));
                }
                if (item instanceof SalesOrder) {
                    String status = ((SalesOrder) item).getStatut();
                    return status != null && normalized.contains(status.toUpperCase(Locale.ROOT));
                }
                return false;
            })
            .count();
    }

    private long averageDeliveryDays(List<PurchaseOrder> orders) {
        List<Long> diffs = orders.stream()
            .map(order -> diffDays(order.getDateCommande(), order.getDateEcheanceEstimee()))
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
        if (diffs.isEmpty()) return 0;
        long sum = diffs.stream().mapToLong(Long::longValue).sum();
        return sum / diffs.size();
    }

    private Long diffDays(LocalDateTime start, LocalDateTime end) {
        if (start == null || end == null) return null;
        return ChronoUnit.DAYS.between(start, end);
    }

    private Map<String, Object> toPurchaseOrderDto(PurchaseOrder order) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", order.getId());
        map.put("numero", order.getNumero());
        map.put("fournisseurLibelle", supplierName(order.getFournisseurId()));
        map.put("montantTotal", order.getMontantTtc());
        map.put("dateExpectedDelivery", order.getDateEcheanceEstimee());
        map.put("statut", order.getStatut());
        return map;
    }

    private Map<String, Object> toSalesOrderDto(SalesOrder order) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", order.getId());
        map.put("numero", order.getNumero());
        map.put("clientLibelle", customerName(order.getClientId()));
        map.put("montantTotal", order.getMontantTtc());
        map.put("dateLivraison", order.getDateCommande());
        map.put("statut", order.getStatut());
        return map;
    }

    private Map<String, Object> toInvoiceDto(Invoice inv) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", inv.getId());
        map.put("numero", inv.getNumero());
        map.put("clientLibelle", resolveInvoiceTiers(inv));
        map.put("montantTotal", inv.getMontantTtc());
        map.put("dateLimite", inv.getDateEcheance());
        map.put("statut", inv.getStatut());
        return map;
    }

    private long stockCount() {
        return stockLevelRepository.count();
    }

    private String supplierName(Long id) {
        if (id == null) return "-";
        Optional<Supplier> supplier = supplierRepository.findById(id);
        return supplier.map(Supplier::getNomEntreprise).orElse("ID " + id);
    }

    private String customerName(Long id) {
        if (id == null) return "-";
        Optional<Customer> customer = customerRepository.findById(id);
        return customer.map(Customer::getNomEntreprise).orElse("ID " + id);
    }

    private String resolveInvoiceTiers(Invoice inv) {
        if (inv == null || inv.getTiersId() == null) return "-";
        if ("CLIENT".equalsIgnoreCase(inv.getTypeTiers())) {
            return customerName(inv.getTiersId());
        }
        if ("FOURNISSEUR".equalsIgnoreCase(inv.getTypeTiers())) {
            return supplierName(inv.getTiersId());
        }
        return "ID " + inv.getTiersId();
    }

    private Map<String, Object> toChartData(Map<String, Long> data) {
        List<String> labels = new ArrayList<>(data.keySet());
        List<Long> values = labels.stream().map(data::get).collect(Collectors.toList());
        return toChartData(labels, values);
    }

    private Map<String, Object> toChartData(Map<String, BigDecimal> data, int limit) {
        List<Map.Entry<String, BigDecimal>> sorted = data.entrySet().stream()
            .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
            .limit(limit)
            .collect(Collectors.toList());
        List<String> labels = sorted.stream().map(Map.Entry::getKey).collect(Collectors.toList());
        List<BigDecimal> values = sorted.stream().map(Map.Entry::getValue).collect(Collectors.toList());
        return toChartData(labels, values);
    }

    private Map<String, Object> toChartData(List<String> labels, List<? extends Number> values) {
        Map<String, Object> chart = new HashMap<>();
        chart.put("labels", labels);
        chart.put("data", values);
        return chart;
    }

    private List<String> toStringList(Object raw) {
        if (!(raw instanceof List<?>)) return Collections.emptyList();
        List<?> list = (List<?>) raw;
        List<String> out = new ArrayList<>();
        for (Object item : list) {
            if (item != null) {
                out.add(String.valueOf(item));
            }
        }
        return out;
    }

    private List<BigDecimal> toBigDecimalList(Object raw) {
        if (!(raw instanceof List<?>)) return Collections.emptyList();
        List<?> list = (List<?>) raw;
        List<BigDecimal> out = new ArrayList<>();
        for (Object item : list) {
            out.add(toBigDecimal(item));
        }
        return out;
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value == null) return BigDecimal.ZERO;
        if (value instanceof BigDecimal) return (BigDecimal) value;
        if (value instanceof Number) return BigDecimal.valueOf(((Number) value).doubleValue());
        try {
            return new BigDecimal(value.toString());
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private Map<YearMonth, BigDecimal> aggregatePurchaseTotals(List<PurchaseOrder> orders) {
        Map<YearMonth, BigDecimal> totals = new HashMap<>();
        for (PurchaseOrder order : orders) {
            LocalDateTime date = order.getDateCommande() != null ? order.getDateCommande() : order.getDateCreation();
            if (date == null) continue;
            YearMonth ym = YearMonth.from(date);
            BigDecimal amount = order.getMontantTtc() != null ? order.getMontantTtc() : BigDecimal.ZERO;
            totals.merge(ym, amount, BigDecimal::add);
        }
        return totals;
    }

    private Map<YearMonth, BigDecimal> aggregateSalesTotals(List<SalesOrder> orders) {
        Map<YearMonth, BigDecimal> totals = new HashMap<>();
        for (SalesOrder order : orders) {
            LocalDateTime date = order.getDateCommande() != null ? order.getDateCommande() : order.getDateCreation();
            if (date == null) continue;
            YearMonth ym = YearMonth.from(date);
            BigDecimal amount = order.getMontantTtc() != null ? order.getMontantTtc() : BigDecimal.ZERO;
            totals.merge(ym, amount, BigDecimal::add);
        }
        return totals;
    }

    private Map<YearMonth, BigDecimal> aggregateInvoiceTotals(List<Invoice> invoices, String type) {
        Map<YearMonth, BigDecimal> totals = new HashMap<>();
        for (Invoice inv : invoices) {
            if (type != null && inv.getTypeFacture() != null && !type.equalsIgnoreCase(inv.getTypeFacture())) {
                continue;
            }
            LocalDateTime date = inv.getDateFacture() != null ? inv.getDateFacture() : inv.getDateCreation();
            if (date == null) continue;
            YearMonth ym = YearMonth.from(date);
            BigDecimal amount = inv.getMontantTtc() != null ? inv.getMontantTtc() : BigDecimal.ZERO;
            totals.merge(ym, amount, BigDecimal::add);
        }
        return totals;
    }

    private Map<String, Object> buildMonthlySeries(Map<YearMonth, BigDecimal> totals) {
        List<YearMonth> months = lastMonths(6);
        List<String> labels = months.stream().map(YearMonth::toString).collect(Collectors.toList());
        List<BigDecimal> data = months.stream()
            .map(m -> totals.getOrDefault(m, BigDecimal.ZERO))
            .collect(Collectors.toList());
        return toChartData(labels, data);
    }

    private List<YearMonth> lastMonths(int count) {
        YearMonth current = YearMonth.now();
        List<YearMonth> months = new ArrayList<>();
        for (int i = count - 1; i >= 0; i--) {
            months.add(current.minusMonths(i));
        }
        return months;
    }

    private long countByDate(List<?> items, LocalDateTime start, LocalDateTime end) {
        return items.stream().filter(item -> {
            LocalDateTime date = null;
            if (item instanceof SalesOrder) {
                date = ((SalesOrder) item).getDateCreation();
            } else if (item instanceof PurchaseOrder) {
                date = ((PurchaseOrder) item).getDateCreation();
            } else if (item instanceof Invoice) {
                date = ((Invoice) item).getDateCreation();
            }
            if (date == null) return false;
            return (date.isEqual(start) || date.isAfter(start)) && date.isBefore(end);
        }).count();
    }

    private Map<String, Object> metric(String name, long current, long previous) {
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("current", current);
        map.put("previous", previous);
        return map;
    }
}
