package com.erp.repository;

import com.erp.domain.SalesProforma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SalesProformaRepository extends JpaRepository<SalesProforma, Long> {
    Optional<SalesProforma> findByNumero(String numero);
    List<SalesProforma> findByClientId(Long clientId);
    List<SalesProforma> findByRequestId(Long requestId);
    List<SalesProforma> findByStatut(String statut);
}
