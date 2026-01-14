package com.erp.repository;

import com.erp.domain.Tax;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TaxRepository extends JpaRepository<Tax, Long> {
    Optional<Tax> findByCode(String code);
    List<Tax> findByActiveTrue();
}
