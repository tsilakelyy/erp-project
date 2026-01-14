package com.erp.exception;

import org.springframework.http.HttpStatus;

public class AuthorizationException extends ApplicationException {
    private final String resource;
    private final String action;
    private final String user;

    public AuthorizationException(String message) {
        super(message, "UNAUTHORIZED", HttpStatus.FORBIDDEN);
        this.resource = null;
        this.action = null;
        this.user = null;
    }

    public AuthorizationException(String message, String resource, String action, String user) {
        super(message, "UNAUTHORIZED", HttpStatus.FORBIDDEN);
        this.resource = resource;
        this.action = action;
        this.user = user;
    }

    public String getResource() {
        return resource;
    }

    public String getAction() {
        return action;
    }

    public String getUser() {
        return user;
    }
}
