package com.erp.exception;

import org.springframework.http.HttpStatus;

public class ResourceNotFoundException extends ApplicationException {
    public ResourceNotFoundException(String resourceName, Long id) {
        super(resourceName + " not found with ID: " + id, "NOT_FOUND", HttpStatus.NOT_FOUND);
    }

    public ResourceNotFoundException(String resourceName, String field, String value) {
        super(resourceName + " not found with " + field + ": " + value, "NOT_FOUND", HttpStatus.NOT_FOUND);
    }

    public ResourceNotFoundException(String message) {
        super(message, "NOT_FOUND", HttpStatus.NOT_FOUND);
    }
}
