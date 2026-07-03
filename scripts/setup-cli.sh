#!/usr/bin/env bash
#
# Merge kiro-powers-mcp-kit MCP servers into ~/.kiro/settings/mcp.json
# for kiro-cli compatibility.
#
# Kiro IDE loads MCP servers from Powers automatically, but kiro-cli only reads
# the top-level "mcpServers" in ~/.kiro/settings/mcp.json. This script merges
# the Power's servers without deleting any existing entries.
#
# Safe to run multiple times (idempotent).
# Requires: jq (https://jqlang.github.io/jq/)

set -euo pipefail

SETTINGS_DIR="$HOME/.kiro/settings"
SETTINGS_FILE="$SETTINGS_DIR/mcp.json"

# Servers to merge
# shellcheck disable=SC2016
POWER_SERVERS='{
  "power-kiro-powers-mcp-kit-engram": {
    "command": "engram",
    "args": ["mcp"],
    "disabled": false
  },
  "power-kiro-powers-mcp-kit-context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"],
    "disabled": false
  },
  "power-kiro-powers-mcp-kit-jira": {
    "command": "npx",
    "args": ["-y", "@aashari/mcp-server-atlassian-jira"],
    "env": {
      "ATLASSIAN_SITE_NAME": "${ATLASSIAN_SITE_NAME}",
      "ATLASSIAN_USER_EMAIL": "${ATLASSIAN_USER_EMAIL}",
      "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN}"
    },
    "disabled": false
  }
}'

echo "=== kiro-powers-mcp-kit: CLI setup ==="
echo ""

# Check jq is available
if ! command -v jq &>/dev/null; then
  echo "[!] ERROR: jq is required but not installed."
  echo "    Install: brew install jq (macOS) or sudo apt install jq (Linux)"
  exit 1
fi

# Ensure directory exists
if [ ! -d "$SETTINGS_DIR" ]; then
  mkdir -p "$SETTINGS_DIR"
  echo "[+] Created $SETTINGS_DIR"
fi

# Load existing config or create empty structure
if [ -f "$SETTINGS_FILE" ]; then
  if ! jq empty "$SETTINGS_FILE" 2>/dev/null; then
    echo "[!] ERROR: $SETTINGS_FILE contains invalid JSON. Fix it manually before running this script."
    exit 1
  fi
  CONFIG=$(cat "$SETTINGS_FILE")
  echo "[i] Loaded existing $SETTINGS_FILE"
else
  CONFIG='{}'
  echo "[+] No mcp.json found, creating new one"
fi

# Ensure mcpServers key exists
CONFIG=$(echo "$CONFIG" | jq 'if .mcpServers == null then .mcpServers = {} else . end')

ADDED=0
SKIPPED=0

# Iterate over each server to merge
for SERVER_NAME in $(echo "$POWER_SERVERS" | jq -r 'keys[]'); do
  # Check if server already exists
  EXISTS=$(echo "$CONFIG" | jq --arg name "$SERVER_NAME" '.mcpServers | has($name)')

  if [ "$EXISTS" = "true" ]; then
    echo "  [=] $SERVER_NAME already exists, skipping"
    SKIPPED=$((SKIPPED + 1))
  else
    # Extract server config and merge it
    SERVER_CONFIG=$(echo "$POWER_SERVERS" | jq --arg name "$SERVER_NAME" '.[$name]')
    CONFIG=$(echo "$CONFIG" | jq --arg name "$SERVER_NAME" --argjson server "$SERVER_CONFIG" '.mcpServers[$name] = $server')
    echo "  [+] Added $SERVER_NAME"
    ADDED=$((ADDED + 1))
  fi
done

# Write back with pretty formatting
echo "$CONFIG" | jq '.' > "$SETTINGS_FILE"

echo ""

# --- Install kiro_sdd agent ---
echo "--- Agent: kiro_sdd_bolivar ---"

AGENTS_DIR="$HOME/.kiro/agents"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_SOURCE="$SCRIPT_DIR/../.kiro/agents/kiro_sdd_bolivar.md"
AGENT_DEST="$AGENTS_DIR/kiro_sdd_bolivar.md"

if [ ! -d "$AGENTS_DIR" ]; then
  mkdir -p "$AGENTS_DIR"
  echo "  [+] Created $AGENTS_DIR"
fi

if [ -f "$AGENT_SOURCE" ]; then
  if [ -f "$AGENT_DEST" ]; then
    # Update only if source is newer
    if [ "$AGENT_SOURCE" -nt "$AGENT_DEST" ]; then
      cp "$AGENT_SOURCE" "$AGENT_DEST"
      echo "  [+] Updated kiro_sdd_bolivar agent (newer version)"
    else
      echo "  [=] kiro_sdd_bolivar agent already up to date"
    fi
  else
    cp "$AGENT_SOURCE" "$AGENT_DEST"
    echo "  [+] Installed kiro_sdd_bolivar agent"
  fi
else
  echo "  [!] Source agent not found at $AGENT_SOURCE"
  echo "      Run this script from the kiro-powers-mcp-kit directory"
fi

echo ""
echo "=== Done ==="
echo "  MCP servers — Added: $ADDED | Skipped: $SKIPPED"
echo "  Agent kiro_sdd_bolivar — installed to ~/.kiro/agents/"
echo ""
echo "  Restart kiro-cli to pick up the changes."
echo "  Switch to SDD agent: /agent swap kiro_sdd_bolivar"
echo ""
