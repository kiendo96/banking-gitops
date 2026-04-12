###############################################################################
# GitOps Makefile - Helm Template Hydration & Kustomize Management
#
# Usage:
#   make all              # Generate all infra + apps
#   make all-infra        # Generate all infrastructure only
#   make all-apps         # Generate all microservices only
#
#   make jenkins          # Generate Jenkins manifests
#   make harbor           # Generate Harbor manifests
#   make postgres         # Generate Postgres HA manifests
#   make redis            # Generate Redis manifests
#   make rabbitmq         # Generate RabbitMQ manifests
#   make kong             # Generate Kong manifests
#
#   make frontend                # Generate frontend app
#   make account-service         # Generate account-service app
#   make auth-service            # Generate auth-service app
#   make notification-service    # Generate notification-service app
#   make transfer-service        # Generate transfer-service app
#
#   make clean                   # Clean ALL generated manifests
#   make clean-infra             # Clean all infra manifests
#   make clean-apps              # Clean all app manifests
#   make clean-jenkins           # Clean only Jenkins
#   make clean-frontend          # Clean only frontend
#   ... (clean-<component>)
#
#   make upgrade-jenkins         # Re-generate Jenkins (clean + generate)
#   make upgrade-frontend        # Re-generate frontend (clean + generate)
#   ... (upgrade-<component>)
#
#   make delete-jenkins          # Remove Jenkins from generated + kustomize base
#   make delete-frontend         # Remove frontend from generated + kustomize base
#   ... (delete-<component>)
#
#   make kustomize-base          # Rebuild kustomize/base/kustomization.yaml
###############################################################################

SHELL := /bin/bash

# ─── Directories ────────────────────────────────────────────────────────────────
HELM_RESOURCE_DIR  := helm-resource
KUSTOMIZE_GEN_DIR  := kustomize/base/generated
COMMON_CHART_DIR   := $(HELM_RESOURCE_DIR)/common-service-chart

# ─── Component lists ────────────────────────────────────────────────────────────
INFRA_COMPONENTS := vault external-secrets jenkins harbor postgres redis rabbitmq kong
APP_COMPONENTS   := frontend account-service auth-service notification-service transfer-service
ALL_COMPONENTS   := $(INFRA_COMPONENTS) $(APP_COMPONENTS)

# ─── Phony targets ──────────────────────────────────────────────────────────────
.PHONY: all all-infra all-apps \
        $(ALL_COMPONENTS) \
        clean clean-infra clean-apps $(addprefix clean-,$(ALL_COMPONENTS)) \
        $(addprefix upgrade-,$(ALL_COMPONENTS)) \
        $(addprefix delete-,$(ALL_COMPONENTS)) \
        kustomize-base repo-add

# ═════════════════════════════════════════════════════════════════════════════════
# GROUP TARGETS
# ═════════════════════════════════════════════════════════════════════════════════

all: all-infra all-apps kustomize-base
	@echo "✅ All components hydrated successfully."

all-infra: $(INFRA_COMPONENTS) kustomize-base
	@echo "✅ All infrastructure components hydrated."

all-apps: $(APP_COMPONENTS) kustomize-base
	@echo "✅ All application components hydrated."

# ═════════════════════════════════════════════════════════════════════════════════
# HELM REPO SETUP
# ═════════════════════════════════════════════════════════════════════════════════

repo-add:
	@echo "📦 Adding Helm repositories..."
	helm repo add jenkins https://charts.jenkins.io 2>/dev/null || true
	helm repo add harbor https://helm.goharbor.io 2>/dev/null || true
	helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
	helm repo add kong https://charts.konghq.com 2>/dev/null || true
	helm repo add hashicorp https://helm.releases.hashicorp.com 2>/dev/null || true
	helm repo add external-secrets https://charts.external-secrets.io 2>/dev/null || true
	helm repo update

# ═════════════════════════════════════════════════════════════════════════════════
# INFRASTRUCTURE COMPONENTS
# ═════════════════════════════════════════════════════════════════════════════════

vault: repo-add
	@echo "🔧 Hydrating Vault..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/vault
	helm template vault hashicorp/vault \
		-n vault \
		-f $(HELM_RESOURCE_DIR)/vault_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/vault
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/vault

external-secrets: repo-add
	@echo "🔧 Hydrating External Secrets Operator..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/external-secrets
	helm template external-secrets external-secrets/external-secrets \
		-n external-secrets \
		--set installCRDs=true \
		-f $(HELM_RESOURCE_DIR)/eso_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/external-secrets
	@echo "🔧 Removing CEL validations from CRDs to bypass local K8s validation budget limit..."
	@python3 -c 'import os, re; d="$(KUSTOMIZE_GEN_DIR)/external-secrets/external-secrets/templates/crds"; [open(os.path.join(d, f), "w").write(re.sub(r"(?m)^ *x-kubernetes-validations:.*\n(?:^ *-.*\n)+", "", open(os.path.join(d, f)).read())) for f in os.listdir(d) if f.endswith(".yaml")]'
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/external-secrets

jenkins: repo-add
	@echo "🔧 Hydrating Jenkins..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/jenkins
	helm template jenkins jenkins/jenkins \
		-n jenkins \
		-f $(HELM_RESOURCE_DIR)/jenkins_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/jenkins
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/jenkins

harbor: repo-add
	@echo "🔧 Hydrating Harbor..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/harbor
	helm template harbor harbor/harbor \
		-n harbor \
		-f $(HELM_RESOURCE_DIR)/harbor_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/harbor
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/harbor

postgres: repo-add
	@echo "🔧 Hydrating Postgres HA..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/postgres
	helm template postgres bitnami/postgresql-ha \
		-n data \
		-f $(HELM_RESOURCE_DIR)/postgres_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/postgres
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/postgres

redis: repo-add
	@echo "🔧 Hydrating Redis..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/redis
	helm template redis bitnami/redis \
		-n data \
		-f $(HELM_RESOURCE_DIR)/redis_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/redis
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/redis

rabbitmq: repo-add
	@echo "🔧 Hydrating RabbitMQ..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/rabbitmq
	helm template rabbitmq bitnami/rabbitmq \
		-n data \
		-f $(HELM_RESOURCE_DIR)/rabbitmq_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/rabbitmq
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/rabbitmq

kong: repo-add
	@echo "🔧 Hydrating Kong..."
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/kong
	helm template kong kong/kong \
		-n kong \
		-f $(HELM_RESOURCE_DIR)/kong_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/kong
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/kong

# ═════════════════════════════════════════════════════════════════════════════════
# APPLICATION COMPONENTS (using common-service-chart)
# ═════════════════════════════════════════════════════════════════════════════════

frontend:
	@echo "🚀 Hydrating frontend..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/frontend
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/frontend
	helm template frontend $(COMMON_CHART_DIR) \
		-n apps \
		-f $(HELM_RESOURCE_DIR)/apps/frontend_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/frontend
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/frontend

account-service:
	@echo "🚀 Hydrating account-service..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/account-service
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/account-service
	helm template account-service $(COMMON_CHART_DIR) \
		-n apps \
		-f $(HELM_RESOURCE_DIR)/apps/account-service_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/account-service
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/account-service

auth-service:
	@echo "🚀 Hydrating auth-service..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/auth-service
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/auth-service
	helm template auth-service $(COMMON_CHART_DIR) \
		-n apps \
		-f $(HELM_RESOURCE_DIR)/apps/auth-service_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/auth-service
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/auth-service

notification-service:
	@echo "🚀 Hydrating notification-service..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/notification-service
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/notification-service
	helm template notification-service $(COMMON_CHART_DIR) \
		-n apps \
		-f $(HELM_RESOURCE_DIR)/apps/notification-service_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/notification-service
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/notification-service

transfer-service:
	@echo "🚀 Hydrating transfer-service..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/transfer-service
	@mkdir -p $(KUSTOMIZE_GEN_DIR)/transfer-service
	helm template transfer-service $(COMMON_CHART_DIR) \
		-n apps \
		-f $(HELM_RESOURCE_DIR)/apps/transfer-service_values.yaml \
		--output-dir $(KUSTOMIZE_GEN_DIR)/transfer-service
	@$(MAKE) --no-print-directory _gen-kustomization DIR=$(KUSTOMIZE_GEN_DIR)/transfer-service

# ═════════════════════════════════════════════════════════════════════════════════
# UPGRADE (clean + re-generate a single component)
# ═════════════════════════════════════════════════════════════════════════════════

$(addprefix upgrade-,$(ALL_COMPONENTS)):
	@$(MAKE) --no-print-directory clean-$(subst upgrade-,,$@)
	@$(MAKE) --no-print-directory $(subst upgrade-,,$@)
	@$(MAKE) --no-print-directory kustomize-base
	@echo "✅ Upgraded $(subst upgrade-,,$@)"

# ═════════════════════════════════════════════════════════════════════════════════
# DELETE (remove from generated + rebuild kustomize base)
# ═════════════════════════════════════════════════════════════════════════════════

$(addprefix delete-,$(ALL_COMPONENTS)):
	@echo "🗑️  Deleting $(subst delete-,,$@)..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/$(subst delete-,,$@)
	@$(MAKE) --no-print-directory kustomize-base
	@echo "✅ Deleted $(subst delete-,,$@) from generated manifests."

# ═════════════════════════════════════════════════════════════════════════════════
# CLEAN TARGETS
# ═════════════════════════════════════════════════════════════════════════════════

clean:
	@echo "🧹 Cleaning ALL generated manifests..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/*
	@echo "✅ All cleaned."

clean-infra:
	@echo "🧹 Cleaning infrastructure manifests..."
	@$(foreach c,$(INFRA_COMPONENTS),rm -rf $(KUSTOMIZE_GEN_DIR)/$(c);)
	@echo "✅ Infrastructure cleaned."

clean-apps:
	@echo "🧹 Cleaning application manifests..."
	@$(foreach c,$(APP_COMPONENTS),rm -rf $(KUSTOMIZE_GEN_DIR)/$(c);)
	@echo "✅ Applications cleaned."

$(addprefix clean-,$(ALL_COMPONENTS)):
	@echo "🧹 Cleaning $(subst clean-,,$@)..."
	@rm -rf $(KUSTOMIZE_GEN_DIR)/$(subst clean-,,$@)

# ═════════════════════════════════════════════════════════════════════════════════
# KUSTOMIZE BASE REBUILD
# ═════════════════════════════════════════════════════════════════════════════════

kustomize-base:
	@echo "📝 Rebuilding kustomize/base/kustomization.yaml..."
	@echo "apiVersion: kustomize.config.k8s.io/v1beta1" > kustomize/base/kustomization.yaml
	@echo "kind: Kustomization" >> kustomize/base/kustomization.yaml
	@echo "" >> kustomize/base/kustomization.yaml
	@echo "resources:" >> kustomize/base/kustomization.yaml
	@echo "  - secrets" >> kustomize/base/kustomization.yaml
	@for dir in $(KUSTOMIZE_GEN_DIR)/*/; do \
		if [ -d "$$dir" ]; then \
			echo "  - generated/$$(basename $$dir)" >> kustomize/base/kustomization.yaml; \
		fi; \
	done
	@echo "✅ kustomize/base/kustomization.yaml rebuilt."

# ═════════════════════════════════════════════════════════════════════════════════
# INTERNAL: Generate kustomization.yaml for a component directory
# ═════════════════════════════════════════════════════════════════════════════════

_gen-kustomization:
	@echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $(DIR)/kustomization.yaml
	@echo "kind: Kustomization" >> $(DIR)/kustomization.yaml
	@echo "" >> $(DIR)/kustomization.yaml
	@echo "resources:" >> $(DIR)/kustomization.yaml
	@cd $(DIR) && find . -name "*.yaml" ! -name "kustomization.yaml" | sed 's|^./|  - |' | sort >> kustomization.yaml
