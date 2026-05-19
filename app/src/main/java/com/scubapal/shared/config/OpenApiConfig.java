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

// @OpenAPIDefinition(
//     info = @Info(
//         title = "ScubaPal API",
//         version = "1.0",
//         description = "API documentation for ScubaPal, the social platform for scuba divers."
//     )
// )

// @Configuration
// public class OpenApiConfig {

//     @Bean
//     public OpenAPI scubaPalOpenAPI() {
//         return new OpenAPI()
//                 .info(new Info()
//                         .title("Scuba Pal API")
//                         .version("v1")
//                         .description("OpenAPI specification for Scuba Pal authentication, users, posts, profiles, dive locations, and admin endpoints.")
//                         .license(new License().name("Internal project")));
//     }
// }

@Configuration
public class OpenApiConfig {

        @Bean
        public OpenAPI scubaPalOpenAPI() {
                return new OpenAPI()

                                // 🔹 API Info (what you already had, improved)
                                .info(new Info()
                                                .title("ScubaPal API")
                                                .version("v1")
                                                .description("Authentication, users, posts, messaging, notifications, dive locations, learn content")
                                                .contact(new Contact()
                                                                .name("Chinmaya Bidkar")
                                                                .email("chinmayabidkar@hotmail.com"))
                                                .license(new License()
                                                                .name("Internal project")))

                                // 🔹 Server (fixes dropdown)
                                .servers(List.of(
                                                new Server().url("http://localhost:8080").description("Local"),
                                                new Server().url("https://api.scubapal.com").description("Production")))

                                // 🔹 Security (VERY IMPORTANT)
                                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
                                .components(new Components()
                                                .addSecuritySchemes("bearerAuth",
                                                                new SecurityScheme()
                                                                                .name("bearerAuth")
                                                                                .type(SecurityScheme.Type.HTTP)
                                                                                .scheme("bearer")
                                                                                .bearerFormat("JWT")));
        }
}
