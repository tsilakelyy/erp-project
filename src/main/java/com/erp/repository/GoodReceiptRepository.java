package com.erp.repository;

import com.erp.domain.GoodReceipt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GoodReceiptRepository extends JpaRepository<GoodReceipt, Long> {
    Optional<GoodReceipt> findByNumber(String number);
    List<GoodReceipt> findByStatus(String status);
    List<GoodReceipt> findByWarehouseIdAndStatusOrderByCreatedAtDesc(Long warehouseId, String status);
}
