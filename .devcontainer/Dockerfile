# was: mcr.microsoft.com/devcontainers/python:3.12
FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends openjdk-17-jdk ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

USER vscode
WORKDIR /workspaces
