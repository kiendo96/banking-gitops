#!/bin/bash
set -eo pipefail

echo "Initializing Vault DEV mode secrets..."

# Wait for vault to be ready
echo "Waiting for vault to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=60s || true

export VAULT_POD=$(kubectl get pod -l app.kubernetes.io/name=vault -n vault -o jsonpath="{.items[0].metadata.name}")

echo "Enabling KV v2 engine at secret/..."
kubectl exec -n vault $VAULT_POD -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault secrets enable -path=secret kv-v2' || true

echo "Configuring Postgres secrets..."
kubectl exec -n vault $VAULT_POD -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault kv put secret/postgres password="super-secure-pg-password" repmgr-password="super-secure-repmgr-password"'

echo "Configuring Redis secrets..."
kubectl exec -n vault $VAULT_POD -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault kv put secret/redis redis-password="super-secure-redis-password"'

echo "Configuring RabbitMQ secrets..."
kubectl exec -n vault $VAULT_POD -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault kv put secret/rabbitmq rabbitmq-password="super-secure-rmq-password" rabbitmq-erlang-cookie="secure-erlang-cookie-xyz"'

echo "Configuring Jenkins secrets..."
kubectl exec -n vault $VAULT_POD -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root vault kv put secret/jenkins jenkins-admin-password="admin"'

echo "Vault Initialized! External Secrets Operator should pick these up shortly."
