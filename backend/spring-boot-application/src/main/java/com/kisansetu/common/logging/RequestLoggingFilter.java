package com.kisansetu.common.logging;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

@Component
public class RequestLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);
    private static final String CORRELATION_ID_HEADER = "X-Correlation-ID";
    private static final String CORRELATION_ID_MDC_KEY = "correlationId";

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        long startTime = System.currentTimeMillis();
        String correlationId = request.getHeader(CORRELATION_ID_HEADER);
        if (!StringUtils.hasText(correlationId)) {
            correlationId = UUID.randomUUID().toString().substring(0, 8);
        }

        MDC.put(CORRELATION_ID_MDC_KEY, correlationId);
        response.setHeader(CORRELATION_ID_HEADER, correlationId);

        try {
            log.info("Incoming Request: [{} {}] from IP: {}",
                    request.getMethod(),
                    request.getRequestURI(),
                    request.getRemoteAddr());

            filterChain.doFilter(request, response);

            long duration = System.currentTimeMillis() - startTime;
            log.info("Completed Request: [{} {}] status: {} in {}ms",
                    request.getMethod(),
                    request.getRequestURI(),
                    response.getStatus(),
                    duration);
        } finally {
            MDC.remove(CORRELATION_ID_MDC_KEY);
        }
    }
}
