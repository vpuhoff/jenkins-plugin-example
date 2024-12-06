# Makefile for Jenkins Plugin Development

# Configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Project structure
PROJECT_ROOT := $(shell pwd)
SETUP_ENV_SCRIPT := $(PROJECT_ROOT)/setup_and_check_environment.sh
BUILD_RUN_SCRIPT := $(PROJECT_ROOT)/viewfilter/build_and_run.sh

.PHONY: help setup-env build run clean all

help:
	@echo "Jenkins Plugin Development Makefile"
	@echo ""
	@echo "Available commands:"
	@echo "  make setup-env   - Check and setup development environment"
	@echo "  make build       - Build the plugin"
	@echo "  make run         - Build and run Jenkins with the plugin"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make all         - Setup environment, build and run"
	@echo ""
	@echo "Usage example:"
	@echo "  make all         # Complete setup and deployment"

setup-env:
	@echo "Setting up development environment..."
	@if [ ! -f "$(SETUP_ENV_SCRIPT)" ]; then \
		echo "Error: Environment setup script not found at $(SETUP_ENV_SCRIPT)"; \
		exit 1; \
	fi
	@sudo $(SETUP_ENV_SCRIPT)

build:
	@echo "Building plugin..."
	cd viewfilter && mvn clean package

run:
	@echo "Building and running Jenkins with plugin..."
	@if [ ! -f "$(BUILD_RUN_SCRIPT)" ]; then \
		echo "Error: Build and run script not found at $(BUILD_RUN_SCRIPT)"; \
		exit 1; \
	fi
	@cd viewfilter && ./build_and_run.sh

clean:
	@echo "Cleaning build artifacts..."
	cd viewfilter && mvn clean
	rm -rf viewfilter/jenkins_home
	-docker rm -f jenkins-test
	-docker rmi jenkins/jenkins:lts

all: setup-env build run