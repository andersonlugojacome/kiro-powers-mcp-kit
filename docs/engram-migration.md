# Engram Migration Document — kiro-powers-mcp-kit

> Documento vivo para persistir en Engram y poder migrar contexto completo a otro entorno.
> Generado: 2026-07-01 | Proyecto: kiro-powers-mcp-kit

---

## PARTE 1: Contexto, Objetivo, Exploration, Proposal

### 1.1 Contexto del Proyecto

**Repo:** https://github.com/andersonlugojacome/kiro-powers-mcp-kit
**Path local:** `/Users/andersonlugo/kiro-powers-mcp-kit`
**Branch:** `main`
**Stack:** Markdown + JSON + Shell (bash/zsh) + PowerShell (optional Windows)
**Instalacion:** Via "Import Power From Github" (mecanismo oficial de Kiro)

**Origen:** Transformacion de https://github.com/andersonlugojacome/mcp-kiro-kit (monolito PowerShell-only para Windows) a un kit modular cross-platform con MCP servers modernos.

### 1.2 Objetivo

Crear un **Kiro Power** publicable en GitHub que integre:

| MCP Server | Tipo | Comando |
|---|---|---|
| **Engram GO** | Binary local (stdio) | `engram mcp --project {project}` |
| **Context7** | NPX local (stdio) | `npx -y @upstash/context7-mcp` |
| **Atlassian** | Remote cloud (via mcp-remote) | `npx -y mcp-remote https://mcp.atlassian.com/v1/mcp` |

Plus: workflow SDD completo (9 skills de desarrollo + 2 operativas + 1 creator).

### 1.3 Exploration (resumen)

**Estado del original (mcp-kiro-kit-fix):**
- Monolito PowerShell: install-mcp-kiro.ps1 (~430 LOC)
- Solo Windows, sin tests, sin CI
- Usaba `engram-mcp-server` (npm viejo) o fallback `@modelcontextprotocol/server-memory`
- 14 skills, 2 steering files, docs/specs
- README de 17KB mezclando todo

**Problemas identificados:**
- Solo Windows/PowerShell
- Sin tests ni CI
- Skills SDD usaban server-memory (API limitada: 6 tools)
- Naming confuso entre repos
- No era un "Power" importable oficialmente

**Solucion elegida:** Kit de configuracion MCP como Kiro Power importable via GitHub, con Engram GO (20 tools, Go binary, SQLite+FTS5) como memoria principal.

### 1.4 Proposal

**Change name:** `transform-mcp-kiro-kit`

**Intent:** Kit MCP 4-servers + SDD workflow para Kiro, instalable via Import Power From Github.

**Scope In:**
- Config MCP para Engram GO, Context7, Atlassian (Jira+Confluence)
- 12 skills SDD migradas y adaptadas a Engram GO
- Steering actualizado (AGENTS + workflow + orchestrator)
- Scripts de verificacion/preflight cross-platform
- Docs por server + README de onboarding
- GitHub Actions para CI

**Scope Out:**
- Powers P7-P12 (team governance, canales, diagnostico corporativo)
- Engram Cloud setup (solo local)
- Bitbucket/Compass/JSM (solo Jira + Confluence)
- UI nativa dentro de Kiro

**Approach:** Scaffold -> Config -> Migrate skills -> Steering -> Scripts -> Docs -> CI

**Risk Level:** Medium (adaptacion skills al API de Engram GO)

### 1.5 Engram GO — Datos Tecnicos

**Repo:** https://github.com/Gentleman-Programming/engram
**Version:** v0.1.9+ (Go binary, SQLite + FTS5)
**Instalacion:** `brew install gentleman-programming/tap/engram`
**Setup Kiro:** `engram setup kiro`
**MCP Transport:** stdio (`engram mcp`)

**20 MCP Tools:**
- Save & Update: `mem_save`, `mem_update`, `mem_delete`, `mem_suggest_topic_key`
- Search & Retrieve: `mem_search`, `mem_context`, `mem_timeline`, `mem_get_observation`
- Session Lifecycle: `mem_session_start`, `mem_session_end`, `mem_session_summary`
- Conflict Surfacing: `mem_judge`, `mem_compare`
- Lifecycle Review: `mem_review`
- Utilities: `mem_save_prompt`, `mem_stats`, `mem_capture_passive`, `mem_merge_projects`, `mem_current_project`, `mem_doctor`

**Key Features:**
- `topic_key` para upserts (guardar actualiza, no duplica)
- `project` scope para aislar memorias por proyecto
- Sessions para tracking de ciclos de trabajo
- Conflict detection automatica en save
- FTS5 full-text search

### 1.6 Atlassian MCP — Datos Tecnicos

**Repo:** https://github.com/atlassian/atlassian-mcp-server
**Tipo:** Remote server (cloud-hosted por Atlassian)
**Endpoint:** `https://mcp.atlassian.com/v1/mcp` (API token) o `/mcp/authv2` (OAuth 2.1)
**Proxy local:** `npx -y mcp-remote` (traduce HTTP -> stdio)
**Auth:** OAuth 2.1 (browser flow) o API token (headless)

**Products soportados:**
- Jira: read, write, search (JQL)
- Confluence: read, write, search (CQL)
- Jira Service Management (solo API token)
- Bitbucket Cloud (solo API token, scoped)
- Compass (solo OAuth)

**Prerequisitos:**
- Atlassian Cloud site con Rovo MCP habilitado
- Admin debe habilitar API token auth o OAuth
- Node.js v18+ para mcp-remote

### 1.7 Context7 — Datos Tecnicos

**Package:** `@upstash/context7-mcp`
**Comando:** `npx -y @upstash/context7-mcp`
**Funcion:** Documentacion actualizada de librerias/frameworks via semantic search
**Tools:** `resolve-library-id`, `query-docs`

### 1.8 Estructura Target

```
kiro-powers-mcp-kit/
├── .kiro/
│   ├── settings/
│   │   └── mcp.json              # 3 MCP servers
│   ├── steering/
│   │   ├── AGENTS.md
│   │   ├── 01-mcp-workflow.md
│   │   └── 02-sdd-orchestrator-runtime.md
│   └── skills/
│       ├── _shared/              # Convenciones compartidas
│       │   ├── engram-convention.md
│       │   ├── persistence-contract.md
│       │   ├── sdd-phase-common.md
│       │   └── openspec-convention.md
│       ├── sdd-init/SKILL.md
│       ├── sdd-explore/SKILL.md
│       ├── sdd-propose/SKILL.md
│       ├── sdd-spec/SKILL.md
│       ├── sdd-design/SKILL.md
│       ├── sdd-tasks/SKILL.md
│       ├── sdd-apply/SKILL.md
│       ├── sdd-verify/SKILL.md
│       ├── sdd-archive/SKILL.md
│       ├── skill-creator/SKILL.md
│       ├── mcp-status-assistant/SKILL.md
│       └── kiro-update-assistant/SKILL.md
├── docs/
│   ├── setup-engram.md
│   ├── setup-atlassian.md
│   ├── setup-context7.md
│   ├── powers-roadmap.md
│   └── engram-migration.md       # Este documento
├── scripts/
│   ├── setup.sh                  # Verificacion macOS/Linux
│   └── setup.ps1                 # Verificacion Windows
├── .github/
│   └── workflows/
│       └── validate.yml
├── README.md
├── LICENSE
└── .gitignore
```

### 1.9 Tool Mapping: server-memory -> Engram GO

| server-memory tool | Engram GO tool | Notas |
|---|---|---|
| `create_entities` | `mem_save` | title + content como observacion |
| `add_observations` | `mem_update` | Actualiza observacion existente |
| `read_graph` | `mem_context` / `mem_stats` | Contexto del proyecto o estadisticas |
| `search_nodes` | `mem_search` | Query FTS5, retorna previews |
| `open_nodes` | `mem_get_observation` | Lee observacion completa por ID |
| `delete_entities` | `mem_delete` | Soft delete por defecto |
| `create_relations` | N/A (implicit via topic_key) | Engram usa topic_key para relaciones |
| `delete_relations` | N/A | No existe equivalente directo |
| `delete_observations` | `mem_delete` | Mismo tool |

### 1.10 Instalacion del Power

El kit se instala via mecanismo oficial de Kiro:

**Import Power From Github:**
```
Repo: andersonlugojacome/kiro-powers-mcp-kit
Branch: main
```

Esto importa automaticamente:
- `.kiro/settings/mcp.json` -> merge con config existente
- `.kiro/steering/` -> steering del proyecto
- `.kiro/skills/` -> skills disponibles

**Prerequisitos del usuario (antes de importar):**
1. Engram GO instalado: `brew install gentleman-programming/tap/engram`
2. Node.js v18+ (para Context7 y mcp-remote)
3. (Opcional) Atlassian Cloud con MCP habilitado

---

## PARTE 2: Spec, Design, Decisiones Tecnicas

### 2.1 Spec (R1-R6)

**R1. Configuracion MCP multi-server**
- Setup con prereqs -> mcp.json con 3 servers (engram, context7, atlassian)
- Setup sin Engram GO -> WARN con instrucciones, no bloquea context7
- Setup sin Atlassian -> configura engram+context7, atlassian opcional

**R2. Skills SDD compatibles con Engram GO**
- Persistir: `mem_save(title, topic_key, type, project, content)`
- Recuperar: `mem_search(query, project)` -> ID -> `mem_get_observation(id)`
- Sessions: `mem_session_start` / `mem_session_end` / `mem_session_summary`
- RESULTADO: Las skills ya usaban mem_save/mem_search nativamente. CERO cambios en las 9 skills SDD.

**R3. Steering multi-server**
- AGENTS.md referencia 3 MCP servers
- 01-mcp-workflow.md documenta flujo Engram GO
- 02-sdd-orchestrator-runtime.md usa tools Engram GO

**R4. Setup cross-platform**
- macOS/Linux: scripts/setup.sh (verifica engram, node, npx)
- Windows: scripts/setup.ps1 (equivalente)
- NOTA: Instalacion del kit es via Import Power From Github, NO por script

**R5. Documentacion**
- docs/setup-engram.md, docs/setup-atlassian.md, docs/setup-context7.md
- README con quick start < 5 min

**R6. CI/CD**
- GitHub Actions: JSON lint, markdownlint, shellcheck, skill count validation

### 2.2 Design (ADRs)

**ADR-1: Engram GO como memoria primaria**
- Go binary, SQLite+FTS5, 20 MCP tools, zero Node deps para memoria
- topic_key para upserts nativos
- Reemplaza @modelcontextprotocol/server-memory y engram-mcp-server (npm viejo)
- Requiere: `brew install gentleman-programming/tap/engram`

**ADR-2: Atlassian via mcp-remote proxy**
- Server remoto oficial de Atlassian (cloud-hosted)
- `npx mcp-remote https://mcp.atlassian.com/v1/mcp` como proxy local
- Auth: OAuth 2.1 (browser) o API token (headless)
- Node.js ya es req por Context7, no es costo extra

**ADR-3: Skills SDD sin cambios en nomenclatura**
- Las skills ya usan `mem_save`/`mem_search`/`mem_get_observation`
- Solo actualizar _shared/ docs (engram-convention.md, persistence-contract.md)
- No reescribir logica core de ninguna skill

**ADR-4: Server Atlassian como opcional**
- Kit funciona completo con solo Engram + Context7
- Atlassian requiere admin y cloud site, no todos lo tienen

**ADR-5: Instalacion via Import Power From Github**
- Mecanismo oficial de Kiro para importar Powers
- No scripts de instalacion como metodo principal
- Repo: andersonlugojacome/kiro-powers-mcp-kit, Branch: main

### 2.3 Persistence Contract v2

```
## Guardar artefacto SDD
mem_save(
  title: "sdd/{change-name}/{phase}",
  topic_key: "sdd/{change-name}/{phase}",
  type: "architecture",
  project: "{project-name}",
  content: "{markdown content}"
)

## Buscar artefacto
mem_search(query: "sdd/{change-name}/{phase}", project: "{project}")
-> returns: [{id, title, snippet, score}]

## Leer completo
mem_get_observation(id: {id-from-search})
-> returns: full content

## Sessions (nuevo en v2)
mem_session_start(project: "{project}", directory: "{cwd}")
mem_session_end(summary: "{what was accomplished}")
mem_session_summary() -> current session state

## Upsert
topic_key garantiza que mem_save actualiza en vez de duplicar.
```

### 2.4 Estado de implementacion a mitad de camino

| Fase | Estado | Archivos |
|---|---|---|
| Phase 1: Scaffold | DONE | mcp.json, LICENSE, .gitignore |
| Phase 2: Skills | DONE | 12 skills + 4 _shared |
| Phase 3: Steering | PENDING | |
| Phase 4: Scripts | PENDING | |
| Phase 5: Docs | PENDING | |
| Phase 6: CI | PENDING | |

**Hallazgo clave:** Las skills SDD del original ya usaban Engram GO tools nativamente (mem_save, mem_search, mem_get_observation). La migracion fue una copia directa sin modificaciones. Solo se reescribieron los archivos _shared/ y las 2 skills operativas (status y update).

---

## PARTE 3: Estado Final, Lecciones, Migracion

### 3.1 Tasks Completadas

| # | Task | Estado |
|---|---|---|
| 1 | Doc Engram PARTE 1 | DONE |
| 2 | Estructura de directorios | DONE |
| 3 | mcp.json con 3 servers | DONE |
| 4 | LICENSE MIT | DONE |
| 5 | .gitignore | DONE |
| 6 | engram-convention.md (Engram GO 20 tools) | DONE |
| 7 | persistence-contract.md (v2 con sessions) | DONE |
| 8 | sdd-phase-common.md | DONE |
| 9 | openspec-convention.md | DONE |
| 10 | 9 skills SDD migradas | DONE |
| 11 | skill-creator migrada | DONE |
| 12 | mcp-status-assistant (3 servers) | DONE |
| 13 | kiro-update-assistant (Import Power) | DONE |
| 14 | Doc Engram PARTE 2 | DONE |
| 15 | AGENTS.md | DONE |
| 16 | 01-mcp-workflow.md | DONE |
| 17 | 02-sdd-orchestrator-runtime.md | DONE |
| 18 | scripts/setup.sh | DONE |
| 19 | scripts/setup.ps1 | DONE |
| 20 | docs/setup-engram.md | DONE |
| 21 | docs/setup-atlassian.md | DONE |
| 22 | docs/setup-context7.md | DONE |
| 23 | docs/powers-roadmap.md | DONE |
| 24 | README.md | DONE |
| 25 | .github/workflows/validate.yml | DONE |
| 26 | Verificacion skills | DONE (12 validas) |
| 27 | Commit final | DONE |
| 28 | Doc Engram PARTE 3 | DONE |

### 3.2 Lecciones Aprendidas

1. **Skills SDD ya eran compatibles con Engram GO.** Las 9 skills del workflow SDD usaban `mem_save`/`mem_search`/`mem_get_observation` nativamente. La migracion fue una copia directa sin modificaciones. Solo se reescribieron los 4 archivos `_shared/` y las 2 skills operativas.

2. **Atlassian MCP es remoto, no local.** A diferencia de Engram y Context7 (que corren como procesos stdio locales), Atlassian usa un server cloud con proxy `mcp-remote`. Esto significa que la primera conexion requiere auth via browser o API token. El server es opcional — el kit funciona completo sin el.

3. **Import Power From Github es el mecanismo oficial.** No se necesitan scripts de instalacion complejos. Los scripts `setup.sh`/`setup.ps1` son solo para VERIFICACION de prerequisitos, no para instalacion.

4. **Engram GO reemplaza completamente server-memory.** El binary Go ofrece 20 tools vs 6 del viejo `@modelcontextprotocol/server-memory`. Sessions, conflicts, doctor, stats — todo built-in.

5. **El MCP de memory (server-memory) tuvo problemas de parsing durante esta sesion.** Engram GO via binary seria mas estable para este caso de uso.

### 3.3 Estado Final del Kit

```
kiro-powers-mcp-kit/
├── .kiro/settings/mcp.json          # 3 servers: engram, context7, atlassian
├── .kiro/steering/                   # 3 archivos: AGENTS, workflow, orchestrator
├── .kiro/skills/                     # 12 skills + 4 _shared docs
├── docs/                             # 5 docs (engram, atlassian, context7, roadmap, migration)
├── scripts/                          # 2 scripts (setup.sh, setup.ps1)
├── .github/workflows/validate.yml    # CI
├── README.md                         # Quick start
├── LICENSE                           # MIT
└── .gitignore
```

**Metricas:**
- 21 archivos nuevos
- 12 skills con SKILL.md valido
- 3 MCP servers configurados
- 5 Powers implementados (P1-P5)
- 7 Powers pendientes (P6-P12)

### 3.4 Como importar este Power

En Kiro:
```
Import Power From Github
Repo: andersonlugojacome/kiro-powers-mcp-kit
Branch: main
```

### 3.5 Como migrar este documento Engram a otro entorno

Este documento (`docs/engram-migration.md`) contiene TODO el contexto necesario para reconstruir el conocimiento del proyecto en un nuevo Engram. Para migrar:

**Opcion A: Guardar manualmente en Engram GO**

```bash
engram save "kiro-powers-mcp-kit migration doc" \
  "$(cat docs/engram-migration.md)" \
  --type architecture \
  --project kiro-powers-mcp-kit
```

**Opcion B: Importar via MCP tool**

```
mem_save(
  title: "kiro-powers-mcp-kit/full-context",
  topic_key: "kiro-powers-mcp-kit/full-context",
  type: "architecture",
  project: "kiro-powers-mcp-kit",
  content: "{contenido completo de este archivo}"
)
```

**Opcion C: Git sync**

Si el nuevo entorno tiene acceso al repo:
```bash
git clone https://github.com/andersonlugojacome/kiro-powers-mcp-kit
# El documento esta en docs/engram-migration.md
# Importar con engram import o mem_save
```

### 3.6 Contexto clave para sesiones futuras

Si un agente necesita continuar trabajo en este proyecto, debe saber:

1. **Instalacion:** via Import Power From Github, NO scripts
2. **Memoria:** Engram GO binary (brew install), NO server-memory npm
3. **Skills SDD:** ya compatibles, usan mem_save/mem_search nativamente
4. **Atlassian:** opcional, requiere cloud site + admin
5. **Context7:** sin install extra, solo Node.js 18+
6. **Powers P1-P5:** implementados. P6-P12: pendientes
7. **Repo:** github.com/andersonlugojacome/kiro-powers-mcp-kit
8. **Branch:** main

---

### 3.7 Adaptacion a formato oficial Kiro Power

El repo fue adaptado al formato oficial de Kiro Powers:

**Estructura oficial:**
```
POWER.md          # OBLIGATORIO — metadata + onboarding + steering docs
mcp.json          # MCP servers (Kiro lo registra automaticamente)
steering/         # Workflows cargados on-demand por Kiro
.kiro/skills/     # Skills SDD (referencia, no importadas por Power system)
```

**Cambios aplicados:**
1. Creado `POWER.md` con frontmatter (name, displayName, description, keywords, author)
2. Movido `mcp.json` a root (eliminado `.kiro/settings/mcp.json`)
3. Creado `steering/` en root con mcp-workflow.md y sdd-workflow.md
4. `.kiro/skills/` se mantiene como referencia (Kiro no auto-importa skills)
5. `.kiro/steering/` se mantiene como docs detallados adicionales

**Flujo de instalacion:**
1. Kiro → Powers panel → Add Custom Power → Import from GitHub
2. URL: https://github.com/andersonlugojacome/kiro-powers-mcp-kit
3. Kiro lee POWER.md, registra mcp.json, carga steering/ on-demand

---

*Documento generado: 2026-07-01 | Sesion completa | Formato Power oficial*
