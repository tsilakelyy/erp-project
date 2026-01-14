package com.erp.repository;

import com.erp.domain.Delivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    Optional<Delivery> findByNumber(String number);
    List<Delivery> findByStatus(String status);
    List<Delivery> findByWarehouseIdAndStatusOrderByCreatedAtDesc(Long warehouseId, String status);
}
