package com.erp.validator;

import com.erp.domain.Article;
import com.erp.exception.ValidationException;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * Validator for Article entity
 * Validates business rules for articles (products)
 */
@Component
public class ArticleValidator {

    /**
     * Validate article before creation/update
     * @param article Article to validate
     * @throws ValidationException if validation fails
     */
    public void validate(Article article) {
        if (article == null) {
            throw new ValidationException("Article cannot be null", "article", "ARTICLE_NULL");
        }

        if (article.getCode() == null || article.getCode().trim().isEmpty()) {
            throw new ValidationException("Article code is required", "code", "CODE_REQUIRED");
        }

        if (article.getCode().length() > 50) {
            throw new ValidationException("Article code must not exceed 50 characters", "code", "CODE_TOO_LONG");
        }

        if (article.getName() == null || article.getName().trim().isEmpty()) {
            throw new ValidationException("Article name is required", "name", "NAME_REQUIRED");
        }

        if (article.getSellingPrice() == null || article.getSellingPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new ValidationException("Article price must be greater than 0", "sellingPrice", "PRICE_INVALID");
        }

        if (article.getUnit() == null) {
            throw new ValidationException("Unit is required", "unit", "UNIT_REQUIRED");
        }

        if (article.getMinStock() != null && article.getMaxStock() != null) {
            if (article.getMinStock() > article.getMaxStock()) {
                throw new ValidationException("Minimum stock must be less than maximum stock", "minStock", "STOCK_INVALID");
            }
        }
    }
}
