package com.erp.repository;

import com.erp.domain.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {
    Optional<Invoice> findByNumero(String numero);
    List<Invoice> findByStatut(String statut);
    List<Invoice> findByTiersIdAndTypeTiers(Long tiersId, String typeTiers);
    List<Invoice> findByTypeFactureIgnoreCase(String typeFacture);
    List<Invoice> findByTypeFacture(String typeFacture);
    List<Invoice> findByCommandeAchatId(Long commandeAchatId);
    Optional<Invoice> findFirstByCommandeAchatId(Long commandeAchatId);
    List<Invoice> findByCommandeClientId(Long commandeClientId);
    Optional<Invoice> findFirstByCommandeClientId(Long commandeClientId);
    List<Invoice> findByDateFactureBetween(LocalDateTime startDate, LocalDateTime endDate);

    @Query("select distinct i from Invoice i left join fetch i.lines l left join fetch l.article where i.id = :id")
    Optional<Invoice> findByIdWithLines(@Param("id") Long id);
}
