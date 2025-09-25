#!/usr/bin/env bash
set -euo pipefail

# ---- CONFIG ----
: "${GH_HOST:=enercity.ghe.com}"                      # your GHE host
: "${GHE_TOKEN:=${GITHUB_TOKEN:-}}"                   # prefer GHE_TOKEN; fall back to GITHUB_TOKEN if set

# Repos to clone (NO trailing commas)
REPOS=(
  "https://enercity.ghe.com/enercity/encore-airflow.git"
  "https://enercity.ghe.com/enercity/encore-infrastructure.git"
)

# ---- AUTH (bypass DevPod helper) ----
if [[ -n "${GHE_TOKEN}" ]]; then
  # Make ANY https://$GH_HOST/... use the token (affects submodules, too)
  git config --global url."https://${GHE_TOKEN}:x-oauth-basic@${GH_HOST}/".insteadOf "https://${GH_HOST}/"
fi

# Optional: support public GitHub token as well (if you also clone from github.com)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
fi

# Avoid “detected dubious ownership” when cloning into /workspaces
git config --global --add safe.directory /workspaces/*

# ---- CLONE ----
cd /workspaces
for url in "${REPOS[@]}"; do
  name="$(basename "${url%%.git}" .git)"           # strip .git reliably
  if [[ ! -d "$name/.git" ]]; then
    echo "Cloning $url -> /workspaces/$name"
    git clone --recursive "$url" "$name"
  else
    echo "Skipping $name (already cloned)"
  fi
done
