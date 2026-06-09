SHELL := /bin/bash

NAME := scubapal
COMPOSE_FILE := ../compose.yaml
COMPOSE_ENV_FILE := ../.env
LOCAL_DB_URL ?= jdbc:postgresql://localhost:5432/${NAME}
LOCAL_DB_USER ?= ${NAME}_runtime
LOCAL_DB_PASSWORD ?= ${NAME}
LOCAL_SMTP_HOST ?= localhost
LOCAL_SMTP_PORT ?= 1025
IMAGE_NAME := ${NAME}-app:local

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make run      	- run Spring Boot (default: development mode)"
	@echo "  make dev      	- run Spring Boot in development mode"
	@echo "  make prod     	- run Spring Boot in production mode"
	@echo "  make test     	- run tests"
	@echo "  make build    	- compile project"
	@echo "  make package  	- create jar"
	@echo "  make clean    	- clean build files"
	@echo "  make compose-up  	- start Docker containers"
	@echo -e "\n======================== GENERATORS ========================"
	@echo "  make openapi-generate		- generate OpenAPI clients"
	@echo "  make create-javadoc		- create Javadoc"
	@echo "  make create-astro-docs	- create Astro documentation"
	@echo -e "\n======================== DOCUMENTATION ========================"
	@echo "  make open-astro-docs		- open Astro documentation"



.PHONY: run
run: dev


.PHONY: dev
dev:
	DB_URL="${LOCAL_DB_URL}" DB_USER="${LOCAL_DB_USER}" DB_PASSWORD="${LOCAL_DB_PASSWORD}" SMTP_HOST="${LOCAL_SMTP_HOST}" SMTP_PORT="${LOCAL_SMTP_PORT}" SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run


.PHONY: prod
prod:
	SPRING_PROFILES_ACTIVE=prod ./mvnw spring-boot:run


.PHONY: test
test:
	./mvnw test


.PHONY: build
build:
	./mvnw clean compile


# .PHONY: app-build
# app-build:
# 	cd $(APP_DIR) && ./mvnw clean package

.PHONY: build-docker
build-docker:
	docker build -t ${IMAGE_NAME} .


.PHONY: package
package:
	./mvnw clean package


.PHONY: flyway-clean
flyway-clean:
	DB_URL="${LOCAL_DB_URL}" DB_USER="${LOCAL_DB_USER}" DB_PASSWORD="${LOCAL_DB_PASSWORD}" SPRING_PROFILES_ACTIVE=dev ./mvnw flyway:clean


.PHONY: clean
clean:
	./mvnw clean


.PHONY: compose-pull
compose-pull:
	docker compose --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) pull


.PHONY: compose-up
compose-up:
	docker compose --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) up -d


.PHONY: compose-down
compose-down:
	docker compose --env-file $(COMPOSE_ENV_FILE) -f $(COMPOSE_FILE) down


# ======================== GENERATORS ========================

.PHONY: mailpit
mailpit:
	open http://localhost:8025


.PHONY: openapi-generate
openapi-generate:
	./mvnw openapi-generator:generate -DgeneratorName=spring -DinputSpec=src/main/resources/api.yaml -Doutput=generated


.PHONY: create-javadoc
create-javadoc:
	./mvnw javadoc:javadoc
