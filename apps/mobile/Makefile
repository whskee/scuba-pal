SHELL := /bin/bash

.PHONY: help dev ios android web install clean doctor

help:
	@echo "Available commands:"
	@echo "  make dev      - start Expo"
	@echo "  make ios      - start Expo iOS"
	@echo "  make android  - start Expo Android"
	@echo "  make web      - start Expo web"
	@echo "  make install  - install dependencies"
	@echo "  make doctor   - check Expo project health"
	@echo "  make clean    - clear Expo cache"

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

clean:
	npx expo start --clear