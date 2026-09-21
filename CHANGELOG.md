# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto adhiere a [Versionamiento Semántico](https://semver.org/lang/es/).

## [No publicado]

## [3.0.1] - 2026-09-21

Sincronizacion de los contratos `_shared` de los skills SDD con **gentle-ai v3.4.0**, manteniendo la portabilidad file-based (Opcion A). Cambio de mantenimiento sin nuevas features ni breaking changes: el delta v3.2.1 -> v3.4.0 es acotado (casi todo es infraestructura Go/CLI que no toca los skills distribuidos).

### Cambiado
- **`engram-convention.md`**: se adopta el protocolo `mem_review` lifecycle, Optional State Hint y research artifacts de v3.4.0; se conservan el Prompt Capture Protocol (`capture_prompt`/`mem_save_prompt`) y la tabla de 20+ tools de Engram GO propios del Power
- **`persistence-contract.md`**: se adopta Mode Roles/Comparison, READ-MERGE-WRITE y sub-agent response ordering de v3.4.0; se conserva la tabla de migracion server-memory -> Engram GO
- **`sdd-phase-common.md`**: Review Workload Guard (budget 400 lineas) + validacion de task-result auto-degradante (verbatim 3.4.0)
- **`openspec-convention.md`**: Delta Spec Sections + filas `research.md` (verbatim 3.4.0)
- **`review-ledger-contract.md`** (+ variante `-pi`): transporte OpenCode Task (verbatim 3.4.0)

### Conservado
- Las **4R review lenses** standalone y los contratos file-based `rdd-contract.md` + `loop-controller-contract.md`
- El banner de fallback file-based en `sdd-orchestrator-sections.md` y `sdd-status-contract.md` (su cuerpo ya coincidia con 3.4.0, sin cambios)
- Todos los SKILL.md quedan identicos salvo los 2 Power-especificos (`kiro-update-assistant`, `mcp-status-assistant`), que NO se sobrescriben

### Fuera de alcance
- Dependencia de la CLI nativa `gentle-ai`
- `go-testing` / `gentle-ai-bench` (product-specific de gentle-ai)

## [3.0.0] - 2026-09-18

Alineacion con gentle-ai v3.x: el framework pasa de SDD-first a **ODD-first** (Organic Driven Development), con SDD como rama de planificacion y RDD como switch de review independiente. Migracion **portable/file-based** (Opcion A): el Power sigue funcionando sin la CLI gentle-ai instalada.

### Agregado
- **Skills nuevos**: `sdd-research`, `sdd-onboard`, `rdd-defect-workflow`, `systemic-issue-triage`, `skill-improver`
- **Contratos _shared nuevos**: `review-ledger-contract.md` (+ variante `-pi`), `research-lifecycle.md`, `skill-resolver.md`, `sdd-status-contract.md`, `sdd-orchestrator-sections.md`, `README.md`
- **Documentacion ODD**: README y `docs/sdd-getting-started.md` reescritos con las 3 rutas de implementacion (direct inline / delegated direct / optional SDD), Mandatory Delegation Triggers, tracking automatico `odd/tasks/`, y RDD con tiers de riesgo (passive/medium/high) + 4R lens

### Cambiado
- **9 skills SDD** actualizados al contenido v3.x (ODD routing, work-unit delivery, references/ y strict-tdd companions)
- **Skills de delivery/quality** actualizados: `branch-pr`, `chained-pr`, `work-unit-commits`, `cognitive-doc-design`, `comment-writer`, `judgment-day`, `issue-creation`, `skill-creator`, `skill-registry`
- Clausula de **fallback file-based** insertada donde los contratos referencian la CLI nativa `gentle-ai`, para preservar la portabilidad del Power
- `docs/powers-roadmap.md`: nota de ODD default + RDD independiente

### Conservado
- Las **4R review lenses** (`review-risk/readability/reliability/resilience`) se mantienen standalone
- Contratos file-based `_shared/rdd-contract.md` y `_shared/loop-controller-contract.md`
- `mcp-status-assistant` y `kiro-update-assistant` (Power-especificos: cubren los 3 MCP servers y el updater del repo) NO se sobrescribieron con la version v3

### Notas
- NO se adopta la dependencia de la CLI nativa `gentle-ai` (review/sdd-status): degrada a file-based
- NO se incluyen `go-testing` ni `gentle-ai-bench` (product-specific de gentle-ai)
- Artefactos SDD de este cambio persistidos en Engram (`sdd/v3-skills-migration/*`)
## [2.0.0] - 2026-08-28

### Agregado
- **RDD Awareness (Receipt-Driven Development)**: Deteccion automatica de `gentle-ai` CLI + Go al inicio de sesion. Si instalado y habilitado: lifecycle nativo. Si no: 4R lens skills como guias de calidad standalone.
- **4R Review Lens Skills**: Cuatro skills de review read-only portadas de gentle-ai upstream:
  - `review-risk` (R1): Seguridad, privilege boundaries, data exposure, dependencies
  - `review-readability` (R2): Naming, complejidad, intencion, mantenibilidad
  - `review-reliability` (R3): Tests, coverage, edge cases, determinismo, contratos
  - `review-resilience` (R4): Fallbacks, retry/backoff, graceful degradation, observabilidad
- **`_shared/rdd-contract.md`**: Contrato completo de RDD — kill switch, risk tiers, lens selection, consent model, correction budget, findings ledger schema, integracion con skills existentes
- Seccion "RDD Awareness" en orchestrator runtime (`02-sdd-orchestrator-runtime.md`) con deteccion de CLI, tabla de comportamiento, 4R overview
- Seccion "RDD" en AGENTS.md con deteccion de Go + gentle-ai, principio informativo, 4R table
- Seccion "RDD" en POWER.md con prerequisitos, modos de operacion, 4R table, kill switch commands

### Cambiado
- `POWER.md` bump a v2.0.0 — Overview incluye RDD awareness como feature principal
- Breaking: el Power ahora asume que si `gentle-ai` esta disponible, se usa nativamente para review

### Filosofia
- Review es informativo — NUNCA bloquea delivery
- El kill switch es del usuario — el agente NUNCA habilita RDD por cuenta propia
- Sin CLI las 4R lenses funcionan como checklists de calidad, sin lifecycle nativo
- Severity: BLOCKER/CRITICAL entran al fix loop, WARNING/SUGGESTION son info

## [1.11.0] - 2026-08-28

### Agregado
- **Engram Protocol v1.15.3+**: Soporte para `capture_prompt` parameter en `mem_save` — diferencia entre saves automatizados (SDD artifacts, `capture_prompt: false`) y saves humanos (decisions/discoveries, default `true`)
- **`mem_save_prompt` tool**: Documentado en engram-convention. Registra prompt del usuario para SessionActivity y dedup antes de saves derivados.
- **Skill `skill-registry`**: Skill formalizada para indexar y resolver skills por contexto de archivo y tarea. Genera `.atl/skill-registry.md` + cache hash. Persiste a Engram para cross-session resolution.
- Nuevas tools en referencia: `mem_session_summary`, `mem_merge_projects`, `mem_doctor`
- Categoria "Prompt Capture" separada en tools reference

### Cambiado
- `_shared/engram-convention.md` actualizado: nueva seccion "Prompt Capture Protocol" al inicio, tablas de cuando usar `capture_prompt: true/false`, writing artifacts section con `capture_prompt: false` para SDD, human decisions section sin override
- `_shared/persistence-contract.md` actualizado: sub-agent prompts incluyen `capture_prompt` guidance
- `POWER.md` actualizado a v1.11.0 con skill-registry en tabla

## [1.10.0] - 2026-08-28

### Agregado
- **Skill `cognitive-doc-design`**: Patrones para docs que reducen carga cognitiva — lead with the answer, progressive disclosure, chunking, signposting, recognition over recall, review empathy. Incluye template de doc shape y reglas para PR descriptions.
- **Skill `comment-writer`**: Comentarios calidos y directos para colaboracion — formula (observacion + por que + accion), anti-patrones, matching de idioma al contexto.
- **Skill `judgment-day`**: Review adversarial dual-blind — dos jueces paralelos en scope congelado, merge de hallazgos, fix actor acotado, max 2 rounds, verdicts APPROVED/ESCALATED. Incluye `references/prompts-and-formats.md` con templates de judge, fix actor, y ledger merge rules.
- **Skill `issue-creation`**: Creacion y triage de issues desde evidencia — duplicate search obligatorio, YAML forms como autoridad, privacy scan, protected labels, decision gates. Incluye `references/delegated-workflow-actions.md` con modelo de autoridad.

### Cambiado
- `POWER.md` actualizado a v1.10.0 con las 4 nuevas skills en tabla de referencia
- Keywords actualizados con `judgment-day` y `cognitive-load`

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
