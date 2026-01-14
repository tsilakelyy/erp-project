package com.erp.repository;

import com.erp.domain.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {
    Optional<PurchaseOrder> findByNumber(String number);
    List<PurchaseOrder> findByStatus(String status);
    List<PurchaseOrder> findBySiteIdAndStatusOrderByCreatedAtDesc(Long siteId, String status);
    List<PurchaseOrder> findBySupplierId(Long supplierId);
}
