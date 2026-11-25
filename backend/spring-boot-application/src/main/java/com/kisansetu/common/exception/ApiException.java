package com.kisansetu.common.exception;

import org.springframework.http.HttpStatus;

public class ApiException extends RuntimeException {
    private final String code;
    private final HttpStatus status;

    public ApiException(String code, String message, HttpStatus status) {
        super(message);
        this.code = code;
        this.status = status;
    }

    public ApiException(String message, HttpStatus status) {
        super(message);
        this.code = status.name();
        this.status = status;
    }

    public ApiException(String message, Throwable cause, HttpStatus status) {
        super(message, cause);
        this.code = status.name();
        this.status = status;
    }

    public String getCode() {
        return code;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
