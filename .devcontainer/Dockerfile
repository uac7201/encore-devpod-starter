# Choose Bookworm variant for easier Java install
FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

# Use bash (with pipefail) for all RUN steps
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# ---------------- Java for Spark ----------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jdk ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

# ---------------- Base tools + build deps for pyenv ----------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl git bash-completion gnupg zsh ca-certificates \
    build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev tk-dev libffi-dev liblzma-dev xz-utils unzip \
    && rm -rf /var/lib/apt/lists/*

# ---------------- kubectl ----------------
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kubectl \
    && rm -rf /var/lib/apt/lists/*

# ---------------- k9s ----------------
ARG K9S_VERSION="0.32.4"
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
    amd64) K9S_ARCH="amd64";; \
    arm64) K9S_ARCH="arm64";; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1;; \
    esac; \
    curl -fsSL -o /tmp/k9s.tgz "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${K9S_ARCH}.tar.gz"; \
    tar -xzf /tmp/k9s.tgz -C /usr/local/bin k9s; \
    rm -f /tmp/k9s.tgz

# ---------------- kubectx & kubens ----------------
RUN git clone --depth=1 https://github.com/ahmetb/kubectx /opt/kubectx \
    && ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx \
    && ln -sf /opt/kubectx/kubens  /usr/local/bin/kubens \
    && mkdir -p /etc/bash_completion.d \
    && /bin/bash -lc 'cat /opt/kubectx/completion/kubectx.bash > /etc/bash_completion.d/kubectx' \
    && /bin/bash -lc 'cat /opt/kubectx/completion/kubens.bash  > /etc/bash_completion.d/kubens'

# ---------------- Azure CLI ----------------
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# ---------------- Terraform (HashiCorp repo) ----------------
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg \
    && chmod 0644 /etc/apt/keyrings/hashicorp.gpg \
    && . /etc/os-release \
    && echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com ${VERSION_CODENAME} main" \
    > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends terraform \
    && rm -rf /var/lib/apt/lists/*
RUN terraform -install-autocomplete || true

# ---------------- Terragrunt ----------------
ARG TERRAGRUNT_VERSION="0.67.16"
# TARGETARCH reused
RUN set -eux; \
    case "$TARGETARCH" in \
    amd64) TARCH="amd64";; \
    arm64) TARCH="arm64";; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1;; \
    esac; \
    curl -fsSL -o /usr/local/bin/terragrunt \
    "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARCH}"; \
    chmod +x /usr/local/bin/terragrunt

# ---------------- sops ----------------
ARG SOPS_VERSION="3.8.1"
# TARGETARCH reused
RUN set -eux; \
    case "$TARGETARCH" in \
    amd64) SOPS_ARCH="amd64";; \
    arm64) SOPS_ARCH="arm64";; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1;; \
    esac; \
    curl -fsSL -o /usr/local/bin/sops \
    "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${SOPS_ARCH}"; \
    chmod +x /usr/local/bin/sops

# ---------------- Load Key Vault env in login shells (bash) ----------------
RUN printf '%s\n' \
    '# /etc/profile.d/20-load-akv-env.sh' \
    'if [ -f /home/vscode/.env.akv ]; then' \
    '  # shellcheck disable=SC1091' \
    '  . /home/vscode/.env.akv' \
    'fi' \
    > /etc/profile.d/20-load-akv-env.sh \
    && chmod 0644 /etc/profile.d/20-load-akv-env.sh

# Keep pip user bin on PATH for all users (bash shells)
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /etc/bash.bashrc

# ---------------- uv (install for vscode user) ----------------
RUN su - vscode -c 'curl -LsSf https://astral.sh/uv/install.sh | sh' \
    && ln -sf /home/vscode/.local/bin/uv /usr/local/bin/uv || true

# ---------------- pyenv (+ pyenv-virtualenv) for vscode ----------------
RUN test -d /home/vscode/.pyenv || git clone https://github.com/pyenv/pyenv.git /home/vscode/.pyenv \
    && test -d /home/vscode/.pyenv/plugins/pyenv-virtualenv || git clone https://github.com/pyenv/pyenv-virtualenv.git /home/vscode/.pyenv/plugins/pyenv-virtualenv \
    && chown -R vscode:vscode /home/vscode/.pyenv

# ---------- Oh My Zsh + Spaceship + plugins (idempotent, install as vscode) ----------
# Ensure base dirs and ownership
RUN install -d -o vscode -g vscode /home/vscode/.oh-my-zsh \
    && install -d -o vscode -g vscode /home/vscode/.oh-my-zsh/custom/plugins \
    && install -d -o vscode -g vscode /home/vscode/.oh-my-zsh/custom/themes

# Clone/update OMZ if needed
RUN su -s /bin/bash -c 'test -d ~/.oh-my-zsh/.git || { rm -rf ~/.oh-my-zsh; git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh; }' vscode

# Theme + plugins (only if missing)
RUN su -s /bin/bash -c 'test -d ~/.oh-my-zsh/custom/themes/spaceship/.git || git clone --depth=1 https://github.com/pascaldevink/spaceship-zsh-theme.git ~/.oh-my-zsh/custom/themes/spaceship' vscode \
    && ln -sf /home/vscode/.oh-my-zsh/custom/themes/spaceship/spaceship.zsh-theme /home/vscode/.oh-my-zsh/custom/themes/spaceship.zsh-theme \
    && su -s /bin/bash -c 'test -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/.git || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions' vscode \
    && su -s /bin/bash -c 'test -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/.git || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting' vscode

# Make zsh default and write ~/.zshrc for vscode
RUN chsh -s /usr/bin/zsh vscode || true \
    && cat > /home/vscode/.zshrc <<'ZRC' \
    && chown vscode:vscode /home/vscode/.zshrc
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

ZSH_THEME="spaceship"
# keep zsh-syntax-highlighting LAST
plugins=(git kubectl zsh-autosuggestions zsh-syntax-highlighting)

# Load Key Vault exports if present (from fetch-akv-secrets.sh)
[ -f "$HOME/.env.akv.export" ] && . "$HOME/.env.akv.export"

# Per-user bin (uv lives here)
export PATH="$HOME/.local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"
command -v pyenv-virtualenv-init >/dev/null && eval "$(pyenv virtualenv-init -)"

# kubectl completion (nice-to-have)
if command -v kubectl >/dev/null; then
  source <(kubectl completion zsh)
  compdef __start_kubectl kubectl
fi

# Locale & editor
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export EDITOR=code

source "$ZSH/oh-my-zsh.sh"
ZRC

# Make sure shells default to zsh
ENV SHELL=/usr/bin/zsh

USER vscode
WORKDIR /workspaces
