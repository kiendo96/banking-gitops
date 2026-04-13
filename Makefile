###############################################################################
# GitOps Makefile - Root Orchestrator
###############################################################################

SHELL := /bin/bash

INFRA_COMPONENTS := vault external-secrets jenkins harbor postgres redis rabbitmq kong
APP_COMPONENTS   := frontend account-service auth-service notification-service transfer-service
ALL_COMPONENTS   := $(INFRA_COMPONENTS) $(APP_COMPONENTS)

# Default environment
ENV ?= dev

.PHONY: all repo-add generate clean $(ALL_COMPONENTS)

all: generate

repo-add:
	@echo "📦 Adding Helm repositories..."
	helm repo add jenkins https://charts.jenkins.io 2>/dev/null || true
	helm repo add harbor https://helm.goharbor.io 2>/dev/null || true
	helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
	helm repo add kong https://charts.konghq.com 2>/dev/null || true
	helm repo add hashicorp https://helm.releases.hashicorp.com 2>/dev/null || true
	helm repo add external-secrets https://charts.external-secrets.io 2>/dev/null || true
	helm repo update

generate: repo-add
	@for service in $(ALL_COMPONENTS); do \
		echo "🛠️  Generating for $$service (ENV=$(ENV))..."; \
		$(MAKE) -C $$service generate ENV=$(ENV); \
	done

clean:
	@for service in $(ALL_COMPONENTS); do \
		echo "🧹 Cleaning $$service (ENV=$(ENV))..."; \
		$(MAKE) -C $$service clean ENV=$(ENV); \
	done

# Individual targets for convenience
$(ALL_COMPONENTS): repo-add
	@$(MAKE) -C $@ generate ENV=$(ENV)
