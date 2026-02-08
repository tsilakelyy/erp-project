package com.erp.repository;

import com.erp.domain.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {
    Optional<PurchaseOrder> findByNumero(String numero);
    List<PurchaseOrder> findByStatut(String statut);
    List<PurchaseOrder> findByProformaId(Long proformaId);

    @Query("select distinct po from PurchaseOrder po left join fetch po.lines l left join fetch l.article where po.id = :id")
    Optional<PurchaseOrder> findByIdWithLines(@Param("id") Long id);
}
