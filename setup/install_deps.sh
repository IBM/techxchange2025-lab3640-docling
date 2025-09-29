#!/bin/bash
set -e pipefail


sudo dnf install -y \
    python3.12 \
    htop \
    podman


## Setup Podman
sudo sysctl user.max_user_namespaces=15000
sudo usermod --add-subuids 200000-201000 --add-subgids 200000-201000 $USER

# Get the required container images
LLAMA_STACK_VERSION=0.2.23
LITELLM_VERSION=v1.74.9-stable
podman pull docker.io/llamastack/distribution-starter:${LLAMA_STACK_VERSION}
podman pull ghcr.io/berriai/litellm:${LITELLM_VERSION}

## Setup Python with uv
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python pin --global 3.12

## Install base python dependencies
uv sync

## Get Docling models
uv run docling-tools models download layout tableformer picture_classifier


