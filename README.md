# Kiro Powers MCP Kit

> Contexto inteligente, memoria persistente, documentacion viva y Jira+Confluence — todo integrado en Kiro.

## Que es esto

Un **Kiro Power** que transforma tu agente en un companero de equipo contextualizado con:

| MCP Server | Funcion |
|---|---|
| **Engram GO** | Memoria persistente (20 tools, SQLite + FTS5) |
| **Context7** | Documentacion actualizada de cualquier libreria |
| **Atlassian** | Jira + Confluence (read, write, search) |

Plus: **SDD Workflow** completo (Spec-Driven Development) con 9 skills de desarrollo + 3 operativas.

## Quick Start (< 5 minutos)

### 1. Prerequisitos

```bash
# Engram GO (memoria)
brew install gentleman-programming/tap/engram

# Node.js v18+ (Context7 + Atlassian proxy)
node --version  # debe ser >= 18
```

### 2. Instalar el Power

En Kiro:
```
Import Power From Github
Repo: andersonlugojacome/kiro-powers-mcp-kit
Branch: main
```

### 3. Verificar

```bash
# macOS/Linux
./scripts/setup.sh

# O en Kiro, escribir: "estatus"
```

## MCP Servers

### Engram GO (memoria persistente)

```json
{ "command": "engram", "args": ["mcp"] }
```

Instalacion: `brew install gentleman-programming/tap/engram`
Docs: [setup-engram.md](docs/setup-engram.md)

### Context7 (documentacion viva)

```json
{ "command": "npx", "args": ["-y", "@upstash/context7-mcp"] }
```

Sin instalacion adicional. Requiere Node.js 18+.
Docs: [setup-context7.md](docs/setup-context7.md)

### Atlassian (Jira + Confluence)

```json
{ "command": "npx", "args": ["-y", "mcp-remote", "https://mcp.atlassian.com/v1/mcp"] }
```

Requiere Atlassian Cloud + OAuth/API token. **Opcional.**
Docs: [setup-atlassian.md](docs/setup-atlassian.md)

## Skills incluidas

### SDD Workflow (Spec-Driven Development)

| Skill | Funcion |
|---|---|
| `sdd-init` | Inicializa contexto del proyecto |
| `sdd-explore` | Explora ideas y alternativas |
| `sdd-propose` | Crea propuesta de cambio |
| `sdd-spec` | Escribe especificaciones |
| `sdd-design` | Define diseno tecnico |
| `sdd-tasks` | Descompone en tareas |
| `sdd-apply` | Implementa tareas |
| `sdd-verify` | Verifica implementacion |
| `sdd-archive` | Archiva cambio completado |

### Operativas

| Skill | Trigger |
|---|---|
| `skill-creator` | Crear nuevas skills |
| `mcp-status-assistant` | "estatus" o "status mcp" |
| `kiro-update-assistant` | "actualizame" o "update" |

## SDD Commands

```
/sdd-init          — Inicializar proyecto
/sdd-explore       — Explorar un tema
/sdd-new <cambio>  — Explore + Propose
/sdd-ff <cambio>   — Propose > Spec > Design > Tasks
/sdd-apply         — Implementar
/sdd-verify        — Verificar
/sdd-archive       — Archivar
```

## Powers Status

| Power | Estado |
|---|---|
| P1 Contexto inteligente | ✅ |
| P2 Memoria persistente | ✅ |
| P3 Documentacion viva | ✅ |
| P4 Health check | ✅ |
| P5 Actualizacion guiada | ✅ |
| P6-P12 Team features | 🔲 Pendiente |

[Roadmap completo](docs/powers-roadmap.md)

## Actualizar

En Kiro:
```
Import Power From Github
Repo: andersonlugojacome/kiro-powers-mcp-kit
Branch: main
```

O escribir en el chat: **"actualizame"**

## Estructura del proyecto

```
.kiro/
├── settings/mcp.json        # 3 MCP servers
├── steering/                # AGENTS + workflows
└── skills/                  # 12 skills + _shared
docs/                        # Guias por server
scripts/                     # Verificacion cross-platform
.github/workflows/           # CI
```

## Licencia

MIT
