#!/bin/bash

set -e  # Exit immediately on error

# Set target directory and repository info
TARGET_DIR="$HOME/lab"
REPO_URL="https://github.com/IBM/techxchange2025-lab3640-docling"
BRANCH="main"  # Can be a branch name or tag

# Clone or update the repository
if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning repository into $TARGET_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
else
    echo "Repository already exists at $TARGET_DIR."
    echo "Attempting to update to latest $BRANCH..."
    cd "$TARGET_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
fi

# Change to the cloned directory
cd "$TARGET_DIR" || { echo "Failed to enter $TARGET_DIR"; exit 1; }

# --- Run expand_lvs.sh ---
SCRIPT="./setup/expand_lvs.sh"
if [ -f "$SCRIPT" ]; then
    echo "Running $(basename "$SCRIPT")..."
    sudo bash "$SCRIPT"
else
    echo "Script $(basename "$SCRIPT") not found."
    exit 1
fi

# --- Run enable_port_forwarding.sh ---
SCRIPT="./setup/enable_port_forwarding.sh"
if [ -f "$SCRIPT" ]; then
    echo "Running $(basename "$SCRIPT")..."
    sudo bash "$SCRIPT"
else
    echo "Script $(basename "$SCRIPT") not found."
    exit 1
fi

# --- Run install_deps.sh ---
SCRIPT="./setup/install_deps.sh"
if [ -f "$SCRIPT" ]; then
    echo "Running $(basename "$SCRIPT")..."
    bash "$SCRIPT"
else
    echo "Script $(basename "$SCRIPT") not found."
    exit 1
fi

# --- Run lab_init.sh ---
# SCRIPT="./setup/lab_init.sh"
# if [ -f "$SCRIPT" ]; then
#     echo "Running $(basename "$SCRIPT")..."
#     bash "$SCRIPT"
# else
#     echo "Script $(basename "$SCRIPT") not found."
#     exit 1
# fi
