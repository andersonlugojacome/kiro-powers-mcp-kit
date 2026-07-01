#!/usr/bin/env bash
set -euo pipefail

# kiro-powers-mcp-kit — Setup verification script
# This script verifies prerequisites and runs preflight checks.
# The kit itself is installed via "Import Power From Github" in Kiro.

VERSION="1.0.0"
WARN_COUNT=0
BLOCKED=false

info()  { printf '\033[0;36m[INFO]\033[0m %s\n' "$1"; }
ok()    { printf '\033[0;32m[OK]\033[0m %s\n' "$1"; }
warn()  { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail()  { printf '\033[0;31m[BLOCKED]\033[0m %s\n' "$1"; BLOCKED=true; }

header() {
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║  kiro-powers-mcp-kit — Setup Verification   ║"
  echo "║  v${VERSION}                                       ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""
}

check_command() {
  local cmd="$1"
  local label="$2"
  local install_hint="$3"

  if command -v "$cmd" &> /dev/null; then
    local ver
    ver=$("$cmd" --version 2>/dev/null | head -1 || echo "unknown")
    ok "$label: $ver"
    return 0
  else
    warn "$label not found. Install: $install_hint"
    return 1
  fi
}

check_engram() {
  info "Checking Engram GO..."
  if check_command "engram" "Engram GO" "brew install gentleman-programming/tap/engram"; then
    # Preflight: can engram mcp start?
    if timeout 5 engram mcp --help &> /dev/null; then
      ok "Engram MCP: responds"
    else
      warn "Engram MCP: --help did not respond (may need update)"
    fi
  fi
}

check_node() {
  info "Checking Node.js..."
  if check_command "node" "Node.js" "brew install node / nvm install --lts"; then
    local node_major
    node_major=$(node -v | sed 's/v\([0-9]*\).*/\1/')
    if [ "$node_major" -ge 18 ]; then
      ok "Node.js version >= 18"
    else
      warn "Node.js version < 18. Context7 and mcp-remote require v18+"
    fi
  else
    fail "Node.js is required for Context7 and Atlassian MCP"
  fi
}

check_npx() {
  info "Checking npx..."
  check_command "npx" "npx" "comes with Node.js (npm)" || fail "npx required"
}

check_context7() {
  info "Preflight Context7..."
  if command -v npx &> /dev/null; then
    if timeout 15 npx -y @upstash/context7-mcp --help &> /dev/null 2>&1; then
      ok "Context7: responds"
    else
      warn "Context7: did not respond (check internet/npm connectivity)"
    fi
  else
    warn "Context7: skipped (npx not available)"
  fi
}

check_mcp_json() {
  info "Checking MCP config..."
  local mcp_path="$HOME/.kiro/settings/mcp.json"

  if [ -f "$mcp_path" ]; then
    if python3 -m json.tool "$mcp_path" > /dev/null 2>&1; then
      ok "mcp.json: valid JSON at $mcp_path"

      # Check for expected servers
      for server in engram context7 atlassian; do
        if grep -q "\"$server\"" "$mcp_path"; then
          ok "Server '$server': configured"
        else
          warn "Server '$server': not found in mcp.json"
        fi
      done
    else
      warn "mcp.json: invalid JSON at $mcp_path"
    fi
  else
    warn "mcp.json not found at $mcp_path (run Import Power From Github in Kiro)"
  fi
}

check_skills() {
  info "Checking skills..."
  local skills_path="$HOME/.kiro/skills"
  if [ -d "$skills_path" ]; then
    local count
    count=$(find "$skills_path" -name "SKILL.md" | wc -l | tr -d ' ')
    if [ "$count" -ge 10 ]; then
      ok "Skills installed: $count"
    else
      warn "Skills count low: $count (expected >= 10)"
    fi
  else
    warn "Skills directory not found: $skills_path"
  fi
}

report() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [ "$BLOCKED" = true ]; then
    fail "Status: BLOCKED — fix required items above"
    exit 1
  elif [ "$WARN_COUNT" -gt 0 ]; then
    warn "Status: WARN ($WARN_COUNT warning(s)) — kit may work partially"
    exit 0
  else
    ok "Status: OK — all checks passed"
    exit 0
  fi
}

# Main
header

if [ "${1:-}" = "--verify-only" ]; then
  info "Running verification only (no changes)"
fi

check_engram
check_node
check_npx
check_context7
check_mcp_json
check_skills
report
