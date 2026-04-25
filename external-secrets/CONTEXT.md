# External Secrets Operator (ESO) Context

## Overview
ESO is a critical security component that synchronizes secrets from external APIs (HashiCorp Vault) into Kubernetes Secrets.

## Configuration
- **CRDs:** Custom Resource Definitions for ESO are installed via Helm (`installCRDs: true`).
- **Cluster Integration:** ESO uses a `ClusterSecretStore` named `vault-backend` (usually defined in a cluster-configs directory) to authenticate with the Vault instance.
- **Usage:** Other services (like Harbor, Postgres, Redis, and apps) declare an `ExternalSecret` manifest. ESO reads this, fetches the value from Vault, and creates a standard Kubernetes `Secret` that the pods can mount.
