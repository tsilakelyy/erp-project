package com.erp.exception;

import org.springframework.http.HttpStatus;
import java.util.*;

public class ValidationException extends ApplicationException {
    private final Map<String, String> fieldErrors;

    public ValidationException(String message) {
        super(message, "VALIDATION_ERROR", HttpStatus.BAD_REQUEST);
        this.fieldErrors = new HashMap<>();
    }

    public ValidationException(String message, String field, String error) {
        super(message, "VALIDATION_ERROR", HttpStatus.BAD_REQUEST);
        this.fieldErrors = new HashMap<>();
        this.fieldErrors.put(field, error);
    }

    public ValidationException(String message, Map<String, String> fieldErrors) {
        super(message, "VALIDATION_ERROR", HttpStatus.BAD_REQUEST);
        this.fieldErrors = fieldErrors != null ? fieldErrors : new HashMap<>();
    }

    public Map<String, String> getFieldErrors() {
        return fieldErrors;
    }

    public void addFieldError(String field, String error) {
        fieldErrors.put(field, error);
    }
}
