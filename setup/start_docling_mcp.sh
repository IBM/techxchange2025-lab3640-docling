#!/bin/bash

# Name of the process to search for
PROCESS_NAME="docling-mcp-server"

# Check if process is already running
if pgrep -f "$PROCESS_NAME" > /dev/null; then
    echo "MCP server is already running."
else
    echo "Starting MCP server..."
    export DOCLING_MCP_LLS_EXTRACTION_MODEL=vllm/gpt-oss-120b
    export DOCLING_MCP_KEEP_IMAGES=1
    nohup uv run docling-mcp-server --port 8000 --host 0.0.0.0 --transport streamable-http conversion generation llama-stack-rag > mcp_server.log 2>&1 &
    echo "MCP server started with PID $!"
fi
