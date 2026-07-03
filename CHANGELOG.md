# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto adhiere a [Versionamiento Semántico](https://semver.org/lang/es/).

## [No publicado]

## [1.6.0] - 2026-07-03

### Agregado
- Se creó `CHANGELOG.md` con historial completo desde v1.0.0
- Se creó workflow de auto-release (`.github/workflows/release.yml`) — crea GitHub Release al mergear PR a main
- Se crearon scripts `setup-cli.ps1` y `setup-cli.sh` para compatibilidad con kiro-cli (merge seguro de MCP servers)
- Se documentó Step 5 opcional en POWER.md para usuarios de kiro-cli
- Se creó agent `kiro_sdd_bolivar` con personalidad costeña colombiana para workflow SDD (`/agent swap kiro_sdd_bolivar`, `Ctrl+Shift+S`)

### Cambiado
- Se actualizó `docs/setup-atlassian.md` para alinearlo con el approach real de `mcp.json.md`

## [1.5.0] - 2026-07-01

### Agregado
- Se agregó footer de licencia, privacidad y soporte en POWER.md para Power submission

## [1.4.1] - 2026-07-01

### Agregado
- Se agregó nota visible de versión instalada en el onboarding de POWER.md
- Se agregó campo `version` al frontmatter de POWER.md (1.4.0)

## [1.4.0] - 2026-07-01

### Agregado
- Se agregó campo `icon` al frontmatter de POWER.md (`assets/logo.png`)

## [1.3.0] - 2026-07-01

### Agregado
- Se agregó guía de configuración `mcp.json.md` con instrucciones de env vars
- Se agregó tabla de skills al README con descripciones y triggers
- Se agregaron instrucciones de setup para Windows 11 sin admin en POWER.md

### Cambiado
- Se reemplazó Atlassian remote MCP por `@aashari/mcp-server-atlassian-jira` (package local via npx)

### Corregido
- Se corrigió documentación de Jira server para usar env vars en vez de base64

## [1.2.0] - 2026-07-01

### Agregado
- Se agregó social preview image para GitHub

## [1.1.0] - 2026-07-01

### Agregado
- Se agregó logo SVG y badges al README

## [1.0.0] - 2026-07-01

### Agregado
- Scaffold inicial del proyecto con Engram GO + Context7 + Atlassian MCP
- Adaptación al formato oficial de Kiro Power
- Configuración de autenticación Atlassian con `.env.sample`
- Notificación proactiva de actualizaciones via GitHub releases API (P10)
- 12 skills SDD: init, explore, propose, spec, design, tasks, apply, verify, archive, skill-creator, mcp-status-assistant, kiro-update-assistant
- Steering files: AGENTS.md, mcp-workflow, sdd-orchestrator-runtime
- Documentación: setup-engram, setup-context7, setup-atlassian, powers-roadmap
- Workflow de validación CI (`validate.yml`)
- Scripts cross-platform: `setup.sh`, `setup.ps1`
