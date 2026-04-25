# Banking Applications (Microservices) Context

## Overview
This directory contains the deployment manifests for all custom banking microservices (e.g., `auth-service`, `account-service`, `frontend`, etc.). 

## Helm Chart
- **Common Chart:** All services utilize a shared, generic Helm chart located at `banking-gitops/charts/common-app`. This ensures standardized deployments across all microservices.

## Routing (Gateway API)
- Services do NOT use standard `Ingress` resources (`ingress.enabled: false`).
- Instead, they use `HTTPRoute` (`httpRoute.enabled: true`) to route traffic through the Kong API Gateway (e.g., `host: banking.local`).

## Secrets & Environment Variables
- **Dynamic Configuration:** Database URLs and Redis connection strings are constructed dynamically in `values.yaml` using environment variables.
- **Vault Integration:** 
  - Secrets are managed via the `secret.enabled: true` block in `values.yaml`.
  - The `common-app` chart automatically generates an `ExternalSecret` pointing to `vaultPath: banking/<service-name>`.
  - The retrieved secrets (like `DB_PASSWORD`, `REDIS_PASSWORD`) are injected as environment variables into the Pod.
