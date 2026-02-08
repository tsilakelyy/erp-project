package com.erp.repository;

import com.erp.domain.SalesOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SalesOrderRepository extends JpaRepository<SalesOrder, Long> {
    Optional<SalesOrder> findByNumero(String numero);
    List<SalesOrder> findByStatut(String statut);
    List<SalesOrder> findByClientId(Long clientId);
    Optional<SalesOrder> findByClientRequestId(Long clientRequestId);
    Optional<SalesOrder> findFirstByProformaId(Long proformaId);
    List<SalesOrder> findByProformaId(Long proformaId);
}
