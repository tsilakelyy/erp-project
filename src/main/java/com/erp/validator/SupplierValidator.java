package com.erp.validator;

import com.erp.domain.Supplier;
import com.erp.exception.ValidationException;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

/**
 * Validator for Supplier (Fournisseur) entity
 * Validates business rules for suppliers
 */
@Component
public class SupplierValidator {

    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");

    /**
     * Validate supplier before creation
     * @param supplier Supplier to validate
     * @throws ValidationException if validation fails
     */
    public void validateForCreate(Supplier supplier) {
        if (supplier == null) {
            throw new ValidationException("Supplier cannot be null", "supplier", "REQUIRED");
        }

        if (supplier.getCode() == null || supplier.getCode().trim().isEmpty()) {
            throw new ValidationException("Supplier code is required", "code", "REQUIRED");
        }

        if (supplier.getCode().length() > 50) {
            throw new ValidationException("Supplier code must not exceed 50 characters", "code", "LENGTH_EXCEEDED");
        }

        if (supplier.getName() == null || supplier.getName().trim().isEmpty()) {
            throw new ValidationException("Supplier name is required", "name", "REQUIRED");
        }

        if (supplier.getEmail() != null && !supplier.getEmail().isEmpty()) {
            if (!EMAIL_PATTERN.matcher(supplier.getEmail()).matches()) {
                throw new ValidationException("Invalid email format", "email", "INVALID_FORMAT");
            }
        }

        if (supplier.getPaymentTermsDays() != null && supplier.getPaymentTermsDays() < 0) {
            throw new ValidationException("Payment delay must be non-negative", "paymentTermsDays", "INVALID_VALUE");
        }

        if (supplier.getPaymentTermsDays() != null && supplier.getPaymentTermsDays() > 365) {
            throw new ValidationException("Payment delay must not exceed 365 days", "paymentTermsDays", "INVALID_VALUE");
        }
    }

    /**
     * Validate supplier before update
     * @param supplier Supplier to validate
     * @throws ValidationException if validation fails
     */
    public void validateForUpdate(Supplier supplier) {
        validateForCreate(supplier);
    }

    /**
     * Validate supplier code is unique
     * @param code Supplier code
     * @param existingCount Number of existing suppliers with this code
     * @throws ValidationException if code is not unique
     */
    public void validateCodeUniqueness(String code, long existingCount) {
        if (existingCount > 0) {
            throw new ValidationException("Supplier code '" + code + "' already exists", "code", "DUPLICATE");
        }
    }
}
