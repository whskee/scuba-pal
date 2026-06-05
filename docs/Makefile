SHELL := /bin/bash

.PHONY: help create create-docs run clear

help:
	@echo "Available commands:"
	@echo "  make create    	- create a new Docusaurus project in the current directory"
	@echo "  make create-docs	- create a new Docusaurus project in the 'docs' directory"
	@echo "  make run      	- run Docusaurus in development mode"
	@echo "  make clear    	- clear Docusaurus build artifacts and cache"

run:
	npm run start
# 	npx docusaurus start

clear:
	npm run clear

create:
	npx create-docusaurus@latest . classic

create-docs:
	npx create-docusaurus@latest docs classic

