#!/bin/bash

# ----------------------------
# Configuration
# ----------------------------
PIDFILE="$HOME/.jupyter_notebook.pid"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
NOTEBOOK_DIR="${REPO_DIR}/notebooks"
PORT=8888

# ----------------------------
# Function to get Jupyter URL
# ----------------------------
get_jupyter_url() {
    URL=$(uv run jupyter lab list | grep ":$PORT" | awk -F '::' '{print $1}')
    echo $URL
}

# ----------------------------
# Check if Jupyter is running
# ----------------------------
if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    echo "Jupyter Notebook is already running (PID $(cat $PIDFILE))."
    URL=$(get_jupyter_url)
    echo "Access it at: $URL"
else
    echo "Starting Jupyter Notebook in UV environment..."

    # Launch Jupyter in background via uv run
    nohup uv run jupyter lab --no-browser --port=$PORT --notebook-dir="$NOTEBOOK_DIR" > "$HOME/jupyter.log" 2>&1 &

    # Save PID
    echo $! > "$PIDFILE"
    echo "Jupyter Notebook started (PID $!)."

    # Give Jupyter a moment to generate token
    sleep 2
    URL=$(get_jupyter_url)
    echo "Access it at: $URL"
fi
