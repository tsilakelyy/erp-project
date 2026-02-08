package com.erp.repository;

import com.erp.domain.Proforma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProformaRepository extends JpaRepository<Proforma, Long> {
    Optional<Proforma> findByNumero(String numero);
    List<Proforma> findByStatut(String statut);
    List<Proforma> findByDemandeId(Long demandeId);
}

