package com.erp.repository;

import com.erp.domain.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {
    Optional<Inventory> findByNumber(String number);
    List<Inventory> findByStatus(String status);
    List<Inventory> findByWarehouseIdAndStatusOrderByCreatedAtDesc(Long warehouseId, String status);
}
