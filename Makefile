SHELL := /bin/bash

APP_DIR := apps/app
WEB_DIR := apps/web
MOBILE_DIR := apps/mobile
DOCS_DIR := apps/docs

.PHONY: help
help:
	@echo "ScubaPal commands:"
	@echo ""
	@echo "  make app-dev       Run Spring Boot App"
	@echo "  make app-test      Run backend tests"
	@echo "  make app-build     Build backend"
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

.PHONY: app-dev
app-dev:
	cd $(APP_DIR) && ./mvnw spring-boot:run

.PHONY: app-test
app-test:
	cd $(APP_DIR) && ./mvnw test

.PHONY: app-build
app-build:
	cd $(APP_DIR) && ./mvnw clean package

.PHONY: db-up
db-up:
	cd $(APP_DIR) && docker compose up -d

.PHONY: db-down
db-down:
	cd $(APP_DIR) && docker compose down

.PHONY: web-dev
web-dev:
	cd $(WEB_DIR) && npm run dev

.PHONY: web-build
web-build:
	cd $(WEB_DIR) && npm run build

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
	-o mobile/src/api/generated