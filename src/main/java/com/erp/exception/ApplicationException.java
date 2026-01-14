package com.erp.exception;

import org.springframework.http.HttpStatus;

public class ApplicationException extends RuntimeException {
    private final HttpStatus status;
    private final String errorCode;

    public ApplicationException(String message, HttpStatus status) {
        super(message);
        this.status = status;
        this.errorCode = "APP_ERROR";
    }

    public ApplicationException(String message, String errorCode, HttpStatus status) {
        super(message);
        this.status = status;
        this.errorCode = errorCode;
    }

    public ApplicationException(String message, Throwable cause, HttpStatus status) {
        super(message, cause);
        this.status = status;
        this.errorCode = "APP_ERROR";
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getErrorCode() {
        return errorCode;
    }
}
