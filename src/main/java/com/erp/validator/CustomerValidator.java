package com.erp.validator;

import com.erp.domain.Customer;
import com.erp.exception.ValidationException;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

/**
 * Validator for Customer entity
 * Validates business rules for customers
 */
@Component
public class CustomerValidator {

    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");

    /**
     * Validate customer before creation/update
     * @param customer Customer to validate
     * @throws ValidationException if validation fails
     */
    public void validate(Customer customer) {
        if (customer == null) {
            throw new ValidationException("Customer cannot be null", "customer", "REQUIRED");
        }

        if (customer.getCode() == null || customer.getCode().trim().isEmpty()) {
            throw new ValidationException("Customer code is required", "code", "REQUIRED");
        }

        if (customer.getCode().length() > 50) {
            throw new ValidationException("Customer code must not exceed 50 characters", "code", "LENGTH_EXCEEDED");
        }

        if (customer.getName() == null || customer.getName().trim().isEmpty()) {
            throw new ValidationException("Customer name is required", "name", "REQUIRED");
        }

        if (customer.getEmail() != null && !customer.getEmail().isEmpty()) {
            if (!EMAIL_PATTERN.matcher(customer.getEmail()).matches()) {
                throw new ValidationException("Invalid email format", "email", "INVALID_FORMAT");
            }
        }

        if (customer.getPaymentTermsDays() != null && customer.getPaymentTermsDays() < 0) {
            throw new ValidationException("Payment delay must be non-negative", "paymentTermsDays", "INVALID_VALUE");
        }

        if (customer.getPaymentTermsDays() != null && customer.getPaymentTermsDays() > 365) {
            throw new ValidationException("Payment delay must not exceed 365 days", "paymentTermsDays", "INVALID_VALUE");
        }
    }
}
