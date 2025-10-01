#!/bin/bash

# ----------------------------
# Configuration
# ----------------------------
PIDFILE="$HOME/.jupyter_notebook.pid"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
NOTEBOOK_DIR="${REPO_DIR}/notebooks"
PORT=8888
MAX_TRIES=10   # number of times to retry
SLEEP_TIME=2   # seconds between retries

# ----------------------------
# Function to get Jupyter URL
# ----------------------------
get_jupyter_url() {
    URL=$(uv run jupyter lab list | grep ":$PORT" | awk -F '::' '{print $1}')
    echo $URL
}

# ----------------------------
# Wait until Jupyter URL is ready
# ----------------------------
wait_for_url() {
    local count=0
    while [ $count -lt $MAX_TRIES ]; do
        URL=$(get_jupyter_url)
        if [ -n "$URL" ]; then
            echo "$URL"
            return 0
        fi
        sleep $SLEEP_TIME
        count=$((count+1))
    done
    return 1
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
    nohup uv run jupyter lab --no-browser --host="0.0.0.0" --port=$PORT --notebook-dir="$NOTEBOOK_DIR" --ServerApp.token='' > "$HOME/jupyter.log" 2>&1 &

    # Save PID
    echo $! > "$PIDFILE"
    echo "Jupyter Notebook started (PID $!)."

    echo "Waiting for Jupyter to be ready..."
    URL=$(wait_for_url)
    if [ $? -eq 0 ]; then
        echo "Access it at: $URL"
    else
        echo "Jupyter did not become ready after $MAX_TRIES attempts (~$((MAX_TRIES * SLEEP_TIME)) seconds)."
        echo "Check $HOME/jupyter.log for details."
    fi
fi
