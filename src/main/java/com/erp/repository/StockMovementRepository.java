package com.erp.repository;

import com.erp.domain.Article;
import com.erp.domain.StockMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {
    List<StockMovement> findByEntrepotIdAndArticle(Long entrepotId, Article article);
    List<StockMovement> findByEntrepotIdAndMovementDateBetween(Long entrepotId, LocalDateTime start, LocalDateTime end);
    
    @Query("SELECT sm FROM StockMovement sm WHERE sm.article.id = :articleId ORDER BY sm.movementDate ASC")
    List<StockMovement> findArticleMovementHistory(@Param("articleId") Long articleId);
}
