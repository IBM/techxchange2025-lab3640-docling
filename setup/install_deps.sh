#!/bin/bash
set -e pipefail


sudo dnf install -y \
    python3.12 \
    htop \
    podman


## Setup Podman
sudo sysctl user.max_user_namespaces=15000
sudo usermod --add-subuids 200000-201000 --add-subgids 200000-201000 $USER

## Setup Python with uv
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python pin --global 3.12

