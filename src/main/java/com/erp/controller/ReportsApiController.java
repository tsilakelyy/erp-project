package com.erp.controller;

import com.erp.domain.Invoice;
import com.erp.domain.PurchaseOrder;
import com.erp.domain.PurchaseRequest;
import com.erp.domain.Proforma;
import com.erp.domain.GoodReceipt;
import com.erp.domain.Delivery;
import com.erp.domain.SalesOrder;
import com.erp.domain.ClientRequest;
import com.erp.domain.Payment;
import com.erp.domain.SalesProforma;
import com.erp.domain.StockLevel;
import com.erp.domain.Article;
import com.erp.domain.Warehouse;
import com.erp.repository.InvoiceRepository;
import com.erp.repository.PurchaseOrderRepository;
import com.erp.repository.PurchaseRequestRepository;
import com.erp.repository.ProformaRepository;
import com.erp.repository.GoodReceiptRepository;
import com.erp.repository.DeliveryRepository;
import com.erp.repository.SalesOrderRepository;
import com.erp.repository.StockLevelRepository;
import com.erp.repository.SupplierRepository;
import com.erp.repository.CustomerRepository;
import com.erp.repository.ClientRequestRepository;
import com.erp.repository.PaymentRepository;
import com.erp.repository.SalesProformaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@SuppressWarnings("deprecation")
@RestController
@RequestMapping("/api/reports")
public class ReportsApiController {

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private PurchaseRequestRepository purchaseRequestRepository;

    @Autowired
    private ProformaRepository proformaRepository;

    @Autowired
    private GoodReceiptRepository goodReceiptRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Autowired
    private SalesOrderRepository salesOrderRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private ClientRequestRepository clientRequestRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private SalesProformaRepository salesProformaRepository;

    @Autowired
    private StockLevelRepository stockLevelRepository;

    @Autowired
    private SupplierRepository supplierRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @GetMapping("/validations")
    public Map<String, Object> getValidationReport(
        @RequestParam(required = false) String status,
        @RequestParam(required = false) String importance,
        @RequestParam(required = false) String mode,
        @RequestParam(required = false) String from,
        @RequestParam(required = false) String to
    ) {
        LocalDate fromDate = parseDate(from);
        LocalDate toDate = parseDate(to);

        List<PurchaseRequest> requests = purchaseRequestRepository.findAll();
        Map<Long, PurchaseRequest> requestById = requests.stream()
            .collect(Collectors.toMap(PurchaseRequest::getId, r -> r));

        List<Proforma> proformas = proformaRepository.findAll();
        List<PurchaseOrder> orders = purchaseOrderRepository.findAll();
        Map<Long, List<PurchaseOrder>> ordersByProforma = orders.stream()
            .filter(o -> o.getProformaId() != null)
            .collect(Collectors.groupingBy(PurchaseOrder::getProformaId));

        List<GoodReceipt> receipts = goodReceiptRepository.findAll();
        Map<Long, List<GoodReceipt>> receiptsByOrder = receipts.stream()
            .filter(r -> r.getCommandeId() != null)
            .collect(Collectors.groupingBy(GoodReceipt::getCommandeId));

        List<Invoice> purchaseInvoices = invoiceRepository.findByTypeFactureIgnoreCase("ACHAT");
        Map<Long, List<Invoice>> invoicesByOrder = purchaseInvoices.stream()
            .filter(inv -> inv.getCommandeAchatId() != null)
            .collect(Collectors.groupingBy(Invoice::getCommandeAchatId));

        List<Map<String, Object>> items = new ArrayList<>();
        Set<Long> requestsWithProforma = new HashSet<>();

        for (Proforma proforma : proformas) {
            PurchaseRequest request = proforma.getDemandeId() != null ? requestById.get(proforma.getDemandeId()) : null;
            if (request != null) {
                requestsWithProforma.add(request.getId());
            }

            PurchaseOrder order = pickLatestOrder(ordersByProforma.get(proforma.getId()));
            GoodReceipt receipt = order != null ? pickLatestReceipt(receiptsByOrder.get(order.getId())) : null;
            Invoice invoice = order != null ? pickLatestInvoice(invoicesByOrder.get(order.getId())) : null;

            Map<String, Object> row = buildValidationRow(request, proforma, order, receipt, invoice);
            if (applyValidationFilters(row, status, importance, mode, fromDate, toDate)) {
                items.add(row);
            }
        }

        for (PurchaseRequest request : requests) {
            if (requestsWithProforma.contains(request.getId())) continue;
            Map<String, Object> row = buildValidationRow(request, null, null, null, null);
            if (applyValidationFilters(row, status, importance, mode, fromDate, toDate)) {
                items.add(row);
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("items", items);
        data.put("total", items.size());
        long complete = items.stream().filter(i -> ((Integer) i.getOrDefault("progress", 0)) >= 100).count();
        data.put("complete", complete);
        data.put("pending", items.size() - complete);
        return data;
    }

    @GetMapping("/sales-cycle")
    public Map<String, Object> getSalesCycleReport() {
        List<SalesProforma> proformas = salesProformaRepository.findAll();
        List<SalesOrder> orders = salesOrderRepository.findAll();
        List<Delivery> deliveries = deliveryRepository.findAll();
        List<Invoice> invoices = invoiceRepository.findByTypeFactureIgnoreCase("VENTE");
        List<Payment> payments = paymentRepository.findAll();
        List<ClientRequest> requests = clientRequestRepository.findAll();

        Map<Long, ClientRequest> requestById = requests.stream()
            .collect(Collectors.toMap(ClientRequest::getId, r -> r, (a, b) -> a));

        Map<Long, List<SalesOrder>> ordersByProforma = orders.stream()
            .filter(o -> o.getProformaId() != null)
            .collect(Collectors.groupingBy(SalesOrder::getProformaId));

        Map<Long, List<Delivery>> deliveriesByOrder = deliveries.stream()
            .filter(d -> d.getCommandeClientId() != null)
            .collect(Collectors.groupingBy(Delivery::getCommandeClientId));

        Map<Long, List<Invoice>> invoicesByOrder = invoices.stream()
            .filter(inv -> inv.getCommandeClientId() != null)
            .collect(Collectors.groupingBy(Invoice::getCommandeClientId));

        Map<Long, List<Payment>> paymentsByInvoice = payments.stream()
            .filter(p -> p.getFactureId() != null)
            .collect(Collectors.groupingBy(Payment::getFactureId));

        List<Map<String, Object>> items = new ArrayList<>();
        for (SalesProforma proforma : proformas) {
            SalesOrder order = pickLatestSalesOrder(ordersByProforma.get(proforma.getId()));
            Delivery delivery = order != null ? pickLatestDelivery(deliveriesByOrder.get(order.getId())) : null;
            Invoice invoice = order != null ? pickLatestInvoice(invoicesByOrder.get(order.getId())) : null;
            Payment payment = invoice != null ? pickLatestPayment(paymentsByInvoice.get(invoice.getId())) : null;
            ClientRequest request = proforma.getRequestId() != null ? requestById.get(proforma.getRequestId()) : null;

            items.add(buildSalesCycleRow(request, proforma, order, delivery, invoice, payment));
        }

        Map<String, Object> data = new HashMap<>();
        data.put("items", items);
        data.put("total", items.size());
        long complete = items.stream().filter(i -> ((Integer) i.getOrDefault("progress", 0)) >= 100).count();
        data.put("complete", complete);
        data.put("pending", items.size() - complete);
        return data;
    }

    @GetMapping("/purchases")
    public Map<String, Object> getPurchaseReport(@RequestParam(required = false) String from,
                                                 @RequestParam(required = false) String to,
                                                 @RequestParam(required = false) Long supplier,
                                                 @RequestParam(required = false) String status) {
        LocalDate fromDate = parseDate(from);
        LocalDate toDate = parseDate(to);

        List<PurchaseOrder> orders = purchaseOrderRepository.findAll().stream()
            .filter(o -> {
                if (supplier != null && (o.getFournisseurId() == null || !supplier.equals(o.getFournisseurId()))) {
                    return false;
                }
                if (status != null && !status.trim().isEmpty()) {
                    String st = o.getStatut() != null ? o.getStatut().trim() : "";
                    if (!st.equalsIgnoreCase(status.trim())) return false;
                }
                if (fromDate != null || toDate != null) {
                    LocalDateTime date = o.getDateCommande() != null ? o.getDateCommande() : o.getDateCreation();
                    if (!withinDate(date, fromDate, toDate)) return false;
                }
                return true;
            })
            .collect(Collectors.toList());

        BigDecimal totalAmount = orders.stream()
            .map(o -> o.getMontantTtc() != null ? o.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Long> byStatus = orders.stream()
            .collect(Collectors.groupingBy(o -> o.getStatut() != null ? o.getStatut() : "INCONNU", Collectors.counting()));

        Map<String, Object> data = new HashMap<>();
        data.put("totalOrders", orders.size());
        data.put("totalAmount", totalAmount);
        data.put("avgOrderValue", orders.isEmpty() ? BigDecimal.ZERO :
            totalAmount.divide(BigDecimal.valueOf(orders.size()), 2, RoundingMode.HALF_UP));
        data.put("pendingOrders", orders.stream()
            .filter(o -> isPendingStatus(o.getStatut()))
            .count());
        data.put("orders", orders.stream().map(this::toPurchaseOrderDto).collect(Collectors.toList()));
        data.put("statusSummary", byStatus);
        data.put("suppliers", buildSupplierSummary(orders));
        return data;
    }

    @GetMapping(value = "/purchases.xlsx", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportPurchasesExcel() {
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Achats");

            int r = 0;
            Row header = sheet.createRow(r++);
            header.createCell(0).setCellValue("Numero");
            header.createCell(1).setCellValue("FournisseurId");
            header.createCell(2).setCellValue("Date creation");
            header.createCell(3).setCellValue("Statut");
            header.createCell(4).setCellValue("Montant TTC (Ar)");

            for (PurchaseOrder o : purchaseOrderRepository.findAll()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(safe(o.getNumero()));
                row.createCell(1).setCellValue(o.getFournisseurId() != null ? o.getFournisseurId() : 0);
                row.createCell(2).setCellValue(o.getDateCreation() != null ? o.getDateCreation().toString() : "");
                row.createCell(3).setCellValue(safe(o.getStatut()));
                row.createCell(4).setCellValue(o.getMontantTtc() != null ? o.getMontantTtc().doubleValue() : 0.0);
            }

            for (int i = 0; i <= 4; i++) sheet.autoSizeColumn(i);

            wb.write(out);
            byte[] bytes = out.toByteArray();
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"rapport-achats.xlsx\"")
                .body(bytes);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/sales")
    public Map<String, Object> getSalesReport(@RequestParam(required = false) String from,
                                              @RequestParam(required = false) String to,
                                              @RequestParam(required = false) Long customer,
                                              @RequestParam(required = false) String status) {
        LocalDate fromDate = parseDate(from);
        LocalDate toDate = parseDate(to);

        List<SalesOrder> orders = salesOrderRepository.findAll().stream()
            .filter(o -> {
                if (customer != null && (o.getClientId() == null || !customer.equals(o.getClientId()))) {
                    return false;
                }
                if (status != null && !status.trim().isEmpty()) {
                    String st = o.getStatut() != null ? o.getStatut().trim() : "";
                    if (!st.equalsIgnoreCase(status.trim())) return false;
                }
                if (fromDate != null || toDate != null) {
                    LocalDateTime date = o.getDateCommande() != null ? o.getDateCommande() : o.getDateCreation();
                    if (!withinDate(date, fromDate, toDate)) return false;
                }
                return true;
            })
            .collect(Collectors.toList());

        BigDecimal totalAmount = orders.stream()
            .map(o -> o.getMontantTtc() != null ? o.getMontantTtc() : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Long> byStatus = orders.stream()
            .collect(Collectors.groupingBy(o -> o.getStatut() != null ? o.getStatut() : "INCONNU", Collectors.counting()));

        Map<String, Object> data = new HashMap<>();
        data.put("totalOrders", orders.size());
        data.put("totalAmount", totalAmount);
        data.put("avgOrderValue", orders.isEmpty() ? BigDecimal.ZERO :
            totalAmount.divide(BigDecimal.valueOf(orders.size()), 2, RoundingMode.HALF_UP));
        data.put("pendingOrders", orders.stream()
            .filter(o -> isPendingStatus(o.getStatut()))
            .count());
        data.put("orders", orders.stream().map(this::toSalesOrderDto).collect(Collectors.toList()));
        data.put("statusSummary", byStatus);
        data.put("customers", buildCustomerSummary(orders));
        return data;
    }

    @GetMapping(value = "/sales.xlsx", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportSalesExcel() {
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Ventes");

            int r = 0;
            Row header = sheet.createRow(r++);
            header.createCell(0).setCellValue("Numero");
            header.createCell(1).setCellValue("ClientId");
            header.createCell(2).setCellValue("Date creation");
            header.createCell(3).setCellValue("Statut");
            header.createCell(4).setCellValue("Montant TTC (Ar)");

            for (SalesOrder o : salesOrderRepository.findAll()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(safe(o.getNumero()));
                row.createCell(1).setCellValue(o.getClientId() != null ? o.getClientId() : 0);
                row.createCell(2).setCellValue(o.getDateCreation() != null ? o.getDateCreation().toString() : "");
                row.createCell(3).setCellValue(safe(o.getStatut()));
                row.createCell(4).setCellValue(o.getMontantTtc() != null ? o.getMontantTtc().doubleValue() : 0.0);
            }

            for (int i = 0; i <= 4; i++) sheet.autoSizeColumn(i);

            wb.write(out);
            byte[] bytes = out.toByteArray();
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"rapport-ventes.xlsx\"")
                .body(bytes);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/financial")
    public Map<String, Object> getFinancialReport(@RequestParam(required = false) String from,
                                                  @RequestParam(required = false) String to) {
        LocalDate fromDate = parseDate(from);
        LocalDate toDate = parseDate(to);
        List<Invoice> invoices = invoiceRepository.findAll().stream()
            .filter(inv -> {
                if (fromDate != null || toDate != null) {
                    LocalDateTime date = inv.getDateFacture() != null ? inv.getDateFacture() : inv.getDateCreation();
                    if (!withinDate(date, fromDate, toDate)) return false;
                }
                return true;
            })
            .collect(Collectors.toList());
        BigDecimal totalRevenue = BigDecimal.ZERO;
        BigDecimal totalExpenses = BigDecimal.ZERO;

        Map<YearMonth, BigDecimal> revenueByMonth = new HashMap<>();
        Map<YearMonth, BigDecimal> expensesByMonth = new HashMap<>();

        for (Invoice inv : invoices) {
            BigDecimal amount = inv.getMontantTtc() != null ? inv.getMontantTtc() : BigDecimal.ZERO;
            String type = inv.getTypeFacture() != null ? inv.getTypeFacture() : "";
            LocalDateTime date = inv.getDateFacture() != null ? inv.getDateFacture() : inv.getDateCreation();
            if (date == null) continue;
            YearMonth ym = YearMonth.from(date);

            if ("VENTE".equalsIgnoreCase(type)) {
                totalRevenue = totalRevenue.add(amount);
                revenueByMonth.merge(ym, amount, BigDecimal::add);
            } else if ("ACHAT".equalsIgnoreCase(type)) {
                totalExpenses = totalExpenses.add(amount);
                expensesByMonth.merge(ym, amount, BigDecimal::add);
            }
        }

        BigDecimal netProfit = totalRevenue.subtract(totalExpenses);
        BigDecimal profitMargin = totalRevenue.compareTo(BigDecimal.ZERO) > 0
            ? netProfit.multiply(BigDecimal.valueOf(100)).divide(totalRevenue, 2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO;

        List<Map<String, Object>> monthlySummary = new ArrayList<>();
        List<YearMonth> months = lastMonths(6);
        for (YearMonth month : months) {
            BigDecimal rev = revenueByMonth.getOrDefault(month, BigDecimal.ZERO);
            BigDecimal exp = expensesByMonth.getOrDefault(month, BigDecimal.ZERO);
            BigDecimal profit = rev.subtract(exp);
            BigDecimal margin = rev.compareTo(BigDecimal.ZERO) > 0
                ? profit.multiply(BigDecimal.valueOf(100)).divide(rev, 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

            Map<String, Object> row = new HashMap<>();
            row.put("month", month.toString());
            row.put("revenue", rev);
            row.put("expenses", exp);
            row.put("profit", profit);
            row.put("margin", margin);
            row.put("cashFlow", profit);
            monthlySummary.add(row);
        }

        Map<String, Object> data = new HashMap<>();
        Map<String, Long> byStatus = invoices.stream()
            .collect(Collectors.groupingBy(inv -> inv.getStatut() != null ? inv.getStatut() : "INCONNU", Collectors.counting()));

        data.put("totalRevenue", totalRevenue);
        data.put("totalExpenses", totalExpenses);
        data.put("netProfit", netProfit);
        data.put("profitMargin", profitMargin);
        data.put("revenueChange", 0);
        data.put("expenseChange", 0);
        data.put("profitChange", 0);
        data.put("monthlySummary", monthlySummary);
        data.put("statusSummary", byStatus);
        return data;
    }

    @GetMapping(value = "/financial.xlsx", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportFinancialExcel() {
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Finance");

            int r = 0;
            Row header = sheet.createRow(r++);
            header.createCell(0).setCellValue("Numero");
            header.createCell(1).setCellValue("Type");
            header.createCell(2).setCellValue("Date facture");
            header.createCell(3).setCellValue("Statut");
            header.createCell(4).setCellValue("Montant TTC (Ar)");

            for (Invoice inv : invoiceRepository.findAll()) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(safe(inv.getNumero()));
                row.createCell(1).setCellValue(safe(inv.getTypeFacture()));
                row.createCell(2).setCellValue(inv.getDateFacture() != null ? inv.getDateFacture().toString() : "");
                row.createCell(3).setCellValue(safe(inv.getStatut()));
                row.createCell(4).setCellValue(inv.getMontantTtc() != null ? inv.getMontantTtc().doubleValue() : 0.0);
            }

            for (int i = 0; i <= 4; i++) sheet.autoSizeColumn(i);

            wb.write(out);
            byte[] bytes = out.toByteArray();
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"rapport-finance.xlsx\"")
                .body(bytes);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/inventory")
    public Map<String, Object> getInventoryReport(@RequestParam(required = false) Long warehouse,
                                                  @RequestParam(required = false) String status) {
        List<StockLevel> levels = stockLevelRepository.findAllWithDetails();
        List<Map<String, Object>> items = new ArrayList<>();
        int lowStockCount = 0;
        BigDecimal totalValue = BigDecimal.ZERO;
        Map<String, Long> statusSummary = new HashMap<>();

        for (StockLevel level : levels) {
            if (level.getEntrepot() == null || level.getArticle() == null) continue;
            if (warehouse != null && !warehouse.equals(level.getEntrepot().getId())) {
                continue;
            }

            Article article = level.getArticle();
            Warehouse wh = level.getEntrepot();
            long qty = level.getQuantiteDisponible() != null ? level.getQuantiteDisponible() : 0L;
            Long min = article.getQuantiteMinimale();
            Long max = article.getQuantiteMaximale();

            String computedStatus = computeStockStatus(qty, min, max);
            if (status != null && !status.isEmpty() && !computedStatus.equalsIgnoreCase(status)) {
                continue;
            }

            statusSummary.merge(computedStatus, 1L, Long::sum);

            if ("LOW".equalsIgnoreCase(computedStatus)) {
                lowStockCount++;
            }

            BigDecimal prix = article.getPrixUnitaire() != null ? article.getPrixUnitaire() : BigDecimal.ZERO;
            BigDecimal lineTotal = prix.multiply(BigDecimal.valueOf(qty));
            totalValue = totalValue.add(lineTotal);

            Map<String, Object> item = new HashMap<>();
            item.put("codeArticle", article.getCode());
            item.put("libelle", article.getLibelle());
            item.put("entrepotLibelle", wh.getNomDepot());
            item.put("quantiteCourante", qty);
            item.put("quantiteMin", min != null ? min : 0L);
            item.put("quantiteMax", max != null ? max : 0L);
            item.put("prixUnitaire", prix);
            items.add(item);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("items", items);
        data.put("totalItems", items.size());
        data.put("totalValue", totalValue);
        data.put("lowStockCount", lowStockCount);
        data.put("avgTurnover", 0);
        data.put("statusSummary", statusSummary);
        return data;
    }

    @GetMapping("/overview")
    public Map<String, Object> getOverview() {
        List<PurchaseOrder> purchases = purchaseOrderRepository.findAll();
        long purchaseDone = purchases.stream().filter(o -> isValidatedOrder(o.getStatut())).count();
        int purchasePct = percent(purchaseDone, purchases.size());

        List<SalesOrder> sales = salesOrderRepository.findAll();
        long salesDone = sales.stream().filter(o -> isSalesDone(o.getStatut())).count();
        int salesPct = percent(salesDone, sales.size());

        List<Invoice> invoices = invoiceRepository.findAll();
        long invoicesPaid = invoices.stream().filter(inv -> isPaid(inv.getStatut())).count();
        int invoicePct = percent(invoicesPaid, invoices.size());

        List<StockLevel> levels = stockLevelRepository.findAllWithDetails();
        long optimal = levels.stream().filter(l -> "OPTIMAL".equalsIgnoreCase(computeStockStatus(
            l.getQuantiteDisponible() != null ? l.getQuantiteDisponible() : 0L,
            l.getArticle() != null ? l.getArticle().getQuantiteMinimale() : null,
            l.getArticle() != null ? l.getArticle().getQuantiteMaximale() : null
        ))).count();
        int stockPct = percent(optimal, levels.size());

        List<Proforma> proformas = proformaRepository.findAll();
        long financeNeeded = proformas.stream().filter(p -> Boolean.TRUE.equals(p.getValidationFinanceRequise())).count();
        long financeDone = proformas.stream().filter(p -> Boolean.TRUE.equals(p.getValideFinance())).count();
        int financePct = percent(financeDone, financeNeeded);

        long directionNeeded = proformas.stream().filter(p -> Boolean.TRUE.equals(p.getValidationDirectionRequise())).count();
        long directionDone = proformas.stream().filter(p -> Boolean.TRUE.equals(p.getValideDirection())).count();
        int directionPct = percent(directionDone, directionNeeded);

        List<GoodReceipt> receipts = goodReceiptRepository.findAll();
        long receiptOrders = receipts.stream()
            .map(GoodReceipt::getCommandeId)
            .filter(Objects::nonNull)
            .distinct()
            .count();
        int receiptPct = percent(receiptOrders, purchases.size());

        List<Invoice> purchaseInvoices = invoiceRepository.findByTypeFactureIgnoreCase("ACHAT");
        long invoicedOrders = purchaseInvoices.stream()
            .map(Invoice::getCommandeAchatId)
            .filter(Objects::nonNull)
            .distinct()
            .count();
        int invoiceOrderPct = percent(invoicedOrders, purchases.size());

        Map<String, Object> data = new HashMap<>();
        List<Map<String, Object>> bars = new ArrayList<>();
        bars.add(bar("Achats", purchasePct, "Commandes valides"));
        bars.add(bar("Ventes", salesPct, "Commandes livrees"));
        bars.add(bar("Factures", invoicePct, "Factures payees"));
        bars.add(bar("Stock", stockPct, "Niveaux optimaux"));

        List<Map<String, Object>> specificBars = new ArrayList<>();
        specificBars.add(bar("Validation finance", financePct, "Proformas validees"));
        specificBars.add(bar("Validation direction", directionPct, "Dossiers critiques"));
        specificBars.add(bar("Receptions", receiptPct, "Commandes receptees"));
        specificBars.add(bar("Facturation achat", invoiceOrderPct, "Commandes facturees"));

        data.put("bars", bars);
        data.put("specificBars", specificBars);
        data.put("counts", Map.of(
            "purchases", purchases.size(),
            "sales", sales.size(),
            "invoices", invoices.size(),
            "stockItems", levels.size()
        ));
        return data;
    }

    @GetMapping(value = "/inventory.xlsx", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    public ResponseEntity<byte[]> exportInventoryExcel(@RequestParam(required = false) Long warehouse,
                                                       @RequestParam(required = false) String status) {
        try (Workbook wb = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Stock");

            int r = 0;
            Row header = sheet.createRow(r++);
            header.createCell(0).setCellValue("Code article");
            header.createCell(1).setCellValue("Libelle");
            header.createCell(2).setCellValue("Entrepot");
            header.createCell(3).setCellValue("Quantite");
            header.createCell(4).setCellValue("Min");
            header.createCell(5).setCellValue("Max");
            header.createCell(6).setCellValue("PU (Ar)");
            header.createCell(7).setCellValue("Statut");

            List<StockLevel> levels = stockLevelRepository.findAllWithDetails();
            for (StockLevel level : levels) {
                if (level.getEntrepot() == null || level.getArticle() == null) continue;
                if (warehouse != null && !warehouse.equals(level.getEntrepot().getId())) continue;

                Article article = level.getArticle();
                Warehouse wh = level.getEntrepot();
                long qty = level.getQuantiteDisponible() != null ? level.getQuantiteDisponible() : 0L;
                Long min = article.getQuantiteMinimale();
                Long max = article.getQuantiteMaximale();
                String computedStatus = computeStockStatus(qty, min, max);
                if (status != null && !status.isEmpty() && !computedStatus.equalsIgnoreCase(status)) continue;

                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue(safe(article.getCode()));
                row.createCell(1).setCellValue(safe(article.getLibelle()));
                row.createCell(2).setCellValue(safe(wh.getNomDepot()));
                row.createCell(3).setCellValue(qty);
                row.createCell(4).setCellValue(min != null ? min : 0L);
                row.createCell(5).setCellValue(max != null ? max : 0L);
                row.createCell(6).setCellValue(article.getPrixUnitaire() != null ? article.getPrixUnitaire().doubleValue() : 0.0);
                row.createCell(7).setCellValue(computedStatus);
            }

            for (int i = 0; i <= 7; i++) sheet.autoSizeColumn(i);

            wb.write(out);
            byte[] bytes = out.toByteArray();
            return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"rapport-stock.xlsx\"")
                .body(bytes);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    private String computeStockStatus(long qty, Long min, Long max) {
        long minVal = min != null ? min : 0L;
        if (qty < minVal) return "LOW";
        if (max != null && qty > max) return "EXCESS";
        return "OPTIMAL";
    }

    private LocalDate parseDate(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        try {
            return LocalDate.parse(raw.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private PurchaseOrder pickLatestOrder(List<PurchaseOrder> orders) {
        if (orders == null || orders.isEmpty()) return null;
        return orders.stream()
            .sorted(Comparator.comparing(PurchaseOrder::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
            .findFirst()
            .orElse(null);
    }

    private GoodReceipt pickLatestReceipt(List<GoodReceipt> receipts) {
        if (receipts == null || receipts.isEmpty()) return null;
        return receipts.stream()
            .sorted(Comparator.comparing(GoodReceipt::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
            .findFirst()
            .orElse(null);
    }

    private Invoice pickLatestInvoice(List<Invoice> invoices) {
        if (invoices == null || invoices.isEmpty()) return null;
        return invoices.stream()
            .sorted(Comparator.comparing(Invoice::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
            .findFirst()
            .orElse(null);
    }

    private SalesOrder pickLatestSalesOrder(List<SalesOrder> orders) {
        if (orders == null || orders.isEmpty()) return null;
        return orders.stream()
            .sorted(Comparator.comparing(SalesOrder::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
            .findFirst()
            .orElse(null);
    }

    private Delivery pickLatestDelivery(List<Delivery> deliveries) {
        if (deliveries == null || deliveries.isEmpty()) return null;
        return deliveries.stream()
            .sorted(Comparator.comparing(Delivery::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
            .findFirst()
            .orElse(null);
    }

    private Payment pickLatestPayment(List<Payment> payments) {
        if (payments == null || payments.isEmpty()) return null;
        return payments.stream()
            .sorted(Comparator.comparing(Payment::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
            .findFirst()
            .orElse(null);
    }

    private Map<String, Object> buildSalesCycleRow(ClientRequest request,
                                                   SalesProforma proforma,
                                                   SalesOrder order,
                                                   Delivery delivery,
                                                   Invoice invoice,
                                                   Payment payment) {
        Map<String, Object> row = new HashMap<>();
        row.put("requestId", request != null ? request.getId() : null);
        row.put("requestNumero", request != null ? ("REQ-" + request.getId()) : "-");
        row.put("requestType", request != null ? request.getRequestType() : "-");

        row.put("proformaId", proforma != null ? proforma.getId() : null);
        row.put("proformaNumero", proforma != null ? proforma.getNumero() : "-");
        row.put("proformaStatus", proforma != null ? proforma.getStatut() : "-");

        row.put("orderId", order != null ? order.getId() : null);
        row.put("orderNumero", order != null ? order.getNumero() : "-");
        row.put("orderStatus", order != null ? order.getStatut() : "-");

        row.put("deliveryId", delivery != null ? delivery.getId() : null);
        row.put("deliveryNumero", delivery != null ? delivery.getNumero() : "-");
        row.put("deliveryStatus", delivery != null ? delivery.getStatut() : "-");

        row.put("invoiceId", invoice != null ? invoice.getId() : null);
        row.put("invoiceNumero", invoice != null ? invoice.getNumero() : "-");
        row.put("invoiceStatus", invoice != null ? invoice.getStatut() : "-");

        row.put("paymentId", payment != null ? payment.getId() : null);
        row.put("paymentNumero", payment != null ? payment.getNumero() : "-");
        row.put("paymentStatus", payment != null ? payment.getStatut() : "-");

        row.put("overallStatus", computeSalesOverallStatus(order, delivery, invoice, payment));
        row.put("progress", computeSalesProgress(proforma, order, delivery, invoice, payment));

        LocalDate dateRef = null;
        if (order != null && order.getDateCreation() != null) {
            dateRef = order.getDateCreation().toLocalDate();
        } else if (delivery != null && delivery.getDateCreation() != null) {
            dateRef = delivery.getDateCreation().toLocalDate();
        } else if (invoice != null && invoice.getDateCreation() != null) {
            dateRef = invoice.getDateCreation().toLocalDate();
        }
        row.put("dateReference", dateRef);
        return row;
    }

    private int computeSalesProgress(SalesProforma proforma,
                                     SalesOrder order,
                                     Delivery delivery,
                                     Invoice invoice,
                                     Payment payment) {
        int steps = 4;
        int done = 0;
        if (proforma != null) done++;
        if (order != null) done++;
        if (delivery != null) done++;
        if (invoice != null) done++;
        if (payment != null || (invoice != null && "PAYEE".equalsIgnoreCase(invoice.getStatut()))) done++;
        steps += 1;
        if (steps <= 0) return 0;
        return Math.round((done * 100f) / steps);
    }

    private String computeSalesOverallStatus(SalesOrder order,
                                             Delivery delivery,
                                             Invoice invoice,
                                             Payment payment) {
        if (payment != null || (invoice != null && "PAYEE".equalsIgnoreCase(invoice.getStatut()))) {
            return "PAYEE";
        }
        if (invoice != null) {
            return invoice.getStatut() != null ? invoice.getStatut() : "FACTUREE";
        }
        if (delivery != null) {
            return delivery.getStatut() != null ? delivery.getStatut() : "LIVRAISON";
        }
        if (order != null) {
            return order.getStatut() != null ? order.getStatut() : "COMMANDE";
        }
        return "-";
    }

    private Map<String, Object> buildValidationRow(PurchaseRequest request,
                                                   Proforma proforma,
                                                   PurchaseOrder order,
                                                   GoodReceipt receipt,
                                                   Invoice invoice) {
        Map<String, Object> row = new HashMap<>();
        row.put("requestId", request != null ? request.getId() : null);
        row.put("requestNumero", request != null ? request.getNumero() : "-");
        row.put("requestStatus", request != null ? request.getStatut() : "-");
        row.put("importance", request != null ? request.getImportance() : (proforma != null ? proforma.getImportance() : "-"));
        row.put("validationMode", request != null ? request.getValidationMode() : (proforma != null ? proforma.getValidationMode() : "-"));

        row.put("proformaId", proforma != null ? proforma.getId() : null);
        row.put("proformaNumero", proforma != null ? proforma.getNumero() : "-");
        row.put("proformaStatus", proforma != null ? proforma.getStatut() : "-");

        row.put("orderId", order != null ? order.getId() : null);
        row.put("orderNumero", order != null ? order.getNumero() : "-");
        row.put("orderStatus", order != null ? order.getStatut() : "-");

        row.put("receiptId", receipt != null ? receipt.getId() : null);
        row.put("receiptNumero", receipt != null ? receipt.getNumero() : "-");
        row.put("receiptStatus", receipt != null ? receipt.getStatut() : "-");

        row.put("invoiceId", invoice != null ? invoice.getId() : null);
        row.put("invoiceNumero", invoice != null ? invoice.getNumero() : "-");
        row.put("invoiceStatus", invoice != null ? invoice.getStatut() : "-");

        row.put("overallStatus", computeOverallStatus(request, proforma, order, receipt, invoice));
        row.put("progress", computeProgress(request, proforma, order, receipt, invoice));

        LocalDate dateRef = null;
        if (proforma != null && proforma.getDateCreation() != null) {
            dateRef = proforma.getDateCreation().toLocalDate();
        } else if (request != null && request.getDateCreation() != null) {
            dateRef = request.getDateCreation().toLocalDate();
        } else if (order != null && order.getDateCreation() != null) {
            dateRef = order.getDateCreation().toLocalDate();
        } else if (receipt != null && receipt.getDateCreation() != null) {
            dateRef = receipt.getDateCreation().toLocalDate();
        } else if (invoice != null && invoice.getDateCreation() != null) {
            dateRef = invoice.getDateCreation().toLocalDate();
        }
        row.put("dateReference", dateRef);
        return row;
    }

    private boolean applyValidationFilters(Map<String, Object> row,
                                           String status,
                                           String importance,
                                           String mode,
                                           LocalDate from,
                                           LocalDate to) {
        if (status != null && !status.trim().isEmpty()) {
            String overall = String.valueOf(row.getOrDefault("overallStatus", "")).trim();
            if (!overall.equalsIgnoreCase(status.trim())) return false;
        }
        if (importance != null && !importance.trim().isEmpty()) {
            String value = String.valueOf(row.getOrDefault("importance", "")).trim();
            if (!value.equalsIgnoreCase(importance.trim())) return false;
        }
        if (mode != null && !mode.trim().isEmpty()) {
            String value = String.valueOf(row.getOrDefault("validationMode", "")).trim();
            if (!value.equalsIgnoreCase(mode.trim())) return false;
        }
        if (from != null || to != null) {
            Object rawDate = row.get("dateReference");
            LocalDate date = null;
            if (rawDate instanceof LocalDate) {
                date = (LocalDate) rawDate;
            } else if (rawDate != null) {
                try {
                    date = LocalDate.parse(rawDate.toString());
                } catch (Exception e) {
                    date = null;
                }
            }
            if (date != null) {
                if (from != null && date.isBefore(from)) return false;
                if (to != null && date.isAfter(to)) return false;
            }
        }
        return true;
    }

    private boolean withinDate(LocalDateTime date, LocalDate from, LocalDate to) {
        if (date == null) return false;
        LocalDate day = date.toLocalDate();
        if (from != null && day.isBefore(from)) return false;
        if (to != null && day.isAfter(to)) return false;
        return true;
    }

    private String computeOverallStatus(PurchaseRequest request,
                                        Proforma proforma,
                                        PurchaseOrder order,
                                        GoodReceipt receipt,
                                        Invoice invoice) {
        if (invoice != null && invoice.getStatut() != null) return invoice.getStatut();
        if (receipt != null && receipt.getStatut() != null) return receipt.getStatut();
        if (order != null && order.getStatut() != null) return order.getStatut();
        if (proforma != null && proforma.getStatut() != null) return proforma.getStatut();
        if (request != null && request.getStatut() != null) return request.getStatut();
        return "INCONNU";
    }

    private int computeProgress(PurchaseRequest request,
                                Proforma proforma,
                                PurchaseOrder order,
                                GoodReceipt receipt,
                                Invoice invoice) {
        int steps = 5;
        int done = 0;
        if (request != null && "APPROUVEE".equalsIgnoreCase(request.getStatut())) done++;
        if (proforma != null && isValidatedProforma(proforma.getStatut())) done++;
        if (order != null && isValidatedOrder(order.getStatut())) done++;
        if (receipt != null && "VALIDEE".equalsIgnoreCase(receipt.getStatut())) done++;
        if (invoice != null) done++;
        return (int) Math.round(done * 100.0 / steps);
    }

    private boolean isValidatedProforma(String status) {
        if (status == null) return false;
        String s = status.toUpperCase(Locale.ROOT);
        return s.equals("VALIDEE") || s.equals("APPROUVEE") || s.equals("TRANSFORMEE_BC");
    }

    private boolean isValidatedOrder(String status) {
        if (status == null) return false;
        String s = status.toUpperCase(Locale.ROOT);
        return s.equals("VALIDEE") || s.equals("RECUE") || s.equals("FACTUREE");
    }

    private boolean isSalesDone(String status) {
        if (status == null) return false;
        String s = status.toUpperCase(Locale.ROOT);
        return s.equals("LIVREE") || s.equals("FACTUREE") || s.equals("PAYEE") || s.equals("VALIDEE");
    }

    private boolean isPaid(String status) {
        if (status == null) return false;
        String s = status.toUpperCase(Locale.ROOT);
        return s.equals("PAYEE") || s.equals("PAID");
    }

    private Map<String, Object> toPurchaseOrderDto(PurchaseOrder order) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", order.getId());
        map.put("numero", order.getNumero());
        map.put("fournisseurLibelle", resolveSupplierLabel(order.getFournisseurId()));
        map.put("dateCreation", order.getDateCreation());
        map.put("dateExpectedDelivery", order.getDateEcheanceEstimee());
        map.put("montantTotal", order.getMontantTtc());
        map.put("statut", order.getStatut());
        return map;
    }

    private Map<String, Object> toSalesOrderDto(SalesOrder order) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", order.getId());
        map.put("numero", order.getNumero());
        map.put("clientLibelle", resolveCustomerLabel(order.getClientId()));
        map.put("dateCreation", order.getDateCreation());
        map.put("dateLivraison", order.getDateCommande());
        map.put("montantTotal", order.getMontantTtc());
        map.put("statut", order.getStatut());
        return map;
    }

    private List<Map<String, Object>> buildSupplierSummary(List<PurchaseOrder> orders) {
        Map<Long, String> labelById = supplierRepository.findAll().stream()
            .collect(Collectors.toMap(s -> s.getId(), s -> s.getNomEntreprise()));

        Map<Long, Long> counts = new HashMap<>();
        for (PurchaseOrder order : orders) {
            if (order.getFournisseurId() == null) continue;
            counts.merge(order.getFournisseurId(), 1L, Long::sum);
        }

        return counts.entrySet().stream()
            .map(entry -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id", entry.getKey());
                map.put("label", labelById.getOrDefault(entry.getKey(), "ID " + entry.getKey()));
                map.put("count", entry.getValue());
                return map;
            })
            .sorted((a, b) -> Long.compare((Long) b.get("count"), (Long) a.get("count")))
            .collect(Collectors.toList());
    }

    private List<Map<String, Object>> buildCustomerSummary(List<SalesOrder> orders) {
        Map<Long, String> labelById = customerRepository.findAll().stream()
            .collect(Collectors.toMap(c -> c.getId(), c -> c.getNomEntreprise()));

        Map<Long, Long> counts = new HashMap<>();
        for (SalesOrder order : orders) {
            if (order.getClientId() == null) continue;
            counts.merge(order.getClientId(), 1L, Long::sum);
        }

        return counts.entrySet().stream()
            .map(entry -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id", entry.getKey());
                map.put("label", labelById.getOrDefault(entry.getKey(), "ID " + entry.getKey()));
                map.put("count", entry.getValue());
                return map;
            })
            .sorted((a, b) -> Long.compare((Long) b.get("count"), (Long) a.get("count")))
            .collect(Collectors.toList());
    }

    private String resolveSupplierLabel(Long id) {
        if (id == null) return "-";
        return supplierRepository.findById(id)
            .map(s -> s.getNomEntreprise())
            .orElse("ID " + id);
    }

    private String resolveCustomerLabel(Long id) {
        if (id == null) return "-";
        return customerRepository.findById(id)
            .map(c -> c.getNomEntreprise())
            .orElse("ID " + id);
    }

    private int percent(long part, long total) {
        if (total <= 0) return 0;
        return (int) Math.round((part * 100.0) / total);
    }

    private Map<String, Object> bar(String label, int value, String note) {
        Map<String, Object> map = new HashMap<>();
        map.put("label", label);
        map.put("value", value);
        map.put("note", note);
        return map;
    }

    private List<YearMonth> lastMonths(int count) {
        YearMonth current = YearMonth.now();
        List<YearMonth> months = new ArrayList<>();
        for (int i = count - 1; i >= 0; i--) {
            months.add(current.minusMonths(i));
        }
        return months;
    }

    private boolean isPendingStatus(String statut) {
        if (statut == null) return false;
        String normalized = statut.toUpperCase(Locale.ROOT);
        return normalized.equals("BROUILLON")
            || normalized.equals("EN_COURS")
            || normalized.equals("EN_ATTENTE")
            || normalized.equals("DRAFT")
            || normalized.equals("SUBMITTED");
    }

    private String safe(String value) {
        return value != null ? value : "";
    }
}
