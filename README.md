# Python + PySpark DevPod Starter

Dev environment for Python and PySpark using **DevPod** + **Dev Containers**.

## Quick start (DevPod CLI)

```bash
# 1) Create a workspace from this repo
devpod create python-spark \
  --repo <YOUR_GIT_URL_OF_THIS_REPO>

# 2) Start the workspace and open in VS Code
devpod up python-spark --ide code
```

> You can also use DevPod Desktop: *Create Workspace* → *Git Repository* → paste this repo URL.

## What’s inside
- `.devcontainer/devcontainer.json` — Dev Container config consumed by DevPod
- `.devcontainer/Dockerfile` — base image + OpenJDK 17 for Spark
- `requirements.txt` — Python deps (PySpark, pytest, Jupyter)
- `src/app.py` — sample Spark job
- `tests/test_spark.py` — minimal pytest
- `.vscode/*` — VS Code recommendations

## Ports
- Spark UI: **4040**
- JupyterLab: **8888** (run `jupyter lab --ip=0.0.0.0 --no-browser`)

## Run
```bash
# inside the container
python -m pip install -r requirements.txt
python src/app.py
pytest -q
```

## Notes
- Uses Java **17** (LTS) and PySpark **3.5.x**.
- Local Spark master is used (`local[*]`).

---
Made for DevPod + VS Code devcontainers.

## installation

setup a host:
```
devpod provider add docker --use
```

verify it is used:
```
devpod provider list
```

For podman set the DOCKER_HOST env variable:
```
$machine = '<YOUR-MACHINE-NAME>'
$pipe = podman machine inspect $machine --format '{{.ConnectionInfo.PodmanPipe.Path}}'
$env:DOCKER_HOST = "npipe://$($pipe -replace '\\','/')"

docker ps   # should list containers (even if none)
devpod provider use docker
```

```
devpod up encore-workspace `
  --source git:https://github.com/uac7201/encore-devpod-starter `
   --reset `
   --workspace-env GH_HOST=enercity.ghe.com `
   --workspace-env GHE_TOKEN=$env:GHE_TOKEN `
   --workspace-env GITHUB_TOKEN=$env:GITHUB_TOKEN `
   --workspace-env AZURE_TENANT_ID=$env:AZURE_TENANT_ID `
   --workspace-env AZURE_CLIENT_ID=$env:AZURE_CLIENT_ID `
   --workspace-env AZURE_CLIENT_SECRET=$env:AZURE_CLIENT_SECRET `
   --workspace-env AZURE_SUBSCRIPTION_ID=$env:AZURE_SUBSCRIPTION_ID `
   --workspace-env AKV_VAULT_NAME=$env:AKV_VAULT_NAME
```