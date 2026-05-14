SHELL := /bin/bash

API_DIR := apps/api
WEB_DIR := apps/web
MOBILE_DIR := apps/mobile
DOCS_DIR := apps/docs

.PHONY: help
help:
	@echo "TheWavs commands:"
	@echo ""
	@echo "  make api-dev       Run Spring Boot API"
	@echo "  make api-test      Run backend tests"
	@echo "  make api-build     Build backend"
	@echo "  make db-up         Start local database"
	@echo "  make db-down       Stop local database"
	@echo ""
	@echo "  make web-dev       Run Next.js web app"
	@echo "  make web-build     Build Next.js web app"
	@echo ""
	@echo "  make mobile-dev    Run Expo mobile app"
	@echo ""
	@echo "  make docs-dev      Run Astro docs"
	@echo "  make docs-build    Build Astro docs"
	@echo ""
	@echo "  make test          Run all tests"
	@echo "  make clean         Clean build artifacts"

.PHONY: api-dev
api-dev:
	cd $(API_DIR) && ./mvnw spring-boot:run

.PHONY: api-test
api-test:
	cd $(API_DIR) && ./mvnw test

.PHONY: api-build
api-build:
	cd $(API_DIR) && ./mvnw clean package

.PHONY: db-up
db-up:
	cd $(API_DIR) && docker compose up -d

.PHONY: db-down
db-down:
	cd $(API_DIR) && docker compose down

.PHONY: web-dev
web-dev:
	cd $(WEB_DIR) && npm run dev

.PHONY: web-build
web-build:
	cd $(WEB_DIR) && npm run build

.PHONY: mobile-dev
mobile-dev:
	cd $(MOBILE_DIR) && npm run start

.PHONY: docs-dev
docs-dev:
	cd $(DOCS_DIR) && npm run dev

.PHONY: docs-build
docs-build:
	cd $(DOCS_DIR) && npm run build

.PHONY: test
test: api-test
	@echo "All tests complete."

.PHONY: clean
clean:
	cd $(API_DIR) && ./mvnw clean
	rm -rf $(WEB_DIR)/.next
	rm -rf $(DOCS_DIR)/dist
	rm -rf $(MOBILE_DIR)/.expo