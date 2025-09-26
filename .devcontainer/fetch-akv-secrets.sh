#!/usr/bin/env bash
set -euo pipefail

: "${AKV_NAME:=}"

# Only run if we actually have credentials
if [[ -z "${AZURE_TENANT_ID:-}" || -z "${AZURE_CLIENT_ID:-}" || -z "${AZURE_CLIENT_SECRET:-}" || -z "${AKV_NAME}" ]]; then
  echo "INFO: Missing one of AZURE_TENANT_ID / AZURE_CLIENT_ID / AZURE_CLIENT_SECRET / AKV_NAME."
  echo "INFO: Skipping Key Vault fetch. Open a new terminal after setting remoteEnv."
  exit 0
fi

# Login non-interactively with a Service Principal
az login --service-principal \
  -u "$AZURE_CLIENT_ID" \
  -p "$AZURE_CLIENT_SECRET" \
  --tenant "$AZURE_TENANT_ID" >/dev/null

# (optional) set subscription if you passed it
if [[ -n "${AZURE_SUBSCRIPTION_ID:-}" ]]; then
  az account set --subscription "$AZURE_SUBSCRIPTION_ID"
fi

# Which secrets to pull
SECRETS=(
  "APP_DB_PASSWORD"
  "APP_API_KEY"
)

OUT="/home/vscode/.env.akv"
: > "$OUT"
for s in "${SECRETS[@]}"; do
  val="$(az keyvault secret show --vault-name "$AKV_NAME" --name "$s" --query value -o tsv)"
  echo "export ${s}=$(printf '%q' "$val")" >> "$OUT"
done

chown vscode:vscode "$OUT"
chmod 600 "$OUT"
echo "Loaded $(wc -l < "$OUT") secrets into $OUT"
