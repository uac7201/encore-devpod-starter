# Devcontainers base image (has common tooling + non-root user 'vscode')
FROM mcr.microsoft.com/devcontainers/python:3.12

# Install Java 17 (LTS) for Spark
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jdk ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

# Speed up pip installs & set UTF-8
ENV PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Switch back to the non-root user provided by the base image
USER vscode
WORKDIR /workspaces
