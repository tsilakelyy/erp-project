package com.erp.repository;

import com.erp.domain.Delivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    Optional<Delivery> findByNumero(String numero);
    List<Delivery> findByStatut(String statut);
    List<Delivery> findByCommandeClientIdIn(List<Long> commandeClientIds);
    Optional<Delivery> findFirstByCommandeClientIdOrderByDateCreationDesc(Long commandeClientId);
}
