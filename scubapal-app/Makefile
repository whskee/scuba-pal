SHELL := /bin/bash

IMAGE_NAME := scuba-pal-app:local
APP_PORT := 8080
DB_URL ?= jdbc:postgresql://host.docker.internal:5432/scuba_pal
DB_USER ?= scuba_pal_runtime
DB_PASSWORD ?= scuba_pal
MEDIA_S3_REGION ?= us-west-2
MEDIA_S3_BUCKET ?= scuba-pal-user-media-test-817455142561-us-west-2-an
MAIL_HOST ?= host.docker.internal
MAIL_PORT ?= 1025

.PHONY: help dev prod test build clean package compose-up compose-down compose-pull mailpit openapi-generate create-javadoc create-astro-docs open-astro-docs flyway-clean

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


run:
	SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run

dev:
	SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run

prod:
	SPRING_PROFILES_ACTIVE=prod ./mvnw spring-boot:run

test:
	./mvnw test

build:
	./mvnw clean compile


# .PHONY: app-build
# app-build:
# 	cd $(APP_DIR) && ./mvnw clean package

build-docker:
	docker build -t scuba-pal-app:local .

package:
	./mvnw clean package

flyway-clean:
	SPRING_PROFILES_ACTIVE=dev ./mvnw flyway:clean

clean:
	./mvnw clean

compose-pull:
	docker compose pull

compose-up:
	docker-compose up -d

compose-down:
	docker compose down

# ======================== GENERATORS ========================
mailpit:
	open http://localhost:8025

openapi-generate:
	./mvnw openapi-generator:generate -DgeneratorName=spring -DinputSpec=src/main/resources/api.yaml -Doutput=generated

create-javadoc:
	./mvnw javadoc:javadoc

