<h1 align="center">
  <!-- <img src="./assets/logo.png" width="66" height="66" alt="logo" title="logo" /> -->
  <img src="./assets/logo/2026-05-23/scubapal-manta-logo-navbar-header.png" width="44" height="44" alt="logo" title="logo" />
  Scuba Pal
</h1>

Scuba Pal is a platform connecting divers to dive deep, and connect deeper. Access [documentation](https://whskee.github.io/scuba-pal) on GitHub Pages

<h3 align="center">
  <a href="https://stackshare.io">Stack</a>
</h3>

<!-- [![My Skills](https://skillicons.dev/icons?i=postman,postgresql&theme=light)](https://skillicons.dev) -->
<p align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=java,spring,postgresql,postman,typescript,javascript,html,css,docker,aws&theme=light" />
  </a>
</p>

<p align="center">
  <!-- <img src="./assets/icons/stack/flyway.png" width="48" height="48" alt="Flyway" title="Flyway" /> -->
  <a href="https://www.thymeleaf.org" title="Go to Thymeleaf">
    <img src="./assets/icons/stack/thymeleaf.svg" width="48" height="48" alt="Thymeleaf" title="Thymeleaf" />
  </a>
  <a href="https://www.openapis.org" title="Go to OpenAPI">
    <img src="./assets/icons/stack/openapi.svg" width="48" height="48" alt="OpenAPI" title="OpenAPI" />
  </a>
  <a href="https://swagger.io/specification" title="Go to Swagger">
    <img src="./assets/icons/stack/swagger.png" width="48" height="48" alt="Swagger" title="Swagger" />
  </a>
  <img src="./assets/icons/stack/aws-s3.png" width="48" height="48" alt="AWS S3" title="AWS S3" />
  <!-- <img src="./assets/icons/stack/aws-rds.png" width="48" height="48" alt="AWS RDS" title="AWS RDS" /> -->
</p>

Full-stack Java Spring Boot social app for scuba divers, featuring a [Thymeleaf](https://www.thymeleaf.org) web frontend, REST APIs, authentication, profiles, posts, messaging, notifications, dive locations, PostgreSQL/Flyway migrations, and OpenAPI docs for native/mobile clients.


|                Domain                |                              Core                              |           Tools           |
| :----------------------------------: | :------------------------------------------------------------: | :-----------------------: |
| [Documentation](https://diataxis.fr) |                        Astro Starlight                         |                           |
|                 Auth                 |                  Spring Security, Validation                   |                           |
|               Storage                |                             AWS S3                             |                           |
|               Database               |             PostgreSQL, Flyway migrations, AWS RDS             | pgAdmin4, dbdiagram, DBML |
|               Backend                |           Java 25, Spring Boot 3.3, Spring Security,           |                           |
|   [API](https://www.openapis.org)    | REST, OpenAPI, [Swagger UI](https://swagger.io/specification)  |          Postman          |
|                 Web                  |                     Thymeleaf, Spring Web                      |                           |
|      [Mobile](https://expo.dev)      | React Native Expo (TypeScript OpenAPI client generation Axios) |     OpenAPI Generator     |
|             Local infra              |                    Docker, pgAdmin, Mailpit                    |                           |
|   [Cloud](https://aws.amazon.com/)   |                        AWS S3, RDS, EC2                        |                           |
|    [CI/CD](https://12factor.net)     |      GitHub Workflows, [Fastlane](https://fastlane.tools)      |                           |



Backend

| Domain          | Framework                                            | Tool                                                                                           |
| --------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Auth            | Spring Security, Validation                          |                                                                                                |
| API             | [Spring Doc](https://springdoc.org/#google_vignette) | [![api](https://skillicons.dev/icons?i=postman&theme=light)](https://skillicons.dev)           |
| ORM             | Spring Data JPA                                      |                                                                                                |
| Storage         | AWS S3                                               |                                                                                                |
| Database        | AWS RDS                                              | [![db](https://skillicons.dev/icons?i=postgresql,pgadmin&theme=light)](https://skillicons.dev) |
| Mailing         | Mailpit Local                                        |                                                                                                |
| Version Control | GitHub                                               |                                                                                                |
| Automation      | GitHub Workflows, Fastlane                           | [![db](https://skillicons.dev/icons?i=github&theme=light)](https://skillicons.dev)             |

### Tools

<p align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=github,postgresql,postman,figma&theme=light" />
  </a>
  <a href="https://visualvm.github.io" title="Go to VisualVM">
    <img src="./assets/icons/stack/visualvm.png" width="48" height="48" alt="VisualVM" title="VisualVM" />
  </a>
</p>

<!-- [![VisualVM](./assets/icons/stack/visualvm.png)](https://visualvm.github.io) -->

|  Domain   |                  Name                  |
| :-------: | :------------------------------------: |
|    IDE    |            vscode, DataGrip            |
|   UI/UX   |     [Figma](https://www.figma.com)     |
| Database  |      dbdiagram, pgAdmin, DataGrip      |
|    API    |                Postman                 |
| Profiling | [VisualVM](https://visualvm.github.io) |

---

## Start
- [Spring Initializr](https://start.spring.io)
- [Vaadin Start](https://start.vaadin.com/app)
- [OpenAPI Generator](https://github.com/openapitools/openapi-generator)
- [Generate DBML](https://dbml.dbdiagram.io/home)

## Links for local testing
- [Scuba Pal App](http://localhost:8080)
  - [Swagger](http://localhost:8080/swagger-ui/index.html)
  - [OpenAPI JSON](http://localhost:8080/v3/api-docs)
- [Scuba Pal App](http://192.168.0.251:8080) (on other devices)
- [pgAdmin](http://localhost:5050)
- [Mailpit](http://localhost:8025)

---

# ✅ To-do
- [ ] [Fail on missing .env variables](https://www.youtube.com/watch?v=6hAGbp8I5ow)
- [ ] Add openapi-generator to npm mobile
- [ ] [Git History](docs/src/content/docs/reference/git-history.md)

# Resources
1. [Spring Data JPA](https://docs.spring.io/spring-data/jpa/reference/jpa.html)


```bash
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/health/readiness
curl -i http://localhost:8080/actuator/health/readiness
```




# Diagramming
1. [Graphviz](https://graphviz.org)
2. [PlantUML](https://plantuml.com)
3. [DBDiagram]
4. [Mermaid]
