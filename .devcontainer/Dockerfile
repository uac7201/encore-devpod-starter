# Choose Bookworm variant for easier Java install
FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

USER root

# Java for Spark
RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jdk ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

# Tools: curl, git, bash-completion
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git bash-completion gnupg \
    && rm -rf /var/lib/apt/lists/*

# kubectl
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kubectl \
    && rm -rf /var/lib/apt/lists/*

# k9s
ARG K9S_VERSION="0.32.4"
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
    amd64) K9S_ARCH="amd64";; \
    arm64) K9S_ARCH="arm64";; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1;; \
    esac; \
    curl -fsSL -o /tmp/k9s.tgz \
    "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${K9S_ARCH}.tar.gz"; \
    tar -xzf /tmp/k9s.tgz -C /usr/local/bin k9s; \
    rm -f /tmp/k9s.tgz

# kubectx & kubens
RUN git clone --depth=1 https://github.com/ahmetb/kubectx /opt/kubectx \
    && ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx \
    && ln -sf /opt/kubectx/kubens  /usr/local/bin/kubens \
    && mkdir -p /etc/bash_completion.d \
    && /bin/bash -lc 'cat /opt/kubectx/completion/kubectx.bash > /etc/bash_completion.d/kubectx' \
    && /bin/bash -lc 'cat /opt/kubectx/completion/kubens.bash  > /etc/bash_completion.d/kubens'

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# ---------- Terraform ----------
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg \
    && chmod 0644 /etc/apt/keyrings/hashicorp.gpg \
    && . /etc/os-release \
    && echo "deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com ${VERSION_CODENAME} main" \
    > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends terraform \
    && rm -rf /var/lib/apt/lists/*

# Optional: enable terraform bash autocomplete for all users
RUN terraform -install-autocomplete || true

# ---------- Terragrunt ----------
ARG TERRAGRUNT_VERSION="0.67.16"
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
    amd64) TARCH="amd64";; \
    arm64) TARCH="arm64";; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1;; \
    esac; \
    curl -fsSL -o /usr/local/bin/terragrunt \
    "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARCH}"; \
    chmod +x /usr/local/bin/terragrunt

# ---------- sops ----------
ARG SOPS_VERSION="3.8.1"
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
    amd64) SOPS_ARCH="amd64";; \
    arm64) SOPS_ARCH="arm64";; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1;; \
    esac; \
    curl -fsSL -o /usr/local/bin/sops \
    "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${SOPS_ARCH}"; \
    chmod +x /usr/local/bin/sops

# ---- load Key Vault env on every shell ----
RUN printf '%s\n' \
    '# /etc/profile.d/20-load-akv-env.sh' \
    'if [ -f /home/vscode/.env.akv ]; then' \
    '  # shellcheck disable=SC1091' \
    '  . /home/vscode/.env.akv' \
    'fi' \
    > /etc/profile.d/20-load-akv-env.sh \
    && chmod 0644 /etc/profile.d/20-load-akv-env.sh

# (optional) make sure local pip scripts are on PATH for all users
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /etc/bash.bashrc

# ===== Zsh + Oh My Zsh + Spaceship, uv, pyenv =====
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh fonts-powerline ca-certificates \
    build-essential make \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# Oh My Zsh (unattended) for user "vscode"
RUN su - vscode -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true'

# Spaceship ZSH theme
RUN su - vscode -c '\
    mkdir -p ~/.oh-my-zsh/custom/themes && \
    git clone --depth=1 https://github.com/pascaldevink/spaceship-zsh-theme.git \
    ~/.oh-my-zsh/custom/themes/spaceship && \
    ln -sf ~/.oh-my-zsh/custom/themes/spaceship/spaceship.zsh-theme \
    ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme \
    '

# zsh plugins
RUN su - vscode -c '\
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    '

# uv (per-user)
RUN su - vscode -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'

# pyenv (+ pyenv-virtualenv)
RUN su - vscode -c '\
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
    mkdir -p ~/.pyenv/plugins && \
    git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv \
    '

# Write ~/.zshrc via heredoc as root, then chown (avoids heredoc-in-su issue)
RUN bash -lc 'cat >/home/vscode/.zshrc << "ZRC"
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)

# Load AKV exports if present (created by your fetch script)
[ -f "\$HOME/.env.akv.export" ] && . "\$HOME/.env.akv.export"

# uv
export PATH="\$HOME/.local/bin:\$PATH"

# pyenv
export PYENV_ROOT="\$HOME/.pyenv"
export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

# Nice defaults
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export EDITOR=code

source "\$ZSH/oh-my-zsh.sh"

# Example spaceship tweaks:
# export SPACESHIP_PROMPT_ORDER=(time user dir git node python venv exec_time line_sep battery char)
ZRC' \
    && chown vscode:vscode /home/vscode/.zshrc

# Make zsh the default shell for vscode
RUN chsh -s /usr/bin/zsh vscode

USER vscode
WORKDIR /workspaces
