#!/usr/bin/env bash
set -euo pipefail

: "${GH_HOST:=enercity.ghe.com}"
# prefer enterprise token, fall back to GitHub token
TOKEN="${GHE_TOKEN:-${GITHUB_TOKEN:-}}"
if [[ -z "${TOKEN}" ]]; then
  echo "ERROR: No GHE_TOKEN or GITHUB_TOKEN available for cloning from https://${GH_HOST}."
  echo "Fix: set GHE_TOKEN in your host env (DevPod -> Workspace -> Variables) and rebuild."
  exit 1
fi

# Username for HTTPS PATs. For GitHub/GHE, 'x-access-token' works as the username.
USER="${GH_USERNAME:-x-access-token}"

REPOS=(
  "https://enercity.ghe.com/enercity/encore-airflow.git"
  "https://enercity.ghe.com/enercity/encore-infrastructure.git"
)

git config --global --add safe.directory /workspaces/*
cd /workspaces

for url in "${REPOS[@]}"; do
  name="$(basename "${url%%.git}" .git)"

  # Only rewrite URLs for your GHE host
  authed_url="$url"
  if [[ "${url}" == "https://${GH_HOST}/"* ]]; then
    path="${url#https://${GH_HOST}/}"
    authed_url="https://${USER}:${TOKEN}@${GH_HOST}/${path}"
  fi

  if [[ ! -d "$name/.git" ]]; then
    echo "Cloning $url -> /workspaces/$name"
    # prevent any helper from intercepting creds
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= clone --recursive "$authed_url" "$name"
  else
    echo "Skipping $name (already cloned)"
  fi
done
