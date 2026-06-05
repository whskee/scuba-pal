SHELL := /bin/bash

# ONLY MODIFY VARIABLES IN THIS SECTION
NAME := scuba-pal
VERSION := 0.1.0
APP_IMAGE := $(NAME)-app:local
APP_PORT := 8080

# Names of subdirectories for different components
APP_DIR := $(NAME)-app
WEB_DIR := $(NAME)-web
MOBILE_DIR := $(NAME)-mobile
DOCS_DIR := $(NAME)-docs

# Database connection settings for local development and Docker
DB_URL ?= jdbc:postgresql://host.docker.internal:5432/scuba_pal
DB_USER ?= scuba_pal_runtime
DB_PASSWORD ?= scuba_pal

MEDIA_S3_REGION ?= us-west-2
MEDIA_S3_BUCKET ?= $(NAME)-user-media-test-817455142561-us-west-2-an
MAIL_HOST ?= host.docker.internal
MAIL_PORT ?= 1025

.PHONY: help
help:
	@echo "ScubaPal commands:"
	@echo ""
	@echo "  make app-dev       Run Spring Boot App in development mode"
	@echo "  make app-prod      Run Spring Boot App in production mode"
	@echo "  make app-test      Run backend tests"
	@echo "  make app-build     Build backend"
	@echo "  make app-docker-build  Build backend Docker image"
	@echo "  make app-docker-run    Run backend Docker image locally"
	@echo "  make app-health        Check backend health endpoint"
	@echo "  make app-readiness     Check backend readiness endpoint"
	@echo ""
	@echo "  make db-up         Start local database"
	@echo "  make db-down       Stop local database"
	@echo ""
	@echo "  make web-dev       Run Next.js web app"
	@echo "  make web-build     Build Next.js web app"
	@echo ""
	@echo "  make mobile-dev    Run Expo mobile app"
	@echo "  make mobile-openapi-generate  Generate OpenAPI client for mobile app"
	@echo ""
	@echo "  make docs-dev      Run Astro docs"
	@echo "  make docs-build    Build Astro docs"
	@echo ""
	@echo "  make test          Run all tests"
	@echo "  make clean         Clean build artifacts"

.PHONY: app-reset
app-reset:
	cd $(APP_DIR) && docker compose down -v
	cd $(APP_DIR) && docker compose up -d

.PHONY: app-dev
app-dev:
	cd $(APP_DIR) && SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run

.PHONY: app-prod
app-prod:
	cd $(APP_DIR) && SPRING_PROFILES_ACTIVE=prod ./mvnw spring-boot:run

.PHONY: app-test
app-test:
	cd $(APP_DIR) && ./mvnw test

.PHONY: app-build
app-build:
	cd $(APP_DIR) && ./mvnw clean package

.PHONY: flyway-clean
flyway-clean:
	cd $(APP_DIR) && ./mvnw flyway:clean

.PHONY: db-up
db-up:
	cd $(APP_DIR) && docker compose up -d

.PHONY: db-down
db-down:
	cd $(APP_DIR) && docker compose down

.PHONY: mobile-dev
mobile-dev:
	cd $(MOBILE_DIR) && npm run start

.PHONY: mobile-openapi-generate
mobile-openapi-generate:
	cd $(MOBILE_DIR) && npm run generate:openapi

.PHONY: docs-dev
docs-dev:
	cd $(DOCS_DIR) && npm run dev

.PHONY: docs-build
docs-build:
	cd $(DOCS_DIR) && npm run build

.PHONY: docusaurus-create
docusaurus-create:
	cd $(DOCS_DIR) && npx create-docusaurus@latest . classic

.PHONY: docusaurus-dev
docusaurus-dev:
	cd $(DOCS_DIR) && npm run dev

.PHONY: docusaurus-build
docusaurus-build:
	cd $(DOCS_DIR) && npm run build

.PHONY: test
test: app-test
	@echo "All tests complete."

.PHONY: clean
clean:
	cd $(APP_DIR) && ./mvnw clean
	rm -rf $(WEB_DIR)/.next
	rm -rf $(DOCS_DIR)/dist
	rm -rf $(MOBILE_DIR)/.expo

.PHONY: openapi-generator-typescript-axios
openapi-generator-typescript-axios:
	openapi-generator generate \
	-i http://localhost:8080/v3/api-docs \
	-g typescript-axios \
	-o $(MOBILE_DIR)/src/api/generated

.PHONY: app-docker-build
app-docker-build:
	docker build -t $(APP_IMAGE) -f $(APP_DIR)/Dockerfile $(APP_DIR)

.PHONY: app-docker-run
app-docker-run:
	docker run --rm -p $(APP_PORT):8080 \
		-e SPRING_PROFILES_ACTIVE=dev \
		-e DB_URL="$(DB_URL)" \
		-e DB_USER="$(DB_USER)" \
		-e DB_PASSWORD="$(DB_PASSWORD)" \
		-e SPRING_MAIL_HOST="$(MAIL_HOST)" \
		-e SPRING_MAIL_PORT="$(MAIL_PORT)" \
		-e MEDIA_S3_REGION="$(MEDIA_S3_REGION)" \
		-e MEDIA_S3_BUCKET="$(MEDIA_S3_BUCKET)" \
		-e MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS="always" \
		$(APP_IMAGE)

app-docker-run-prod:
	docker run --rm -p $(APP_PORT):8080 \
		-e SPRING_PROFILES_ACTIVE=prod \
		-e DB_URL="$(DB_URL)" \
		-e DB_USER="$(DB_USER)" \
		-e DB_PASSWORD="$(DB_PASSWORD)" \
		-e SPRING_MAIL_HOST="$(MAIL_HOST)" \
		-e SPRING_MAIL_PORT="$(MAIL_PORT)" \
		-e MEDIA_S3_REGION="$(MEDIA_S3_REGION)" \
		-e MEDIA_S3_BUCKET="$(MEDIA_S3_BUCKET)" \
		-e MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS="always" \
		$(APP_IMAGE)

# 	cd $(APP_DIR) &&APP_DIR
# 	./mvnw clean package -DskipTests
# 	docker build -t scubapal-app:local .
# 	docker run --rm -p 8080:8080 \
# 		-e SPRING_PROFILES_ACTIVE=prod \
# 		-e DB_URL="$(DB_URL)" \
# 		-e DB_USER="$(DB_USER)" \
# 		-e DB_PASSWORD="$(DB_PASSWORD)" \
# 		-e APP_BASE_URL="http://localhost:8080" \
# 		scubapal-app:local

.PHONY: app-health
app-health:
	curl -i http://localhost:$(APP_PORT)/actuator/health

.PHONY: app-readiness
app-readiness:
	curl -i http://localhost:$(APP_PORT)/actuator/health/readiness

.PHONY: app-liveness
app-liveness:
	curl -i http://localhost:$(APP_PORT)/actuator/health/liveness
