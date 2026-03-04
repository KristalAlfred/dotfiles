#!/bin/bash
# Configure Claude Code MCP servers
# Script hash: 1 (bump this number to re-run)

if ! command -v claude &> /dev/null; then
    echo "claude not found, skipping MCP setup"
    exit 0
fi

claude mcp add --scope user playwright npx @playwright/mcp@latest 2>/dev/null || true
echo "Claude MCP servers configured"
