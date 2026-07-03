---
name: "kiro-powers-mcp-kit"
displayName: "Kiro Powers MCP Kit"
version: "1.6.0"
icon: "https://raw.githubusercontent.com/andersonlugojacome/kiro-powers-mcp-kit/main/assets/logo.png"
description: "v1.6.0 — Framework de desarrollo Spec-Driven para Kiro. Proceso estructurado (SDD, 9 fases), memoria persistente (Engram GO), documentacion viva (Context7) y gestion de equipo (Jira). Cambia COMO desarrollas, no solo que herramientas usas."
keywords: ["mcp", "engram", "memory", "jira", "confluence", "atlassian", "sdd", "context7", "spec-driven", "persistent memory", "documentation"]
author: "Anderson Lugo"
---

# Kiro Powers MCP Kit

> **Version instalada: 1.6.0** — Escribi "estatus" para verificar estado MCP.

## Overview

Este Power es un **framework de desarrollo** que cambia como trabajas con Kiro:

- **SDD Workflow** — Proceso estructurado de 9 fases: cada cambio pasa por spec → design → tasks antes de escribir codigo. Gating obligatorio, TDD estricto, review workload guard.
- **Engram GO** — Memoria persistente (20 MCP tools, SQLite + FTS5). Persiste artefactos, decisiones y progreso entre sesiones automaticamente.
- **Context7** — Documentacion actualizada de cualquier libreria via semantic search. Auto-refresh cada 4 queries.
- **Jira** — Integracion con gestion de equipo (read, write, search) — opcional.

> No es un bundle de herramientas MCP. Es un proceso que impone calidad, con infraestructura de soporte.

## Onboarding

### Step 1: Verify Engram GO is installed

Engram GO es la memoria persistente del kit. Un Go binary local.

```bash
# macOS
brew install gentleman-programming/tap/engram

# Verify
engram --version
```

Si ya tenes Engram instalado, verificar que responde:
```bash
engram doctor
```

### Step 2: Verify Node.js 18+

Necesario para Context7 y el proxy mcp-remote de Atlassian.

```bash
node --version  # debe ser >= 18
npx --version
```

### Step 3: Configurar Jira (variables de entorno)

#### Windows 11

1. Crear API Token en: https://id.atlassian.com/manage-profile/security/api-tokens
2. En PowerShell, setear variables a nivel usuario:

```powershell
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_SITE_NAME", "jirasegurosbolivar", "User")
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_USER_EMAIL", "tu.email@segurosbolivar.com", "User")
[System.Environment]::SetEnvironmentVariable("ATLASSIAN_API_TOKEN", "tu-api-token", "User")
```

O desde la UI:
1. Buscar "Variables de entorno" en el menu inicio
2. Click "Editar las variables de entorno de esta cuenta"
3. Agregar las 3 variables: `ATLASSIAN_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN`
4. Aceptar y reiniciar Kiro

#### macOS/Linux

```bash
# Agregar a ~/.zshrc o ~/.bashrc:
export ATLASSIAN_SITE_NAME="jirasegurosbolivar"
export ATLASSIAN_USER_EMAIL="tu.email@segurosbolivar.com"
export ATLASSIAN_API_TOKEN="tu-api-token"

# Recargar
source ~/.zshrc
```

#### Verificar

```bash
npx -y @aashari/mcp-server-atlassian-jira get --path "/rest/api/3/myself"
```

Si muestra tu usuario, las credenciales estan bien. Reiniciar Kiro.

### Step 4: Verify installation

```bash
# macOS/Linux — corre el script de verificacion
./scripts/setup.sh

# O en Kiro, escribi: "estatus"
```

### Step 5 (opcional): Habilitar para kiro-cli

Kiro IDE carga los MCP servers del Power automaticamente. Pero **kiro-cli** solo lee `~/.kiro/settings/mcp.json` — no lee Powers.

Si tambien usas kiro-cli, ejecuta el script de merge:

```powershell
# Windows (PowerShell)
./scripts/setup-cli.ps1
```

```bash
# macOS/Linux (requiere jq)
./scripts/setup-cli.sh
```

El script **solo agrega** los servers faltantes sin borrar ni modificar nada existente en tu `mcp.json`. Es idempotente (podés ejecutarlo multiples veces sin riesgo).

El script tambien instala el agent **kiro_sdd_bolivar** en `~/.kiro/agents/` — un agent alternativo con personalidad costeña colombiana especializado en el workflow SDD. Para usarlo:

```
/agent swap kiro_sdd_bolivar
```

O con keyboard shortcut: `Ctrl+Shift+S`

Luego reiniciar kiro-cli para que tome los cambios.

## Available Steering Files

- **sdd-workflow** — Workflow SDD completo: orquestacion, concurrencia, gating por fase
- **mcp-workflow** — Flujo de trabajo MCP: Engram + Context7 + Atlassian, troubleshooting

## Available MCP Servers

### engram
Memoria persistente local. Go binary con SQLite + FTS5.

**Tools principales:** `mem_save`, `mem_search`, `mem_get_observation`, `mem_context`, `mem_session_start`, `mem_session_end`, `mem_update`, `mem_delete`, `mem_stats`, `mem_doctor` (20 tools total).

```bash
# Setup automatico
engram setup kiro
```

### context7
Documentacion actualizada de librerias/frameworks.

**Tools:** `resolve-library-id`, `query-docs`

### jira
Jira Cloud via MCP local. Package: `@aashari/mcp-server-atlassian-jira`

**Tools:** `jira_get`, `jira_post`, `jira_put`, `jira_patch`, `jira_delete` — acceso completo a la REST API de Jira.

**Variables requeridas:**
| Variable | Valor |
|---|---|
| `ATLASSIAN_SITE_NAME` | `jirasegurosbolivar` (parte antes de .atlassian.net) |
| `ATLASSIAN_USER_EMAIL` | Tu email de Atlassian |
| `ATLASSIAN_API_TOKEN` | Token de https://id.atlassian.com/manage-profile/security/api-tokens |

## SDD Workflow (Spec-Driven Development)

Workflow estructurado para cambios sustanciales:

| Fase | Comando | Funcion |
|---|---|---|
| Init | `/sdd-init` | Inicializa contexto del proyecto |
| Explore | `/sdd-explore` | Investiga ideas y alternativas |
| Propose | `/sdd-propose` | Formaliza propuesta de cambio |
| Spec | `/sdd-spec` | Escribe especificaciones |
| Design | `/sdd-design` | Define diseno tecnico |
| Tasks | `/sdd-tasks` | Descompone en tareas |
| Apply | `/sdd-apply` | Implementa por lotes |
| Verify | `/sdd-verify` | Verifica contra specs |
| Archive | `/sdd-archive` | Archiva cambio completado |

### Dependency Graph

```
proposal -> specs --> tasks -> apply -> verify -> archive
             ^
             |
           design
```

### Persistence

Todos los artefactos SDD se persisten automaticamente en Engram GO via `topic_key` (upserts, sin duplicados).

## Best Practices

### Memoria (Engram GO)
- Consultar Engram en cada query antes de responder
- Guardar decisiones y hallazgos en Engram al cerrar cada bloque
- Usar `mem_session_start`/`mem_session_end` para sesiones largas
- `topic_key` previene duplicados en artefactos SDD

### Documentacion (Context7)
- Se refresca cada 4 consultas del usuario automaticamente
- Si hay incertidumbre tecnica, consultar de inmediato
- Fallback a contexto local si no responde

### Atlassian
- Configurar `cloudId` y `project key` en steering del proyecto para reducir token usage
- Usar `maxResults: 10` en searches
- Server opcional: no bloquea si no esta configurado

## Troubleshooting

### Engram GO
| Problema | Solucion |
|---|---|
| `engram: command not found` | `brew install gentleman-programming/tap/engram` |
| DB corrupta | `engram doctor` |
| Memorias de otro proyecto | Verificar `--project` flag |

### Context7
| Problema | Solucion |
|---|---|
| Timeout | Verificar internet, reintentar |
| Package not found | `npx clear-npx-cache` |

### Atlassian
| Problema | Solucion |
|---|---|
| Unauthorized | Renovar OAuth token o API token |
| Site admin required | Admin debe completar 3LO consent primero |

## Configuration

### Reducir token usage con Atlassian

Agregar en el steering de tu proyecto:
```markdown
## Atlassian Rovo MCP
- MUST use cloudId = "https://tu-site.atlassian.net"
- MUST use Jira project key = TUPROJ
- MUST use maxResults: 10 for ALL searches
```

## Skills Reference

Este Power incluye skills SDD en `.kiro/skills/` para uso con Engram GO:

| Skill | Funcion |
|---|---|
| `sdd-init` | Inicializa contexto SDD |
| `sdd-explore` | Explora alternativas |
| `sdd-propose` | Crea proposal |
| `sdd-spec` | Escribe specs |
| `sdd-design` | Define diseno |
| `sdd-tasks` | Descompone en tareas |
| `sdd-apply` | Implementa |
| `sdd-verify` | Verifica |
| `sdd-archive` | Archiva |
| `skill-creator` | Crea nuevas skills |
| `mcp-status-assistant` | Muestra estado MCP |
| `kiro-update-assistant` | Guia actualizaciones |

## License and support

This power is licensed under [MIT](LICENSE).

### MCP Servers used

| Server | License | Privacy | Support |
|---|---|---|---|
| **Engram GO** | [MIT](https://github.com/Gentleman-Programming/engram/blob/main/LICENSE) | [GitHub](https://github.com/Gentleman-Programming/engram) | [Issues](https://github.com/Gentleman-Programming/engram/issues) |
| **Context7** (@upstash/context7-mcp) | [MIT](https://github.com/upstash/context7/blob/main/LICENSE) | [Upstash Privacy](https://upstash.com/trust/privacy.pdf) | [Issues](https://github.com/upstash/context7/issues) |
| **Jira** (@aashari/mcp-server-atlassian-jira) | [ISC](https://github.com/aashari/mcp-server-atlassian-jira/blob/main/LICENSE) | [Atlassian Privacy](https://www.atlassian.com/legal/privacy-policy) | [Issues](https://github.com/aashari/mcp-server-atlassian-jira/issues) |

### Power support

- [Issues](https://github.com/andersonlugojacome/kiro-powers-mcp-kit/issues)
- [Discussions](https://github.com/andersonlugojacome/kiro-powers-mcp-kit/discussions)
- [Privacy Policy](https://digitalesweb.com/privacy-policy/)
- Email: andersonlugojacome@gmail.com
<!-- release-trigger: v1.6.0 -->
