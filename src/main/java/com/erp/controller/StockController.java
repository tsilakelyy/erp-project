package com.erp.controller;

import com.erp.domain.StockLevel;
import com.erp.domain.StockMovement;
import com.erp.domain.Warehouse;
import com.erp.service.StockService;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/stocks")
public class StockController {
    @Autowired
    private StockService stockService;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<Warehouse> warehouses = warehouseRepository.findAll();
        model.addAttribute("warehouses", warehouses);
        return "stocks/list";
    }

    @GetMapping("/warehouse/{warehouseId}")
    public String warehouseStock(@PathVariable Long warehouseId, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Warehouse> warehouse = warehouseRepository.findById(warehouseId);
        if (warehouse.isPresent()) {
            List<StockLevel> levels = stockService.getWarehouseStock(warehouseId);
            BigDecimal totalValue = stockService.getWarehouseStockValue(warehouseId);
            model.addAttribute("warehouse", warehouse.get());
            model.addAttribute("stocks", levels);
            model.addAttribute("totalValue", totalValue);
            return "stocks/warehouse-detail";
        }
        return "redirect:/stocks";
    }

    @GetMapping("/article/{articleId}")
    public String articleHistory(@PathVariable Long articleId, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<StockMovement> movements = stockService.getArticleHistory(articleId);
        model.addAttribute("movements", movements);
        return "stocks/article-history";
    }

    // REST API
    @GetMapping("/api/warehouse/{warehouseId}")
    @ResponseBody
    public ResponseEntity<List<StockLevel>> getWarehouseStock(@PathVariable Long warehouseId) {
        return ResponseEntity.ok(stockService.getWarehouseStock(warehouseId));
    }

    @GetMapping("/api/stock-levels")
    @ResponseBody
    public ResponseEntity<List<StockLevel>> getAllStockLevels() {
        return ResponseEntity.ok(stockService.getAllStockLevels());
    }

    @GetMapping("/api/available/{warehouseId}/{articleId}")
    @ResponseBody
    public ResponseEntity<Integer> getAvailableQuantity(@PathVariable Long warehouseId, @PathVariable Long articleId) {
        int qty = stockService.getAvailableQuantity(warehouseId, articleId);
        return ResponseEntity.ok(qty);
    }
}
