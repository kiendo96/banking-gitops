ENV ?= dev
HELM_DIR := helm
KUSTOMIZE_DIR := kustomize/overlays/$(ENV)
OUTPUT_DIR := $(KUSTOMIZE_DIR)/base

# Path tuyệt đối tới common chart
CHART_REPO := $(realpath $(CURDIR)/../charts/common-app)
CHART_NAME := frontend
NAMESPACE  := apps

.PHONY: generate clean

generate:
	@echo "🚀 Generating frontend for environment: $(ENV)..."
	@mkdir -p $(OUTPUT_DIR)
	helm template $(CHART_NAME) $(CHART_REPO) \
		-n $(NAMESPACE) \
		-f $(HELM_DIR)/values-$(ENV).yaml \
		--output-dir $(OUTPUT_DIR)
	@echo "📝 Building kustomization.yaml..."
	@echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "kind: Kustomization" >> $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "resources:" >> $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "  - base" >> $(KUSTOMIZE_DIR)/kustomization.yaml
	@echo "apiVersion: kustomize.config.k8s.io/v1beta1" > $(OUTPUT_DIR)/kustomization.yaml
	@echo "kind: Kustomization" >> $(OUTPUT_DIR)/kustomization.yaml
	@echo "resources:" >> $(OUTPUT_DIR)/kustomization.yaml
	@cd $(OUTPUT_DIR) && find . -name "*.yaml" ! -name "kustomization.yaml" | sed 's|^./|  - |' | sort >> kustomization.yaml
