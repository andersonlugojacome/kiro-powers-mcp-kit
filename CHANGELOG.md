# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto adhiere a [Versionamiento Semántico](https://semver.org/lang/es/).

## [No publicado]

## [1.9.0] - 2026-08-28

### Agregado
- **Skill `branch-pr`**: PRs con issue-first checks, branch naming regex, conventional commits, PR template format, automated checks reference
- **Skill `chained-pr`**: Split de PRs >400 lineas en cadenas revisables, dos estrategias (stacked-to-main, feature-branch-chain), dependency diagrams, chain context section, `references/chaining-details.md` con branch commands y reviewer guidance
- **Skill `work-unit-commits`**: Commits como unidades de trabajo revisables, reglas de colocacion (tests con codigo, docs con feature), SDD workload guard integration, split examples
- Tres skills interconectadas con cross-dependency: `work-unit-commits → chained-pr → branch-pr`

### Cambiado
- `POWER.md` actualizado a v1.9.0 con las 3 nuevas skills en la tabla de referencia
- Keywords actualizados con `chained-pr` y `work-units`

## [1.8.0] - 2026-08-28

### Agregado
- **Routing Organico (Implementation Routing)**: tres rutas de implementacion (direct inline, delegated direct, optional SDD) — SDD ya no es el default obligatorio, se activa por solicitud o propuesta aceptada
- **Delegation Stop Rules**: reglas formales de delegacion (4-file rule, write rule, bounded read, context rule, per-action rule, optional SDD rule) en el orchestrator runtime
- **Review Workload Guard**: pausa obligatoria si `sdd-tasks` forecasta >400 lineas cambiadas — pregunta split vs `size:exception`
- **Delivery Strategy**: soporte para `ask-on-risk` (default), `auto-chain`, `single-pr`, `exception-ok` en el orchestrator
- Se agregó campo `skill_resolution` al Result Contract de cada fase SDD

### Cambiado
- `02-sdd-orchestrator-runtime.md` reestructurado: nueva seccion "Implementation Routing" al inicio, "Delegation Stop Rules" formalizadas, Rol del Orquestador actualizado con evaluacion de ruta
- `AGENTS.md` actualizado: objetivo refleja routing organico, seccion SDD documenta cuando usar SDD vs direct, tabla de señales de routing
- `sdd-workflow.md` (root steering) actualizado: seccion "Implementation Routing" al inicio, delegation stop rules, review workload guard
- `POWER.md` Overview reescrito: routing organico como feature principal, SDD como opcion para ambiguedad

### Filosofia
- SDD es una herramienta poderosa para ambiguedad sustancial, no un requisito universal
- File count, lineas cambiadas, o riesgo percibido NUNCA fuerzan SDD por si solos
- El agente elige la ruta mas liviana que resuelva el problema sin ceremonia innecesaria

## [1.7.0] - 2026-07-09

### Agregado
- Se creó contrato del Execution Loop Controller (ELC) en `.kiro/skills/_shared/loop-controller-contract.md` — gobierna el sub-bucle `apply ⇄ verify` con criterio de parada, rollback granular, acumulación de restricciones y persistencia de lecciones en Engram
- Se agregó sección "Execution Loop Controller" al orchestrator runtime (`02-sdd-orchestrator-runtime.md`) con flujo operativo, 6 políticas clave y protocolo de escalamiento
- Se agregó `loop_feedback` al return envelope de `sdd-verify` (JSON estructurado con `suggested_action`, `trigger_context_refresh`, y `extracted_constraints`)
- Se agregó Step 2b "Loop-Aware Re-execution" a `sdd-apply` para consumir restricciones acumuladas del ELC (`PATCH_FORWARD` vs `ROLLBACK_AND_RETRY`)

## [1.6.1] - 2026-07-03

### Corregido
- Se corrigió trigger del workflow de release (`push` + `paths` en vez de `pull_request: closed`)
- Se corrigió ícono del Power usando URL absoluta de GitHub (Kiro IDE no copia `assets/` al instalar)
- Se actualizó `ludeeus/action-shellcheck` de `@master` a `@2.0.0` (Node.js 20 deprecation)

### Cambiado
- Se agregó versión visible en la description del Power panel (`v1.6.1 — ...`)

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
