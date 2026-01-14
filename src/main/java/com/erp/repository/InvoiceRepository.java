package com.erp.repository;

import com.erp.domain.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {
    Optional<Invoice> findByNumber(String number);
    List<Invoice> findByStatus(String status);
    List<Invoice> findBySiteIdAndStatusOrderByCreatedAtDesc(Long siteId, String status);
}
