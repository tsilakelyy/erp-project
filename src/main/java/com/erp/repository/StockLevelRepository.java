package com.erp.repository;

import com.erp.domain.StockLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockLevelRepository extends JpaRepository<StockLevel, Long> {
    Optional<StockLevel> findByWarehouseIdAndArticleId(Long warehouseId, Long articleId);
    List<StockLevel> findByWarehouseId(Long warehouseId);
    List<StockLevel> findByWarehouseIdAndQuantityGreaterThan(Long warehouseId, Integer quantity);
}
