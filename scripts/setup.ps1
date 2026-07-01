# kiro-powers-mcp-kit — Setup verification script (Windows)
# This script verifies prerequisites and runs preflight checks.
# The kit itself is installed via "Import Power From Github" in Kiro.

param(
  [switch]$VerifyOnly
)

$ErrorActionPreference = "Stop"
$Version = "1.0.0"
$WarnCount = 0
$Blocked = $false

function Write-Info { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Ok { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-WarnMsg { param([string]$Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow; $script:WarnCount++ }
function Write-Fail { param([string]$Message) Write-Host "[BLOCKED] $Message" -ForegroundColor Red; $script:Blocked = $true }

function Show-Header {
  Write-Host ""
  Write-Host "  kiro-powers-mcp-kit - Setup Verification v$Version" -ForegroundColor Cyan
  Write-Host "  ================================================" -ForegroundColor Cyan
  Write-Host ""
}

function Test-Command {
  param([string]$Command, [string]$Label, [string]$InstallHint)

  $cmd = Get-Command $Command -ErrorAction SilentlyContinue
  if ($null -ne $cmd) {
    $ver = & $Command --version 2>&1 | Select-Object -First 1
    Write-Ok "$Label`: $ver"
    return $true
  } else {
    Write-WarnMsg "$Label not found. Install: $InstallHint"
    return $false
  }
}

function Test-Engram {
  Write-Info "Checking Engram GO..."
  if (Test-Command -Command "engram" -Label "Engram GO" -InstallHint "Download from github.com/Gentleman-Programming/engram/releases") {
    try {
      $helpOutput = & cmd /c "engram mcp --help" 2>&1
      if ($LASTEXITCODE -eq 0) { Write-Ok "Engram MCP: responds" }
      else { Write-WarnMsg "Engram MCP: --help returned error" }
    } catch {
      Write-WarnMsg "Engram MCP: could not verify"
    }
  }
}

function Test-Node {
  Write-Info "Checking Node.js..."
  if (Test-Command -Command "node" -Label "Node.js" -InstallHint "scoop install nodejs-lts / winget install OpenJS.NodeJS.LTS") {
    $ver = & node -v
    $major = [int]($ver -replace 'v(\d+)\..*', '$1')
    if ($major -ge 18) { Write-Ok "Node.js version >= 18" }
    else { Write-WarnMsg "Node.js version < 18. Context7 and mcp-remote require v18+" }
  } else {
    Write-Fail "Node.js is required for Context7 and Atlassian MCP"
  }
}

function Test-Npx {
  Write-Info "Checking npx..."
  if (-not (Test-Command -Command "npx" -Label "npx" -InstallHint "comes with Node.js")) {
    Write-Fail "npx required"
  }
}

function Test-Context7 {
  Write-Info "Preflight Context7..."
  if (Get-Command npx -ErrorAction SilentlyContinue) {
    try {
      $job = Start-Job { & cmd /c "npx -y @upstash/context7-mcp --help" 2>&1 }
      $completed = Wait-Job $job -Timeout 15
      if ($completed -and $job.State -ne "Failed") {
        Write-Ok "Context7: responds"
      } else {
        Write-WarnMsg "Context7: did not respond (check internet)"
      }
      Remove-Job $job -Force -ErrorAction SilentlyContinue
    } catch {
      Write-WarnMsg "Context7: verification failed"
    }
  } else {
    Write-WarnMsg "Context7: skipped (npx not available)"
  }
}

function Test-McpJson {
  Write-Info "Checking MCP config..."
  $mcpPath = Join-Path $env:USERPROFILE ".kiro\settings\mcp.json"

  if (Test-Path $mcpPath) {
    try {
      $json = Get-Content $mcpPath -Raw | ConvertFrom-Json
      Write-Ok "mcp.json: valid JSON at $mcpPath"

      foreach ($server in @("engram", "context7", "atlassian")) {
        if ($null -ne $json.mcpServers.$server) {
          Write-Ok "Server '$server': configured"
        } else {
          Write-WarnMsg "Server '$server': not found in mcp.json"
        }
      }
    } catch {
      Write-WarnMsg "mcp.json: invalid JSON at $mcpPath"
    }
  } else {
    Write-WarnMsg "mcp.json not found (run Import Power From Github in Kiro)"
  }
}

function Test-Skills {
  Write-Info "Checking skills..."
  $skillsPath = Join-Path $env:USERPROFILE ".kiro\skills"
  if (Test-Path $skillsPath) {
    $count = @(Get-ChildItem -Path $skillsPath -Recurse -Filter "SKILL.md").Count
    if ($count -ge 10) { Write-Ok "Skills installed: $count" }
    else { Write-WarnMsg "Skills count low: $count (expected >= 10)" }
  } else {
    Write-WarnMsg "Skills directory not found: $skillsPath"
  }
}

function Show-Report {
  Write-Host ""
  Write-Host "  ================================================" -ForegroundColor Cyan
  if ($script:Blocked) {
    Write-Fail "Status: BLOCKED - fix required items above"
    exit 1
  } elseif ($script:WarnCount -gt 0) {
    Write-WarnMsg "Status: WARN ($($script:WarnCount) warning(s))"
    exit 0
  } else {
    Write-Ok "Status: OK - all checks passed"
    exit 0
  }
}

# Main
Show-Header
if ($VerifyOnly) { Write-Info "Running verification only (no changes)" }

Test-Engram
Test-Node
Test-Npx
Test-Context7
Test-McpJson
Test-Skills
Show-Report
