# PostgreSQL Database Context

## Overview
PostgreSQL serves as the primary relational database for the banking microservices.

## Architecture & Configuration
- **Deployment Mode:** Standalone architecture.
- **Resources:** Configured with specific memory/CPU limits suitable for the environment.
- **Access & Authentication:** Uses `pgHbaConfiguration` to enforce secure authentication mechanisms (scram-sha-256).
- **Secrets Management:** 
  - Passwords are NOT hardcoded in `values.yaml`.
  - The database relies on an `ExternalSecret` that generates the Kubernetes Secret `vault-postgres-secret`.
  - The master password is pulled from Vault (refer to `vault-init.sh` for the exact path, usually `secret/postgres`).
