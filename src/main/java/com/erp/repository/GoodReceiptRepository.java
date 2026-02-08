package com.erp.repository;

import com.erp.domain.GoodReceipt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GoodReceiptRepository extends JpaRepository<GoodReceipt, Long> {
    Optional<GoodReceipt> findByNumero(String numero);
    List<GoodReceipt> findByStatut(String statut);
    List<GoodReceipt> findByCommandeId(Long commandeId);

    @Query("select distinct gr from GoodReceipt gr left join fetch gr.lines l left join fetch l.article where gr.id = :id")
    Optional<GoodReceipt> findByIdWithLines(@Param("id") Long id);
}
