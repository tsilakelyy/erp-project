package com.erp.repository;

import com.erp.domain.StockLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockLevelRepository extends JpaRepository<StockLevel, Long> {
    Optional<StockLevel> findByEntrepot_IdAndArticle_Id(Long entrepotId, Long articleId);
    List<StockLevel> findByEntrepot_Id(Long entrepotId);
    List<StockLevel> findByEntrepot_IdAndQuantiteActuelleGreaterThan(Long entrepotId, Long quantity);
}
