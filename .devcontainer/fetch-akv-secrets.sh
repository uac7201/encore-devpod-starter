#!/usr/bin/env bash
set -euo pipefail

# Required: these must be passed via devcontainer "remoteEnv"
: "${AZURE_TENANT_ID:?missing}"
: "${AZURE_CLIENT_ID:?missing}"
: "${AZURE_CLIENT_SECRET:?missing}"
: "${AKV_VAULT_NAME:?missing}"

ENV_FILE="/home/vscode/.env.akv"
EXPORT_FILE="/home/vscode/.env.akv.export"

echo "INFO: Logging in to Azure with service principal..."
az login --service-principal \
  --tenant "$AZURE_TENANT_ID" \
  --username "$AZURE_CLIENT_ID" \
  --password "$AZURE_CLIENT_SECRET" \
  >/dev/null

echo "INFO: Fetching secrets from Key Vault: $AKV_VAULT_NAME"
# Write raw key=value pairs (use secret names as-is)
: > "$ENV_FILE"
while IFS= read -r name; do
  # Skip disabled/archived etc. (we filter to enabled list)
  val="$(az keyvault secret show --vault-name "$AKV_VAULT_NAME" --name "$name" --query 'value' -o tsv)"
  printf '%s=%s\n' "$name" "$val" >> "$ENV_FILE"
done < <(az keyvault secret list --vault-name "$AKV_VAULT_NAME" --query '[?attributes.enabled].name' -o tsv)

# Build an exportable version:
#  - uppercase keys
#  - replace non [A-Z0-9_] with _
#  - prefix leading digits with _
#  - emit `export KEY='value'` safely (handles special chars)
: > "$EXPORT_FILE"
while IFS='=' read -r k v; do
  [[ -z "${k:-}" || "${k:0:1}" == "#" ]] && continue
  sk="$(echo -n "$k" | tr '[:lower:]-' '[:upper:]_' | sed 's/[^A-Z0-9_]/_/g')"
  [[ "$sk" =~ ^[0-9] ]] && sk="_$sk"
  # shellcheck disable=SC2086 # we want printf %q quoting
  printf 'export %s=%q\n' "$sk" "$v" >> "$EXPORT_FILE"
done < "$ENV_FILE"

chown vscode:vscode "$ENV_FILE" "$EXPORT_FILE"
chmod 0600 "$ENV_FILE" "$EXPORT_FILE"

# Auto-load on future shells (fallback if /etc/profile.d loader isn’t present)
grep -qF '. ~/.env.akv.export' /home/vscode/.bashrc || echo '. ~/.env.akv.export' >> /home/vscode/.bashrc

echo "INFO: Wrote $(wc -l < "$ENV_FILE") secrets to:"
echo "  - $ENV_FILE          (raw)"
echo "  - $EXPORT_FILE       (exportable)"
echo "INFO: Open a NEW terminal, or run:  source $EXPORT_FILE"
