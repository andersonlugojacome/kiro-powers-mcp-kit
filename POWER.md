---
name: "kiro-powers-mcp-kit"
displayName: "Kiro Powers MCP Kit"
version: "3.0.0"
icon: "https://raw.githubusercontent.com/andersonlugojacome/kiro-powers-mcp-kit/main/assets/logo.png"
description: "v3.0.0 — Framework de desarrollo organico (ODD) para Kiro: routing por complejidad real (direct/delegated/optional SDD), delivery por work-units, skills v3.x, RDD como switch de review independiente (file-based, 4R lens), memoria persistente (Engram GO), documentacion viva (Context7) y gestion de equipo (Jira)."
keywords: ["mcp", "engram", "memory", "jira", "confluence", "atlassian", "sdd", "context7", "spec-driven", "persistent memory", "documentation", "loop-controller", "organic-routing", "delegation", "chained-pr", "work-units", "judgment-day", "cognitive-load", "skill-registry"]
version: "2.0.0"
icon: "https://raw.githubusercontent.com/andersonlugojacome/kiro-powers-mcp-kit/main/assets/logo.png"
description: "v2.0.0 — Framework de desarrollo para Kiro con routing organico, RDD awareness (4R review lenses + gentle-ai CLI detection), delivery workflow, quality skills, Engram GO v1.15.3+, Context7 y Jira."
keywords: ["mcp", "engram", "memory", "jira", "confluence", "atlassian", "sdd", "context7", "spec-driven", "persistent memory", "documentation", "loop-controller", "organic-routing", "delegation", "chained-pr", "work-units", "judgment-day", "cognitive-load", "skill-registry", "rdd", "review", "4r-lenses"]
author: "Anderson Lugo"
---

# Kiro Powers MCP Kit

> **Version instalada: 3.0.0** — Escribi "estatus" para verificar estado MCP.
> **Version instalada: 2.0.0** — Escribi "estatus" para verificar estado MCP.

## Overview

Este Power es un **framework de desarrollo** que cambia como trabajas con Kiro:

- **Routing Organico** — Tres rutas de implementacion: direct inline (1-3 archivos), delegated direct (4+ archivos), y optional SDD (ambiguedad sustancial). El agente elige la mas liviana que resuelva el problema.
- **RDD Awareness** — Receipt-Driven Development con deteccion de `gentle-ai` CLI. Si esta instalado y habilitado: review nativo con 4R lenses. Si no: las lenses sirven como guias de calidad standalone. Review es informativo, NUNCA bloquea delivery.
- **SDD Workflow** — Proceso estructurado de 9 fases para cambios complejos: spec → design → tasks antes de escribir codigo. Gating obligatorio, TDD estricto, review workload guard. Se activa por solicitud o propuesta aceptada.
- **Delegation Stop Rules** — Reglas claras de cuando delegar: 4-file rule, write rule, context rule. Escala sin ceremonia innecesaria.
- **Engram GO** — Memoria persistente (20 MCP tools, SQLite + FTS5). Persiste artefactos, decisiones y progreso entre sesiones automaticamente.
- **Context7** — Documentacion actualizada de cualquier libreria via semantic search. Auto-refresh cada 4 queries.
- **Jira** — Integracion con gestion de equipo (read, write, search) — opcional.

> No es un bundle de herramientas MCP. Es un proceso que impone calidad con la ceremonia justa — SDD cuando hay ambiguedad, directo cuando no.

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

Workflow estructurado para cambios con ambiguedad sustancial. Se activa por solicitud explicita o propuesta aceptada — no por tamaño o riesgo percibido.

### Implementation Routing

| Ruta | Cuando | Ejemplo |
|---|---|---|
| **Direct inline** | 1–3 archivos, cambio mecanico, patron claro | Fix typo, rename, agregar campo |
| **Delegated direct** | 4+ archivos, 2+ writes no-triviales | Rename global, refactor de imports |
| **Optional SDD** | Ambiguedad de diseno, multiples decisiones | Auth system, feature compleja |

### Fases SDD

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

## RDD (Receipt-Driven Development)

Review informativo provisto por `gentle-ai` CLI. Se detecta automaticamente al inicio de sesion.

### Prerequisitos

```bash
# Verificar disponibilidad
go version            # Go runtime
gentle-ai --version   # gentle-ai CLI
```

### Modos de operacion

| `gentle-ai` instalado | RDD habilitado | Comportamiento |
|---|---|---|
| No | N/A | 4R lens skills como guias de calidad standalone |
| Si | No (disabled) | Respetar kill switch, implementar organicamente |
| Si | Si (enabled) | Lifecycle nativo completo via CLI |

### 4R Lens System

| Lens | ID | Foco |
|---|---|---|
| Risk | R1 | Seguridad, auth, data exposure, dependencies |
| Readability | R2 | Naming, complejidad, intencion, mantenibilidad |
| Reliability | R3 | Tests, edge cases, determinismo, contratos |
| Resilience | R4 | Fallbacks, retry, degradacion, observabilidad |

### Principio fundamental

> Review es informativo. NUNCA bloquea delivery. Approval es evidencia, no autoridad. Delivery es del humano.

### Kill Switch

```bash
gentle-ai review mode enable --scope global   # activar
gentle-ai review mode disable --cwd .         # desactivar
gentle-ai review mode status --cwd .          # consultar
```

Contrato completo: `.kiro/skills/_shared/rdd-contract.md`

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
| `branch-pr` | PRs con issue-first checks y conventional commits |
| `chained-pr` | Split de PRs >400 lineas en cadenas revisables |
| `work-unit-commits` | Commits como unidades de trabajo revisables |
| `cognitive-doc-design` | Docs que reducen carga cognitiva |
| `comment-writer` | Comentarios calidos y directos en PRs/issues |
| `judgment-day` | Review adversarial dual-blind |
| `issue-creation` | Issues desde evidencia de repo |
| `skill-registry` | Indexa y resuelve skills por contexto |
| `review-risk` | R1: Seguridad, auth, data exposure, dependencies |
| `review-readability` | R2: Naming, complejidad, intencion, mantenibilidad |
| `review-reliability` | R3: Tests, edge cases, determinismo, contratos |
| `review-resilience` | R4: Fallbacks, retry, degradacion, observabilidad |
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
<!-- release-trigger: v2.0.0 -->
