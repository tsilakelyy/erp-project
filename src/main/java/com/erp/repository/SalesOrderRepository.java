package com.erp.repository;

import com.erp.domain.SalesOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SalesOrderRepository extends JpaRepository<SalesOrder, Long> {
    Optional<SalesOrder> findByNumber(String number);
    List<SalesOrder> findByStatus(String status);
    List<SalesOrder> findBySiteIdAndStatusOrderByCreatedAtDesc(Long siteId, String status);
    List<SalesOrder> findByCustomerId(Long customerId);
}
