# Harbor Service Context

## Overview
Harbor is used as the private container registry and Helm chart repository for the banking project. It is deployed via Helm and customized using Kustomize for different environments.

## Architecture & Routing
- **Ingress/Routing:** Harbor uses Kong API Gateway. Traffic is routed to Harbor via `HTTPRoute` (`resources/harbor-route.yaml`).
- **Nginx Proxy:** The internal Harbor NGINX proxy requires `externalURL: https://harbor.local` configured in `values-dev.yaml` to correctly route `/v2/` API requests (essential for Kaniko image pushes in CI).

## Secrets Management (Vault & External Secrets)
- **Strict Rule:** No hardcoded secrets in `values.yaml`.
- **Vault Location:** All Harbor secrets are stored in HashiCorp Vault under the path `secret/harbor`.
- **ExternalSecret:** The configuration uses an `ExternalSecret` (`apiVersion: external-secrets.io/v1`) named `harbor-secrets` to fetch credentials from Vault.
- **Key Mappings:**
  - Admin Password: `HARBOR_ADMIN_PASSWORD` (Stored securely in Vault, do not document actual passwords here)
  - Core Secret: `secret`
  - Jobservice Secret: `JOBSERVICE_SECRET`
  - Registry Secret: `REGISTRY_HTTP_SECRET`
  - Database: `POSTGRES_PASSWORD`
  - Redis: `REDIS_PASSWORD`

## Deployment Workflow
1. Modify `helm/values-<env>.yaml` or files in `kustomize/overlays/<env>/`.
2. Run `make generate ENV=<env>` from the `harbor/` directory.
3. The Makefile automatically injects `externalsecret.yaml` and `resources/harbor-route.yaml` into the generated Kustomize base.
4. Commit and push to the `banking-gitops` repository to trigger ArgoCD synchronization.