# Redis Datastore Context

## Overview
Redis is utilized as an in-memory data structure store, primarily used for caching and message broker backing by the banking microservices.

## Architecture
- **Deployment Mode:** Standalone architecture.
- **Secrets Management:** 
  - Authentication is enforced but passwords are NOT hardcoded.
  - Redis relies on an `ExternalSecret` that creates the Kubernetes Secret `vault-redis-secret`.
  - The password is authenticated against Vault (populated via `vault-init.sh` at `secret/redis`).
