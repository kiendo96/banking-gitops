# Cluster Configurations Context

## Overview
This directory contains cluster-wide configurations and Custom Resources that do not belong to a specific application or infrastructure component but are required for the cluster's core operations.

## Core Resources
- **ClusterSecretStore:** Configures the integration between the External Secrets Operator (ESO) and HashiCorp Vault (`vault-backend`). 
- **Vault Connection:** It points to the internal Vault service (`http://vault-internal.vault.svc.cluster.local:8200`) using the KV v2 engine at the `secret` path. Authentication is handled via a Kubernetes Secret (`vault-token`) generated during the Vault initialization process.
