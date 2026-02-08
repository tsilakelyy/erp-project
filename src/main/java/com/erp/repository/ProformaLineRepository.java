package com.erp.repository;

import com.erp.domain.ProformaLine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProformaLineRepository extends JpaRepository<ProformaLine, Long> {
}

