# Microservices GitOps Orchestration (ArgoCD)

## Overview
This directory uses the ArgoCD "App of Apps" pattern to orchestrate the deployment of all banking microservices and the frontend application.

## Orchestration Flow
- The root `argocd-dev-apps.yaml` points to this directory.
- This directory defines ArgoCD `Application` Custom Resources for the business logic components located in `apps/`:
  - frontend
  - account-service
  - auth-service
  - notification-service
  - transfer-service
- **Rule:** When a new microservice is developed in `banking-source`, its deployment manifests must be created in `apps/<new-service>`, and an ArgoCD `Application` resource must be added here to tell ArgoCD to track and sync it.
