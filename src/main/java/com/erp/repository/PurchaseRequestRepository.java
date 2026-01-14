package com.erp.repository;

import com.erp.domain.PurchaseRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseRequestRepository extends JpaRepository<PurchaseRequest, Long> {
    Optional<PurchaseRequest> findByNumber(String number);
    List<PurchaseRequest> findByStatus(String status);
    List<PurchaseRequest> findBySiteIdAndStatusOrderByCreatedAtDesc(Long siteId, String status);
}
