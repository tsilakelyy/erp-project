package com.erp.exception;

import org.springframework.http.HttpStatus;

public class ConflictException extends ApplicationException {
    public ConflictException(String message) {
        super(message, "CONFLICT", HttpStatus.CONFLICT);
    }

    public ConflictException(String message, String resource) {
        super(message + " for resource: " + resource, "CONFLICT", HttpStatus.CONFLICT);
    }
}
