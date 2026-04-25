# Vault Configuration Context

## Overview
HashiCorp Vault is the single source of truth for all secrets in this project. It runs in HA mode.

## Initialization & Usage
- **Initialization Script:** `vault-init.sh` at the root of `banking-gitops` is used to initialize, unseal, and populate Vault with required infrastructure and application secrets.
- **Engine:** Uses KV-V2 engine mounted at the `secret/` path.
- **Rule of Thumb:** If a new service requires a database password, API key, or token, it MUST be added to the `vault-init.sh` script under the respective path (e.g., `secret/banking/<app-name>`). 

## Integration
- External Secrets Operator (ESO) connects to Vault via a `ClusterSecretStore` named `vault-backend`.
- **Warning:** NEVER commit the `cluster-keys.json` file generated during initialization to Git.
