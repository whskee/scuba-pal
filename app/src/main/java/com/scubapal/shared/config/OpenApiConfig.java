package com.scubapal.shared.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI scubaPalOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("ScubaPal API")
                        .version("v1")
                        .description("Authentication, users, posts, messaging, notifications, dive locations, and learn content. Authenticated API endpoints currently use HTTP Basic auth.")
                        .contact(new Contact()
                                .name("Chinmaya Bidkar")
                                .email("chinmayabidkar@hotmail.com"))
                        .license(new License().name("Internal project")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Local"),
                        new Server().url("https://api.scubapal.com").description("Production")))
                .addSecurityItem(new SecurityRequirement().addList("basicAuth"))
                .components(new Components()
                        .addSecuritySchemes("basicAuth", new SecurityScheme()
                                .name("basicAuth")
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("basic")));
    }
}
