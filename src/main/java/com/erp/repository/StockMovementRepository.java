package com.erp.repository;

import com.erp.domain.StockMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    List<StockMovement> findByWarehouseIdAndArticleId(Long warehouseId, Long articleId);
    List<StockMovement> findByWarehouseIdAndMovementDateBetween(Long warehouseId, LocalDateTime start, LocalDateTime end);
    List<StockMovement> findByArticleIdOrderByMovementDateAsc(Long articleId);
}
