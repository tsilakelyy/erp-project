package com.erp.repository;

import com.erp.domain.StockLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockLevelRepository extends JpaRepository<StockLevel, Long> {
    Optional<StockLevel> findByEntrepot_IdAndArticle_Id(Long entrepotId, Long articleId);
    List<StockLevel> findByEntrepot_Id(Long entrepotId);
    List<StockLevel> findByEntrepot_IdAndQuantiteActuelleGreaterThan(Long entrepotId, Long quantity);

    @Query("select sl from StockLevel sl join fetch sl.article join fetch sl.entrepot")
    List<StockLevel> findAllWithDetails();

    @Query("select sl from StockLevel sl join fetch sl.article join fetch sl.entrepot where sl.entrepot.id = :entrepotId")
    List<StockLevel> findByEntrepotIdWithDetails(Long entrepotId);
}
