SHELL := /bin/bash

.PHONY: help dev test build clean package compose-up compose-down compose-pull mailpit openapi-generate create-javadoc create-astro-docs open-astro-docs

help:
	@echo "Available commands:"
	@echo "  make dev      	- run Spring Boot"
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

# dev:
# 	./mvnw spring-boot:run

dev:
	SPRING_PROFILES_ACTIVE=dev ./mvnw spring-boot:run

test:
	./mvnw test

build:
	./mvnw clean compile

package:
	./mvnw clean package

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

# ======================== DOCUMENTATION ========================
# DOCUMENTATION_DIR := docs
create-astro-docs:
	npm create astro@latest -- --template starlight

open-astro-docs:
	open http://localhost:4321/scuba-pal-app && cd docs && npm run dev