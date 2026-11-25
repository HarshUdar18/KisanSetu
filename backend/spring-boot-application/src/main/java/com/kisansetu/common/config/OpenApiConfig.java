package com.kisansetu.common.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Value("${server.port:8080}")
    private String serverPort;

    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "BearerAuth";

        return new OpenAPI()
                .info(new Info()
                        .title("KisanSetu Agricultural Supply Chain Platform API")
                        .version("v1.0.0")
                        .description("Direct Farmer-to-Customer & Bulk Buyer supply chain ecosystem with dynamic pricing, hub tracking, and automated settlement.")
                        .contact(new Contact()
                                .name("KisanSetu Platform Engineering")
                                .email("engineering@kisansetu.com")
                                .url("https://kisansetu.com"))
                        .license(new License().name("Apache 2.0").url("https://springdoc.org")))
                .servers(List.of(
                        new Server().url("http://localhost:" + serverPort).description("Local Development Server"),
                        new Server().url("http://10.0.2.2:" + serverPort).description("Android Emulator Host Loopback")
                ))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("Enter your JWT token in the format: Bearer <token>")));
    }
}
