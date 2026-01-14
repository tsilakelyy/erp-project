package com.erp.validator;

import com.erp.domain.StockMovement;
import com.erp.exception.ValidationException;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * Validator for StockMovement entity
 * Validates business rules for stock movements
 */
@Component
public class StockMovementValidator {

    /**
     * Validate stock movement before creation/update
     * @param movement StockMovement to validate
     * @throws ValidationException if validation fails
     */
    public void validate(StockMovement movement) {
        if (movement == null) {
            throw new ValidationException("Stock movement cannot be null", "movement", "MOVEMENT_NULL");
        }

        if (movement.getType() == null || movement.getType().trim().isEmpty()) {
            throw new ValidationException("Movement type is required", "type", "TYPE_REQUIRED");
        }

        String type = movement.getType().toUpperCase();
        if (!isValidMovementType(type)) {
            throw new ValidationException(
                "Invalid movement type. Must be ENTREE, SORTIE, TRANSFERT, RESERVATION, or AJUSTEMENT",
                "type",
                "TYPE_INVALID"
            );
        }

        if (movement.getArticle() == null) {
            throw new ValidationException("Article is required", "article", "ARTICLE_REQUIRED");
        }

        if (movement.getWarehouse() == null) {
            throw new ValidationException("Warehouse is required", "warehouse", "WAREHOUSE_REQUIRED");
        }

        if (movement.getQuantity() == null || movement.getQuantity() <= 0) {
            throw new ValidationException("Quantity must be greater than 0", "quantity", "QUANTITY_INVALID");
        }

        if (movement.getUnitCost() == null || movement.getUnitCost().compareTo(BigDecimal.ZERO) < 0) {
            throw new ValidationException("Unit cost cannot be negative", "unitCost", "COST_NEGATIVE");
        }

        if (movement.getTotalCost() == null || movement.getTotalCost().compareTo(BigDecimal.ZERO) < 0) {
            throw new ValidationException("Total cost cannot be negative", "totalCost", "COST_NEGATIVE");
        }

        // Validate that total cost matches quantity * unit cost
        BigDecimal calculatedTotal = BigDecimal.valueOf(movement.getQuantity())
            .multiply(movement.getUnitCost());

        if (!movement.getTotalCost().equals(calculatedTotal)) {
            throw new ValidationException(
                "Total cost mismatch: should be " + calculatedTotal.toString(),
                "totalCost",
                "COST_MISMATCH"
            );
        }
    }

    /**
     * Check if movement type is valid
     * @param type Movement type
     * @return true if type is valid
     */
    private boolean isValidMovementType(String type) {
        return "ENTREE".equals(type) || "SORTIE".equals(type) || "TRANSFERT".equals(type)
            || "RESERVATION".equals(type) || "AJUSTEMENT".equals(type);
    }
}
