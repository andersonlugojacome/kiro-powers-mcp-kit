<#
.SYNOPSIS
    Merge kiro-powers-mcp-kit MCP servers into ~/.kiro/settings/mcp.json for kiro-cli compatibility.

.DESCRIPTION
    Kiro IDE loads MCP servers from Powers automatically, but kiro-cli only reads
    the top-level "mcpServers" in ~/.kiro/settings/mcp.json. This script merges
    the Power's servers without deleting any existing entries.

    Safe to run multiple times (idempotent).
#>

$ErrorActionPreference = "Stop"

$settingsDir = Join-Path $env:USERPROFILE ".kiro" "settings"
$settingsFile = Join-Path $settingsDir "mcp.json"

# Servers to merge (from the Power's mcp.json)
$powerServers = @{
    "power-kiro-powers-mcp-kit-engram" = @{
        command = "engram"
        args = @("mcp")
        disabled = $false
    }
    "power-kiro-powers-mcp-kit-context7" = @{
        command = "npx"
        args = @("-y", "@upstash/context7-mcp")
        disabled = $false
    }
    "power-kiro-powers-mcp-kit-jira" = @{
        command = "npx"
        args = @("-y", "@aashari/mcp-server-atlassian-jira")
        env = @{
            ATLASSIAN_SITE_NAME = "`${ATLASSIAN_SITE_NAME}"
            ATLASSIAN_USER_EMAIL = "`${ATLASSIAN_USER_EMAIL}"
            ATLASSIAN_API_TOKEN = "`${ATLASSIAN_API_TOKEN}"
        }
        disabled = $false
    }
}

Write-Host "=== kiro-powers-mcp-kit: CLI setup ===" -ForegroundColor Cyan
Write-Host ""

# Ensure directory exists
if (-not (Test-Path $settingsDir)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    Write-Host "[+] Created $settingsDir" -ForegroundColor Green
}

# Load existing config or create empty structure
if (Test-Path $settingsFile) {
    $raw = Get-Content $settingsFile -Raw -Encoding UTF8
    try {
        $config = $raw | ConvertFrom-Json
    } catch {
        Write-Host "[!] ERROR: $settingsFile contains invalid JSON. Fix it manually before running this script." -ForegroundColor Red
        exit 1
    }
    Write-Host "[i] Loaded existing $settingsFile" -ForegroundColor Gray
} else {
    $config = [PSCustomObject]@{}
    Write-Host "[+] No mcp.json found, creating new one" -ForegroundColor Green
}

# Ensure mcpServers key exists
if (-not ($config.PSObject.Properties.Name -contains "mcpServers")) {
    $config | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{})
}

# Merge servers (add only if not already present)
$added = 0
$skipped = 0

foreach ($name in $powerServers.Keys) {
    if ($config.mcpServers.PSObject.Properties.Name -contains $name) {
        Write-Host "  [=] $name already exists, skipping" -ForegroundColor Yellow
        $skipped++
    } else {
        $serverObj = [PSCustomObject]@{}
        $server = $powerServers[$name]

        $serverObj | Add-Member -NotePropertyName "command" -NotePropertyValue $server.command
        $serverObj | Add-Member -NotePropertyName "args" -NotePropertyValue $server.args

        if ($server.ContainsKey("env")) {
            $envObj = [PSCustomObject]@{}
            foreach ($key in $server.env.Keys) {
                $envObj | Add-Member -NotePropertyName $key -NotePropertyValue $server.env[$key]
            }
            $serverObj | Add-Member -NotePropertyName "env" -NotePropertyValue $envObj
        }

        $serverObj | Add-Member -NotePropertyName "disabled" -NotePropertyValue $server.disabled

        $config.mcpServers | Add-Member -NotePropertyName $name -NotePropertyValue $serverObj
        Write-Host "  [+] Added $name" -ForegroundColor Green
        $added++
    }
}

# Write back with pretty formatting
$json = $config | ConvertTo-Json -Depth 10
Set-Content -Path $settingsFile -Value $json -Encoding UTF8

Write-Host ""

# --- Install kiro_sdd agent ---
Write-Host "--- Agent: kiro_sdd_bolivar ---" -ForegroundColor Cyan

$agentsDir = Join-Path $env:USERPROFILE ".kiro" "agents"
$agentSource = Join-Path $PSScriptRoot ".." ".kiro" "agents" "kiro_sdd_bolivar.md"
$agentDest = Join-Path $agentsDir "kiro_sdd_bolivar.md"

if (-not (Test-Path $agentsDir)) {
    New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
    Write-Host "  [+] Created $agentsDir" -ForegroundColor Green
}

if (Test-Path $agentSource) {
    if (Test-Path $agentDest) {
        # Update only if source is newer
        $srcTime = (Get-Item $agentSource).LastWriteTime
        $dstTime = (Get-Item $agentDest).LastWriteTime
        if ($srcTime -gt $dstTime) {
            Copy-Item -Path $agentSource -Destination $agentDest -Force
            Write-Host "  [+] Updated kiro_sdd_bolivar agent (newer version)" -ForegroundColor Green
        } else {
            Write-Host "  [=] kiro_sdd_bolivar agent already up to date" -ForegroundColor Yellow
        }
    } else {
        Copy-Item -Path $agentSource -Destination $agentDest -Force
        Write-Host "  [+] Installed kiro_sdd_bolivar agent" -ForegroundColor Green
    }
} else {
    Write-Host "  [!] Source agent not found at $agentSource" -ForegroundColor Red
    Write-Host "      Run this script from the kiro-powers-mcp-kit directory" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "  MCP servers — Added: $added | Skipped: $skipped"
Write-Host "  Agent kiro_sdd_bolivar — installed to ~/.kiro/agents/"
Write-Host ""
Write-Host "  Restart kiro-cli to pick up the changes." -ForegroundColor Gray
Write-Host "  Switch to SDD agent: /agent swap kiro_sdd_bolivar" -ForegroundColor Gray
Write-Host ""
