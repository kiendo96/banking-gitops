#!/bin/bash
set -e

echo "==========================================================="
echo "   Initialize and Unseal Vault HA (Production-ready mode)  "
echo "==========================================================="

echo "Waiting for vault-0 to be ready for initialization..."
kubectl wait --for=jsonpath='{.status.phase}'=Running pod/vault-0 -n vault --timeout=120s

# Helper to execute commands in vault-0
VAULT_POD=vault-0
VAULT_CMD="kubectl exec -n vault $VAULT_POD --"

# Check if vault is already initialized
INIT_STATUS=$($VAULT_CMD vault status -format=json 2>/dev/null | jq -r .initialized || echo "false")

if [ "$INIT_STATUS" != "true" ]; then
  echo "Initializing Vault..."
  $VAULT_CMD vault operator init -format=json > cluster-keys.json
  echo "✅ Vault initialized. Keys saved to cluster-keys.json"
  echo "⚠️  CRITICAL: DO NOT COMMIT cluster-keys.json to Git!"
else
  echo "Vault is already initialized."
  if [ ! -f "cluster-keys.json" ]; then
     echo "❌ Error: cluster-keys.json not found but Vault is initialized."
     echo "We need the unseal keys. If you lost them, you must wipe the PVCs and start over."
     exit 1
  fi
fi

# Extract keys
ROOT_TOKEN=$(jq -r '.root_token' cluster-keys.json)
UNSEAL_KEY_1=$(jq -r '.unseal_keys_b64[0]' cluster-keys.json)
UNSEAL_KEY_2=$(jq -r '.unseal_keys_b64[1]' cluster-keys.json)
UNSEAL_KEY_3=$(jq -r '.unseal_keys_b64[2]' cluster-keys.json)

# Unseal all 3 pods
for pod in vault-0 vault-1 vault-2; do
  echo "Checking status of $pod..."
  while [[ $(kubectl get pods $pod -n vault -o 'jsonpath={..status.phase}') != "Running" ]]; do
      echo "Waiting for $pod to be running..."
      sleep 3
  done

  # If it's not vault-0, we must join the raft cluster BEFORE unsealing
  if [ "$pod" != "vault-0" ]; then
    echo "Joining $pod to raft cluster..."
    kubectl exec -n vault $pod -- vault operator raft join http://vault-0.vault-internal:8200 || true
  fi

  SEALED=$(kubectl exec -n vault $pod -- vault status -format=json 2>/dev/null | jq -r .sealed || echo "true")
  if [ "$SEALED" == "true" ]; then
    echo "🔑 Unsealing $pod..."
    kubectl exec -n vault $pod -- vault operator unseal $UNSEAL_KEY_1 > /dev/null
    kubectl exec -n vault $pod -- vault operator unseal $UNSEAL_KEY_2 > /dev/null
    kubectl exec -n vault $pod -- vault operator unseal $UNSEAL_KEY_3 > /dev/null
    echo "✅ $pod unsealed."
  else
    echo "✅ $pod is already unsealed."
  fi
done

# Wait for leader election
echo "Waiting for Raft leader election (10s)..."
sleep 10

echo "Updating vault-token secret for External Secrets Operator..."
kubectl delete secret vault-token -n vault --ignore-not-found
kubectl create secret generic vault-token -n vault --from-literal=token=$ROOT_TOKEN

# Check if KV engine is enabled at secret/
echo "Enabling KV v2 engine at secret/..."
$VAULT_CMD sh -c "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=$ROOT_TOKEN vault secrets enable -path=secret kv-v2 || true"

# Populate secrets
echo "Configuring Infrastructure secrets..."
$VAULT_CMD sh -c "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=$ROOT_TOKEN vault kv put secret/postgres password='super-secure-pg-password' repmgr-password='super-secure-repmgr-password'"
$VAULT_CMD sh -c "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=$ROOT_TOKEN vault kv put secret/redis redis-password='super-secure-redis-password'"
$VAULT_CMD sh -c "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=$ROOT_TOKEN vault kv put secret/rabbitmq rabbitmq-password='super-secure-rmq-password' rabbitmq-erlang-cookie='secure-erlang-cookie-xyz'"
$VAULT_CMD sh -c "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=$ROOT_TOKEN vault kv put secret/jenkins jenkins-admin-password='admin' jenkins-admin-user='admin'"

echo "Configuring App secrets..."
for app in auth-service account-service transfer-service notification-service; do
  $VAULT_CMD sh -c "VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=$ROOT_TOKEN vault kv put secret/banking/$app database-password='super-secure-pg-password' redis-password='super-secure-redis-password'"
done

echo "🚀 Vault Initialized and Unsealed! External Secrets Operator should pick these up shortly."
