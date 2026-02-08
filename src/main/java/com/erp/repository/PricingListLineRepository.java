package com.erp.repository;

import com.erp.domain.PricingListLine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PricingListLineRepository extends JpaRepository<PricingListLine, Long> {
    List<PricingListLine> findByPricingListId(Long pricingListId);
    List<PricingListLine> findByArticleId(Long articleId);
    List<PricingListLine> findByPricingListIdAndActifTrue(Long pricingListId);
    Optional<PricingListLine> findByPricingListIdAndArticleId(Long pricingListId, Long articleId);
}
