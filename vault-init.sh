#!/bin/bash
set -eo pipefail

echo "Initializing Vault DEV mode secrets..."

# Wait for vault to be ready
echo "Waiting for vault to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=60s || true

# Forward port briefly
kubectl port-forward svc/vault 8200:8200 -n vault &
PF_PID=$!
sleep 3

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'

echo "Enabling KV v2 engine at secret/..."
vault secrets enable -path=secret kv-v2 || true

echo "Configuring Postgres secrets..."
vault kv put secret/postgres password="super-secure-pg-password" repmgr-password="super-secure-repmgr-password"

echo "Configuring Redis secrets..."
vault kv put secret/redis redis-password="super-secure-redis-password"

echo "Configuring RabbitMQ secrets..."
vault kv put secret/rabbitmq rabbitmq-password="super-secure-rmq-password" rabbitmq-erlang-cookie="secure-erlang-cookie-xyz"

echo "Configuring Jenkins secrets..."
vault kv put secret/jenkins jenkins-admin-password="admin"

kill $PF_PID

echo "Vault Initialized! External Secrets Operator should pick these up shortly."
