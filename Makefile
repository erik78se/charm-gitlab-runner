# VARIABLES
export CHARM_NAME := gitlab-runner
export CHARM_BUILD_DIR := ./builds

# TARGETS
lint: ## Run linter

ifeq ("$(wildcard /usr/bin/shellcheck)", "")
$(error shellcheck was not found in path. Please install it.)
endif

ifeq "$(SCVER)" "1"
$(error Wrong version of shellcheck. Please use a \
shellcheck version lower than 0.5)
endif

	cd src
	shellcheck -x -s bash ./hooks/*
	shellcheck -x -s bash ./actions/*
	shellcheck -x -s bash ./lib/*

build: clean lint ## Build charm
# create backup of generic version
	mkdir -p $(CHARM_BUILD_DIR)/$(CHARM_NAME)
	cp -r src/* $(CHARM_BUILD_DIR)/$(CHARM_NAME)
	charm proof $(CHARM_BUILD_DIR)/$(CHARM_NAME)

clean: ## Remove .tox and build dirs
	find . -name '*~' -type f -delete
	rm -rf $(CHARM_BUILD_DIR)

# Display target comments in 'make help'
help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# SETTINGS
# Use one shell for all commands in a target recipe
.ONESHELL:
# Set default goal
.DEFAULT_GOAL := help
# Use bash shell in Make instead of sh
SHELL := /bin/bash
