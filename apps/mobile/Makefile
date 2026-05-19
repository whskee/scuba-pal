SHELL := /bin/bash

.PHONY: help dev ios android web install clean doctor typecheck generate-api

help:
	@echo "Available commands:"
	@echo "  make dev          - start Expo with cleared cache"
	@echo "  make ios          - start Expo iOS"
	@echo "  make android      - start Expo Android"
	@echo "  make web          - start Expo web"
	@echo "  make install      - install dependencies"
	@echo "  make doctor       - check Expo project health"
	@echo "  make typecheck    - run TypeScript without emitting files"
	@echo "  make generate-api - regenerate TypeScript Axios client from Spring Boot OpenAPI"
	@echo "  make clean        - clear Expo cache"

dev:
	npx expo start -c

ios:
	npx expo start --ios

android:
	npx expo start --android

web:
	npx expo start --web

install:
	npm install

doctor:
	npx expo-doctor

typecheck:
	npm run typecheck

generate-api:
	curl http://localhost:8080/v3/api-docs -o openapi.json
	rm -rf src/api/generated
	npx @openapitools/openapi-generator-cli generate \
		-i ./openapi.json \
		-g typescript-axios \
		-o ./src/api/generated
	rm -f src/api/generated/git_push.sh

clean:
	npx expo start --clear
