# Banking GitOps Repository Context

## Overview
This is the root of the GitOps repository for the banking project. It acts as the single source of truth for the entire Kubernetes cluster's desired state.

## Architecture & ArgoCD "App of Apps" Pattern
The cluster state is orchestrated by ArgoCD using two main entry points located at the root of this repo:
1. **`argocd-dev-infra.yaml`**: Bootstraps the foundational infrastructure (Kong, Vault, Harbor, Jenkins, Databases) by pointing to `banking-application-argocd/`.
2. **`argocd-dev-apps.yaml`**: Bootstraps the custom banking microservices (auth, account, transfer, etc.) by pointing to `banking-apps-argocd/`.

## Core Workflows
- **Secrets:** Run `./vault-init.sh` manually after spinning up the cluster to unseal Vault and populate it with initial secrets. NEVER commit `cluster-keys.json`.
- **Manifest Hydration:** Do NOT manually modify files in `base/` directories. Always navigate to a component's folder (e.g., `harbor/`, `apps/auth-service/`) and run `make generate ENV=<env>`.
- **Auto-pilot AI Navigation:** If you (the AI) need to work on a specific component, you MUST read the local `CONTEXT.md` file within that component's folder before making any changes.
