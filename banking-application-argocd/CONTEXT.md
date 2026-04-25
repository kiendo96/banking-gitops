# Infrastructure GitOps Orchestration (ArgoCD)

## Overview
This directory uses the ArgoCD "App of Apps" pattern to orchestrate the deployment of all core Infrastructure components in the Kubernetes cluster.

## Orchestration Flow
- The root `argocd-dev-infra.yaml` (or prod) points to this directory's Kustomize overlay.
- This directory defines multiple ArgoCD `Application` Custom Resources for foundational services:
  - cert-manager
  - vault
  - external-secrets
  - jenkins
  - harbor
  - postgres
  - redis
  - rabbitmq
  - kong
  - cluster-configs
- **Rule:** If a new infrastructure tool (e.g., Elasticsearch, Prometheus) is added to the project, its corresponding ArgoCD `Application` YAML must be added to the `resources/applications/` folder and appended to this `kustomization.yaml`.
