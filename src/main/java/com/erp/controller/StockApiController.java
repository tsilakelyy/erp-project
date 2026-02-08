package com.erp.controller;

import com.erp.domain.Article;
import com.erp.domain.StockLevel;
import com.erp.domain.StockMovement;
import com.erp.domain.Warehouse;
import com.erp.repository.StockMovementRepository;
import com.erp.repository.WarehouseRepository;
import com.erp.service.StockService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/stock-levels")
public class StockApiController {

    @Autowired
    @Qualifier("erpStockService")
    private StockService stockService;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private StockMovementRepository stockMovementRepository;

    @GetMapping
    public List<Map<String, Object>> getAllStockLevels(@RequestParam(required = false) Long warehouse,
                                                       @RequestParam(required = false) String status) {
        List<StockLevel> levels = filterLevels(stockService.getAllStockLevelsWithDetails(), warehouse, status);
        return levels.stream().map(level -> {
            Map<String, Object> item = new HashMap<>();
            item.put("articleCode", level.getArticle() != null ? level.getArticle().getCode() : null);
            item.put("entrepotCode", level.getEntrepot() != null ? level.getEntrepot().getCode() : null);
            item.put("quantiteActuelle", level.getQuantiteActuelle());
            item.put("quantiteReservee", level.getQuantiteReservee());
            item.put("quantiteDisponible", level.getQuantiteDisponible());
            return item;
        }).collect(Collectors.toList());
    }

    @GetMapping("/metrics")
    public Map<String, Object> getStockMetrics(@RequestParam(required = false) Long warehouse,
                                               @RequestParam(required = false) String status) {
        List<StockLevel> levels = filterLevels(stockService.getAllStockLevelsWithDetails(), warehouse, status);
        long itemsCount = levels.size();
        long lowStockCount = levels.stream().filter(this::isLowStock).count();
        double capacityUsage = computeCapacityUsage(levels);

        Map<String, Object> metrics = new HashMap<>();
        metrics.put("itemsCount", itemsCount);
        metrics.put("capacityUsage", Math.round(capacityUsage));
        metrics.put("lowStockCount", lowStockCount);
        metrics.put("pendingOrders", 0);
        return metrics;
    }

    @GetMapping("/low-stock")
    public List<Map<String, Object>> getLowStockItems(@RequestParam(required = false) Long warehouse,
                                                      @RequestParam(required = false) String status) {
        List<StockLevel> levels = filterLevels(stockService.getAllStockLevelsWithDetails(), warehouse, status);
        return levels.stream()
            .filter(this::isLowStock)
            .map(level -> {
                Map<String, Object> item = new HashMap<>();
                Article article = level.getArticle();
                item.put("codeArticle", article != null ? article.getCode() : null);
                item.put("libelle", article != null ? article.getLibelle() : null);
                item.put("quantiteCourante", level.getQuantiteDisponible());
                item.put("quantiteMin", article != null ? article.getQuantiteMinimale() : null);
                return item;
            })
            .collect(Collectors.toList());
    }

    @GetMapping("/charts")
    public Map<String, Object> getStockCharts(@RequestParam(required = false) Long warehouse,
                                              @RequestParam(required = false) String status) {
        List<StockLevel> levels = filterLevels(stockService.getAllStockLevelsWithDetails(), warehouse, status);
        List<Warehouse> warehouses = warehouseRepository.findAll();
        if (warehouse != null) {
            warehouses = warehouses.stream()
                .filter(w -> warehouse.equals(w.getId()))
                .collect(Collectors.toList());
        }

        Map<Long, Long> stockByWarehouse = new HashMap<>();
        for (StockLevel level : levels) {
            if (level.getEntrepot() == null) continue;
            Long wid = level.getEntrepot().getId();
            Long qty = level.getQuantiteActuelle() != null ? level.getQuantiteActuelle() : 0L;
            stockByWarehouse.merge(wid, qty, Long::sum);
        }

        List<String> warehouseLabels = new ArrayList<>();
        List<Long> warehouseStock = new ArrayList<>();
        List<BigDecimal> capacityUsage = new ArrayList<>();

        for (Warehouse wh : warehouses) {
            warehouseLabels.add(wh.getNomDepot());
            Long qty = stockByWarehouse.getOrDefault(wh.getId(), 0L);
            warehouseStock.add(qty);

            BigDecimal capacity = wh.getCapaciteMaximale();
            if (capacity != null && capacity.doubleValue() > 0) {
                BigDecimal usage = BigDecimal.valueOf(qty).multiply(BigDecimal.valueOf(100))
                    .divide(capacity, 2, RoundingMode.HALF_UP);
                capacityUsage.add(usage);
            } else {
                capacityUsage.add(BigDecimal.ZERO);
            }
        }

        Map<String, Object> movementTrend = buildMovementTrend(warehouse);

        Map<String, Object> data = new HashMap<>();
        data.put("stockByWarehouse", toChartData(warehouseLabels, warehouseStock));
        data.put("capacityUsage", toChartData(warehouseLabels, capacityUsage));
        data.put("movementTrend", movementTrend);
        return data;
    }

    private boolean isLowStock(StockLevel level) {
        if (level == null || level.getArticle() == null) {
            return false;
        }
        Long min = level.getArticle().getQuantiteMinimale();
        Long available = level.getQuantiteDisponible();
        if (min == null || available == null) {
            return false;
        }
        return available < min;
    }

    private String computeStatus(StockLevel level) {
        if (level == null || level.getArticle() == null) {
            return "OPTIMAL";
        }
        Long available = level.getQuantiteDisponible() != null ? level.getQuantiteDisponible() : 0L;
        Long min = level.getArticle().getQuantiteMinimale();
        Long max = level.getArticle().getQuantiteMaximale();
        if (min != null && available < min) return "LOW";
        if (max != null && available > max) return "EXCESS";
        return "OPTIMAL";
    }

    private List<StockLevel> filterLevels(List<StockLevel> levels, Long warehouseId, String status) {
        if (levels == null) return new ArrayList<>();
        return levels.stream()
            .filter(level -> {
                if (warehouseId != null) {
                    if (level.getEntrepot() == null || !warehouseId.equals(level.getEntrepot().getId())) {
                        return false;
                    }
                }
                if (status != null && !status.trim().isEmpty()) {
                    return computeStatus(level).equalsIgnoreCase(status.trim());
                }
                return true;
            })
            .collect(Collectors.toList());
    }

    private double computeCapacityUsage(List<StockLevel> levels) {
        if (levels == null || levels.isEmpty()) return 0;
        Map<Long, Long> qtyByWarehouse = new HashMap<>();
        for (StockLevel level : levels) {
            if (level.getEntrepot() == null) continue;
            Long wid = level.getEntrepot().getId();
            Long qty = level.getQuantiteActuelle() != null ? level.getQuantiteActuelle() : 0L;
            qtyByWarehouse.merge(wid, qty, Long::sum);
        }

        double totalCapacity = 0;
        double totalQty = 0;
        for (Warehouse wh : warehouseRepository.findAll()) {
            double cap = wh.getCapaciteMaximale() != null ? wh.getCapaciteMaximale().doubleValue() : 0;
            totalCapacity += cap;
            totalQty += qtyByWarehouse.getOrDefault(wh.getId(), 0L);
        }

        if (totalCapacity <= 0) return 0;
        return (totalQty / totalCapacity) * 100.0;
    }

    private Map<String, Object> buildMovementTrend(Long warehouseId) {
        List<StockMovement> movements = stockMovementRepository.findAll();
        Map<YearMonth, Long> inbound = new HashMap<>();
        Map<YearMonth, Long> outbound = new HashMap<>();

        for (StockMovement mv : movements) {
            if (warehouseId != null && (mv.getEntrepotId() == null || !warehouseId.equals(mv.getEntrepotId()))) {
                continue;
            }
            LocalDateTime date = mv.getMovementDate();
            if (date == null) continue;
            YearMonth ym = YearMonth.from(date);
            long qty = mv.getQuantity() != null ? mv.getQuantity() : 0;
            String type = mv.getType() != null ? mv.getType().toUpperCase() : "";
            if ("ENTREE".equals(type)) {
                inbound.merge(ym, Math.abs(qty), Long::sum);
            } else if ("SORTIE".equals(type)) {
                outbound.merge(ym, Math.abs(qty), Long::sum);
            }
        }

        List<YearMonth> months = new ArrayList<>();
        YearMonth current = YearMonth.now();
        for (int i = 5; i >= 0; i--) {
            months.add(current.minusMonths(i));
        }

        List<String> labels = months.stream().map(YearMonth::toString).collect(Collectors.toList());
        List<Long> inboundData = months.stream().map(m -> inbound.getOrDefault(m, 0L)).collect(Collectors.toList());
        List<Long> outboundData = months.stream().map(m -> outbound.getOrDefault(m, 0L)).collect(Collectors.toList());

        Map<String, Object> data = new HashMap<>();
        data.put("labels", labels);
        data.put("inbound", inboundData);
        data.put("outbound", outboundData);
        return data;
    }

    private Map<String, Object> toChartData(List<String> labels, List<? extends Number> values) {
        Map<String, Object> chart = new HashMap<>();
        chart.put("labels", labels);
        chart.put("data", values);
        return chart;
    }
}
