###############################################################################
# Service Makefile - Multi-Environment Hydration
#
# Usage:
#   make generate ENV=dev    (default)
#   make generate ENV=prod
#   make clean ENV=dev
###############################################################################

ENV ?= dev
HELM_DIR := helm
KUSTOMIZE_DIR := kustomize/overlays/$(ENV)
OUTPUT_DIR := $(KUSTOMIZE_DIR)/base

# Component specific config (can be overwritten per service)
CHART_REPO := bitnami/rabbitmq
CHART_NAME := rabbitmq
NAMESPACE  := data

.PHONY: generate clean

generate: clean
	@echo "🔧 Hydrating $(CHART_NAME) for environment: $(ENV)..."
	@mkdir -p $(OUTPUT_DIR)
	helm template $(CHART_NAME) $(CHART_REPO) \
		-n $(NAMESPACE) \
		-f $(HELM_DIR)/values-$(ENV).yaml \
		--output-dir $(OUTPUT_DIR)
	@echo "📝 Generating kustomization.yaml for $(ENV)..."
	@echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "kind: Kustomization" >> $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "resources:" >> $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "  - base" >> $(KUSTOMIZE_DIR)/kustomization.yaml
	@if [ -f $(KUSTOMIZE_DIR)/externalsecret.yaml ]; then echo "  - externalsecret.yaml" >> $(KUSTOMIZE_DIR)/kustomization.yaml; fi
	@echo "📝 Generating base/kustomization.yaml for $(ENV)..."
	@echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $(OUTPUT_DIR)/kustomization.yaml
	@echo "kind: Kustomization" >> $(OUTPUT_DIR)/kustomization.yaml
	@echo "resources:" >> $(OUTPUT_DIR)/kustomization.yaml
	@cd $(OUTPUT_DIR) && find . -name "*.yaml" ! -name "kustomization.yaml" | sed 's|^./|  - |' | sort >> kustomization.yaml
	@echo "✅ Done."

clean:
	@echo "🧹 Cleaning $(ENV) manifests..."
	rm -rf $(OUTPUT_DIR)/*
	rm -f $(KUSTOMIZE_DIR)/kustomization.yaml
