# ---- existing lines above (FROM ..., Java install, etc.) ----
USER root

# Base tools for installs + completions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg bash-completion git \
    && rm -rf /var/lib/apt/lists/*

# --- kubectl (via pkgs.k8s.io repos) ---
# Choose a stable stream (v1.30 shown; bump when you want newer)
RUN install -d -m 0755 /etc/apt/keyrings \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kubectl \
    && rm -rf /var/lib/apt/lists/*

# --- k9s ---
ARG K9S_VERSION="0.32.4"
ARG TARGETARCH
# Map Docker's TARGETARCH to k9s archive names
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

# --- kubectx & kubens ---
RUN git clone --depth=1 https://github.com/ahmetb/kubectx /opt/kubectx \
    && ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx \
    && ln -sf /opt/kubectx/kubens  /usr/local/bin/kubens \
    # bash completions
    && mkdir -p /etc/bash_completion.d \
    && /bin/bash -lc 'cat /opt/kubectx/completion/kubectx.bash > /etc/bash_completion.d/kubectx' \
    && /bin/bash -lc 'cat /opt/kubectx/completion/kubens.bash  > /etc/bash_completion.d/kubens'

# kubectl bash completion for all users
RUN echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc

# ---- switch back to non-root user as you already had ----
USER vscode
WORKDIR /workspaces
