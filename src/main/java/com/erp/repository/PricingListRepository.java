package com.erp.repository;

import com.erp.domain.PricingList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PricingListRepository extends JpaRepository<PricingList, Long> {
    Optional<PricingList> findByCode(String code);
    List<PricingList> findByTypeListe(String typeListe);
    List<PricingList> findByActifTrue();
    Optional<PricingList> findByTypeListeAndParDefautTrue(String typeListe);
    List<PricingList> findAll();
}
