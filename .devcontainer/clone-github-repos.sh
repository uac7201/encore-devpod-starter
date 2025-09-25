#!/usr/bin/env bash
set -euo pipefail


# List your repos here (HTTPS or SSH)
REPOS=(
  "https://enercity.ghe.com/enercity/encore-airflow.git"
)

# If using HTTPS + private repos: inject token transparently
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

cd /workspaces
for url in "${REPOS[@]}"; do
  name="$(basename "$url" .git)"
  if [[ ! -d "$name/.git" ]]; then
    echo "Cloning $url -> /workspaces/$name"
    git clone --recursive "$url" "$name"
  else
    echo "Skipping $name (already cloned)"
  fi
done
