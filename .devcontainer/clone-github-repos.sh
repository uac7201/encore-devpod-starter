#!/usr/bin/env bash
set -euo pipefail

: "${GH_HOST:=enercity.ghe.com}"
: "${GHE_TOKEN:=${GITHUB_TOKEN:-}}"   # prefer GHE_TOKEN; fallback to GITHUB_TOKEN

REPOS=(
  "https://enercity.ghe.com/enercity/encore-airflow.git"
  "https://enercity.ghe.com/enercity/encore-infrastructure.git"
)

git config --global --add safe.directory /workspaces/*
cd /workspaces

for url in "${REPOS[@]}"; do
  name="$(basename "${url%%.git}" .git)"

  # Build a tokenized URL only for your GHE host
  authed_url="$url"
  if [[ -n "${GHE_TOKEN}" && "${url}" == "https://${GH_HOST}/"* ]]; then
    host="${GH_HOST}"
    path="${url#https://${host}/}"     # everything after host/
    authed_url="https://${GHE_TOKEN}:x-oauth-basic@${host}/${path}"
  fi

  if [[ ! -d "$name/.git" ]]; then
    echo "Cloning $url -> /workspaces/$name"
    # Disable any credential helper so DevPod can't intercept (avoids the panic)
    GIT_TERMINAL_PROMPT=0 git \
      -c credential.helper= \
      clone --recursive "$authed_url" "$name"
  else
    echo "Skipping $name (already cloned)"
  fi
done
