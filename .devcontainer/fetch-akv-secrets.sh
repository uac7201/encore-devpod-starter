#!/usr/bin/env bash
set -euo pipefail

# Required env from host via remoteEnv
: "${AZURE_TENANT_ID:?missing}"
: "${AZURE_SUBSCRIPTION_ID:?missing}"
: "${AZURE_CLIENT_ID:?missing}"
: "${AZURE_CLIENT_SECRET:?missing}"
: "${AKV_VAULT_NAME:?missing}"

# Map Key Vault secret names -> ENV VAR names (left is KV name, right is env var)
# If no "=", the env var name equals the secret name.
SECRETS=(
  "db-password=APP_DB_PASSWORD"
  "api-key=EXTERNAL_API_KEY"
  # "sops-age-key"           # becomes SOPS-AGE-KEY (not ideal) – better to map explicitly
)

# Login (idempotent)
az login --service-principal \
  --tenant  "$AZURE_TENANT_ID" \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" >/dev/null
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# Where to write resolved env vars (not checked in)
ENV_FILE="/home/vscode/.env.akv"
: > "$ENV_FILE"

for item in "${SECRETS[@]}"; do
  if [[ "$item" == *"="* ]]; then
    kv_name="${item%%=*}"
    env_name="${item#*=}"
  else
    kv_name="$item"
    env_name="$item"
  fi

  val="$(az keyvault secret show \
          --vault-name "$AKV_VAULT_NAME" \
          --name "$kv_name" \
          --query value -o tsv)"
  # Write a POSIX-safe export line (quote values)
  printf "export %s=%q\n" "$env_name" "$val" >> "$ENV_FILE"
done

# Optional: also mirror Azure creds for Terraform azurerm provider
{
  echo "export ARM_TENANT_ID=${AZURE_TENANT_ID@Q}"
  echo "export ARM_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID@Q}"
  echo "export ARM_CLIENT_ID=${AZURE_CLIENT_ID@Q}"
  echo "export ARM_CLIENT_SECRET=${AZURE_CLIENT_SECRET@Q}"
} >> "$ENV_FILE"
