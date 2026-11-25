package com.kisansetu.common.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    private String getRequestId() {
        String reqId = MDC.get("correlationId");
        return reqId != null ? reqId : UUID.randomUUID().toString().substring(0, 8);
    }

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ErrorResponse> handleApiException(ApiException ex, HttpServletRequest request) {
        String reqId = getRequestId();
        log.warn("[{}] API Exception [{}]: {}", reqId, ex.getStatus(), ex.getMessage());
        ErrorResponse errorResponse = new ErrorResponse(
                ex.getCode() != null ? ex.getCode() : ex.getStatus().name(),
                ex.getMessage(),
                reqId
        );
        return new ResponseEntity<>(errorResponse, ex.getStatus());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException ex, HttpServletRequest request) {
        String reqId = getRequestId();
        Map<String, String> fieldErrors = new HashMap<>();
        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.put(fieldError.getField(), fieldError.getDefaultMessage());
        }
        log.warn("[{}] Validation failed for {}: {}", reqId, request.getRequestURI(), fieldErrors);

        ErrorResponse errorResponse = new ErrorResponse(
                "VALIDATION_ERROR",
                "Input validation failed for one or more fields",
                reqId,
                fieldErrors
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCredentials(BadCredentialsException ex, HttpServletRequest request) {
        String reqId = getRequestId();
        log.warn("[{}] Bad credentials attempt at {}: {}", reqId, request.getRequestURI(), ex.getMessage());
        ErrorResponse errorResponse = new ErrorResponse(
                "INVALID_CREDENTIALS",
                "Invalid phone/email or password provided",
                reqId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.UNAUTHORIZED);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(AccessDeniedException ex, HttpServletRequest request) {
        String reqId = getRequestId();
        log.warn("[{}] Access denied for {}: {}", reqId, request.getRequestURI(), ex.getMessage());
        ErrorResponse errorResponse = new ErrorResponse(
                "ACCESS_DENIED",
                "You do not have permission to access this resource",
                reqId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.FORBIDDEN);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex, HttpServletRequest request) {
        String reqId = getRequestId();
        ErrorResponse errorResponse = new ErrorResponse(
                "METHOD_NOT_ALLOWED",
                ex.getMessage(),
                reqId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.METHOD_NOT_ALLOWED);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex, HttpServletRequest request) {
        String reqId = getRequestId();
        log.error("[{}] Unhandled exception at {}: ", reqId, request.getRequestURI(), ex);
        ErrorResponse errorResponse = new ErrorResponse(
                "INTERNAL_SERVER_ERROR",
                "An unexpected server error occurred. Please contact KisanSetu support.",
                reqId
        );
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
