#!/bin/bash

set -e pipefail

# Get the directory where this script is located
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


SECRETS_FILE="$SETUP_DIR/env.secrets"
EXAMPLE_FILE="$SETUP_DIR/env.secrets.example"

# Check if env.secrets exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "env.secrets not found. Creating from env.secrets.example..."
    
    # Copy example file
    if [ -f "$EXAMPLE_FILE" ]; then
        cp "$EXAMPLE_FILE" "$SECRETS_FILE"
        echo "Created $SECRETS_FILE from $EXAMPLE_FILE."
    else
        echo "Error: $EXAMPLE_FILE does not exist. Cannot create $SECRETS_FILE."
        exit 1
    fi

    # Prompt user for API key and Project ID
    read -p "Enter your WATSONX_APIKEY: " WATSONX_APIKEY
    # read -p "Enter your WATSONX_PROJECT_ID: " WATSONX_PROJECT_ID

    # Replace placeholder values in env.secrets
    sed -i "s|WATSONX_APIKEY=fillme|WATSONX_APIKEY=$WATSONX_APIKEY|" "$SECRETS_FILE"
    # sed -i "s|WATSONX_PROJECT_ID=fillme|WATSONX_PROJECT_ID=$WATSONX_PROJECT_ID|" "$SECRETS_FILE"

    echo "Updated $SECRETS_FILE with your credentials."
else
    echo "$SECRETS_FILE already exists. No action taken."
fi


## LITELLM for proxying LLM calls to watsonx.ai

CONTAINER_NAME="litellm"

# Check if the container is running
if podman ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -wq "$CONTAINER_NAME"; then
    echo "Container '$CONTAINER_NAME' is already running."
else
    echo "Container '$CONTAINER_NAME' is not running. Launching..."

    podman run --name="$CONTAINER_NAME" -d \
        -v "$SETUP_DIR/litellm_config.yaml":/app/config.yaml \
        --rm \
        -p 4000:4000 \
        --env-file "$SETUP_DIR/env.secrets" \
        ghcr.io/berriai/litellm:v1.74.9-stable \
        --config /app/config.yaml
fi


## Llama Stack for proxying LLM calls to watsonx.ai

export LLAMA_STACK_PORT=8321
CONTAINER_NAME="llamastack"
if podman ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -wq "$CONTAINER_NAME"; then
    echo "Container '$CONTAINER_NAME' is already running."
else
    echo "Container '$CONTAINER_NAME' is not running. Launching..."

    mkdir -p ~/.llama

    podman run --name="$CONTAINER_NAME" -d \
        --rm \
        -p $LLAMA_STACK_PORT:$LLAMA_STACK_PORT \
        -v ~/.llama:/root/.llama \
        llamastack/distribution-starter:0.2.22 \
        --port $LLAMA_STACK_PORT \
        --env MILVUS_URL=http://localhost:19530 \
        --env VLLM_URL=http://host.containers.internal:1234/v1
fi


# Launch the Jupyter notebooks
bash "$SETUP_DIR/start_jupyter.sh"

