package com.erp.repository;

import com.erp.domain.SalesProformaLine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SalesProformaLineRepository extends JpaRepository<SalesProformaLine, Long> {
    List<SalesProformaLine> findByProformaId(Long proformaId);
}
