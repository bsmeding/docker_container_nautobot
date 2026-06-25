.PHONY: help build list build-1x build-2x build-3x build-dev

# Default values
REGISTRY ?= bsmeding
IMAGE_NAME ?= nautobot
PYTHON_VER ?= 3.12

help: ## Show this help message
	@echo "Nautobot Docker Image Build System"
	@echo ""
	@echo "Usage: make [target] [VERSION=x.y.z] [PYTHON_VER=3.12]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make build VERSION=3.0.2"
	@echo "  make build-3x VERSION=3.0.2 PYTHON_VER=3.11"
	@echo "  make build-2x VERSION=2.4.19"
	@echo "  make build-dev VERSION=3.0.2          # local -dev image with requirements-dev.txt"
	@echo "  make build-dev BASE_IMAGE=bsmeding/nautobot:stable"
	@echo "  make list"

list: ## List available versions
	@./build.sh --list

build: ## Build image for specified VERSION (required: VERSION=x.y.z)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Example: make build VERSION=3.0.2"; \
		exit 1; \
	fi
	@./build.sh -p $(PYTHON_VER) -r $(REGISTRY) -n $(IMAGE_NAME) $(VERSION)

build-1x: ## Build Nautobot 1.x image (required: VERSION=1.x.x)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Example: make build-1x VERSION=1.6.32"; \
		exit 1; \
	fi
	@./build.sh -p $(PYTHON_VER) -r $(REGISTRY) -n $(IMAGE_NAME) $(VERSION)

build-2x: ## Build Nautobot 2.x image (required: VERSION=2.x.x)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Example: make build-2x VERSION=2.4.19"; \
		exit 1; \
	fi
	@./build.sh -p $(PYTHON_VER) -r $(REGISTRY) -n $(IMAGE_NAME) $(VERSION)

build-3x: ## Build Nautobot 3.x image (required: VERSION=3.x.x)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Example: make build-3x VERSION=3.0.2"; \
		exit 1; \
	fi
	@./build.sh -p $(PYTHON_VER) -r $(REGISTRY) -n $(IMAGE_NAME) $(VERSION)

build-dev: ## Build local -dev image layering requirements-dev.txt (VERSION=x.y.z or BASE_IMAGE=...)
	@if [ -z "$(VERSION)" ] && [ -z "$(BASE_IMAGE)" ]; then \
		echo "Error: provide VERSION or BASE_IMAGE. Examples:"; \
		echo "  make build-dev VERSION=3.0.2"; \
		echo "  make build-dev BASE_IMAGE=bsmeding/nautobot:stable"; \
		exit 1; \
	fi
	@./build.sh --dev -p $(PYTHON_VER) -r $(REGISTRY) -n $(IMAGE_NAME) \
		$(if $(BASE_IMAGE),-b $(BASE_IMAGE),) \
		$(if $(TAG),-t $(TAG),) \
		$(VERSION)

build-all-3x: ## Build all 3.x versions
	@echo "Building all Nautobot 3.x versions..."
	@./build.sh -p 3.10 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.0
	@./build.sh -p 3.11 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.0
	@./build.sh -p 3.12 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.0
	@./build.sh -p 3.10 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.1
	@./build.sh -p 3.11 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.1
	@./build.sh -p 3.12 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.1
	@./build.sh -p 3.10 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.2
	@./build.sh -p 3.11 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.2
	@./build.sh -p 3.12 -r $(REGISTRY) -n $(IMAGE_NAME) 3.0.2

