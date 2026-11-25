package com.kisansetu.common.exception;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.Instant;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {
    private String code;
    private String message;
    private String requestId;
    private Instant timestamp;
    private Map<String, String> fieldErrors;

    public ErrorResponse() {
        this.timestamp = Instant.now();
    }

    public ErrorResponse(String code, String message, String requestId) {
        this.code = code;
        this.message = message;
        this.requestId = requestId;
        this.timestamp = Instant.now();
    }

    public ErrorResponse(String code, String message, String requestId, Map<String, String> fieldErrors) {
        this(code, message, requestId);
        this.fieldErrors = fieldErrors;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Instant timestamp) {
        this.timestamp = timestamp;
    }

    public Map<String, String> getFieldErrors() {
        return fieldErrors;
    }

    public void setFieldErrors(Map<String, String> fieldErrors) {
        this.fieldErrors = fieldErrors;
    }
}
