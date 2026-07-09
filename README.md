<p align="center">
  <img src="assets/logo.svg" alt="Kiro Powers MCP Kit" width="160"/>
</p>

<h1 align="center">Kiro Powers MCP Kit</h1>

<p align="center">
  <strong>Framework de desarrollo Spec-Driven para Kiro</strong> — proceso estructurado, memoria persistente y documentacion viva.
</p>

<p align="center">
  <a href="https://github.com/andersonlugojacome/kiro-powers-mcp-kit/releases/latest"><img src="https://img.shields.io/github/v/release/andersonlugojacome/kiro-powers-mcp-kit?style=flat-square&color=6366f1" alt="Release"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License"/></a>
  <img src="https://img.shields.io/badge/SDD-9%20phases-6366f1?style=flat-square" alt="SDD Phases"/>
  <img src="https://img.shields.io/badge/powers-P1--P5%20%2B%20P10-34d399?style=flat-square" alt="Powers"/>
</p>

---

## El problema

Desarrollar con AI agents hoy tiene 3 problemas que nadie resuelve con herramientas sueltas:

1. **Codigo sin spec** — el agente genera codigo sin definir primero que debe hacer, como, ni por que. Resultado: rework constante.
2. **Amnesia entre sesiones** — cada vez que abris una conversacion nueva, perdiste todo el contexto anterior. Decisiones, descubrimientos, patrones: se evaporan.
3. **Documentacion muerta** — se consultan docs desactualizadas y se toman decisiones sobre APIs que ya cambiaron.

Estos no son problemas de *herramientas*. Son problemas de **proceso**.

## Que es esto

Un **framework de desarrollo** que cambia COMO trabajas con Kiro:

> **No es un bundle de herramientas MCP. Es un proceso estructurado (SDD) con infraestructura de soporte.**

| Capa | Funcion | Como |
|------|---------|------|
| **Proceso (SDD Workflow)** | Define COMO se desarrolla cada cambio | 9 fases: explore → propose → spec → design → tasks → apply → verify → archive |
| **Memoria (Engram GO)** | Persiste decisiones, hallazgos y artefactos entre sesiones | SQLite + FTS5, 20 MCP tools, topic-key upserts |
| **Documentacion (Context7)** | Garantiza que se consulten docs actualizadas | Semantic search sobre librerias, auto-refresh cada 4 queries |
| **Integracion (Jira)** | Conecta el proceso con la gestion del equipo | Read/write/search — opcional |

## Por que un framework y no solo herramientas

| Solo herramientas (antes) | Framework SDD (ahora) |
|---|---|
| El agente genera codigo ad-hoc | Cada cambio pasa por spec → design → tasks antes de escribir una linea |
| Se pierde contexto entre sesiones | Engram persiste artefactos, decisiones y progreso automaticamente |
| No hay trazabilidad de decisiones | Cada fase produce un artefacto verificable (proposal, spec, design, tasks) |
| Code review sin baseline | `sdd-verify` compara implementacion contra specs — review objectivo |
| Docs desactualizadas | Context7 refresca docs automaticamente, sin intervencion manual |
| Sin control de calidad de proceso | Gating obligatorio: no se puede implementar sin spec y design aprobados |
| TDD opcional | Strict TDD Mode: se detectan capabilities y se fuerza test-first |
| Loops infinitos de correccion | Execution Loop Controller: criterio de parada, rollback granular y restricciones acumuladas |

## SDD Workflow — El nucleo del framework

```
  explore ─→ propose ─→ spec ──→ tasks ─→ apply ─→ verify ─→ archive
                          ↑                  │
                       design ───────────────┘
```

### Fases

| Fase | Que produce | Comando |
|------|-------------|---------|
| **Init** | Contexto del proyecto (stack, convenciones, testing) | `/sdd-init` |
| **Explore** | Investigacion de alternativas y riesgos | `/sdd-explore <tema>` |
| **Propose** | Propuesta formal con intent, scope y approach | `/sdd-new <cambio>` |
| **Spec** | Requisitos verificables y escenarios | (automatico en pipeline) |
| **Design** | Decisiones de arquitectura y approach tecnico | (automatico en pipeline) |
| **Tasks** | Descomposicion en tareas concretas por lotes | (automatico en pipeline) |
| **Apply** | Implementacion por lotes secuenciales | `/sdd-apply` |
| **Verify** | Validacion contra specs (CRITICAL / WARNING / SUGGESTION) | `/sdd-verify` |
| **Archive** | Cierre y persistencia del cambio completado | `/sdd-archive` |

### Fast-forward

Para cambios donde ya tenes claridad:

```
/sdd-ff <nombre-del-cambio>
```

Ejecuta: propose → spec → design → tasks en secuencia sin pausas intermedias.

### Ventajas concretas

- **Review Workload Guard** — si un cambio supera 400 lineas, el framework propone chained PRs automaticamente
- **Strict TDD Mode** — detecta test runner y fuerza ciclos test-first en apply
- **Cross-session continuity** — todo artefacto queda en Engram con `topic_key`, recuperable en cualquier sesion futura
- **Dependency gating** — no se puede hacer apply sin tasks, no se puede hacer tasks sin spec+design. El proceso impone calidad.
- **Delivery strategy** — soporta `ask-on-risk`, `auto-chain`, `single-pr`, `exception-ok`
- **Execution Loop Controller** — gobierna el ciclo apply⇄verify con control determinista (ver abajo)

### Execution Loop Controller (ELC)

El ELC transforma el ciclo implicito `apply → falla → re-apply` en un proceso programatico y determinista:

```
  apply(task) ─→ verify(task) ─→ loop_feedback
                                      │
                         ┌────────────┴────────────┐
                         │                         │
                      [PASS]                    [FAIL]
                         │                         │
                    next task              iteration < max?
                                               │
                                    ┌──────────┴──────────┐
                                    │                     │
                                   SI                    NO
                                    │                     │
                          rollback/patch +         escalar al humano
                          accumulate constraint    con contexto
                                    │
                               re-apply(task)
```

| Capacidad | Que hace |
|-----------|----------|
| **Criterio de parada** | Max 3 iteraciones por tarea (configurable hasta 5). Sin loops infinitos. |
| **Rollback granular** | `PATCH_FORWARD` (fix encima del progreso) vs `ROLLBACK_AND_RETRY` (git checkout y approach diferente) |
| **Constraint accumulation** | Cada fallo se comprime a 200 chars y se inyecta como restriccion obligatoria al re-apply |
| **Context7 conditional** | Si el error indica API deprecada/firma incorrecta, refresca docs automaticamente antes del re-apply |
| **Post-mortem inteligente** | Lecciones arquitectonicas se persisten en Engram (no typos ni errores mecanicos) |
| **Aislamiento por tarea** | El fallo de Task 1.1 no afecta ni bloquea Task 1.2 |

## Infraestructura MCP (lo que soporta el framework)

### Engram GO — Memoria persistente

```json
{ "command": "engram", "args": ["mcp"] }
```

20 MCP tools. Persiste artefactos SDD, decisiones, hallazgos, y progreso de apply entre sesiones.
Docs: [docs/setup-engram.md](docs/setup-engram.md)

### Context7 — Documentacion viva

```json
{ "command": "npx", "args": ["-y", "@upstash/context7-mcp"] }
```

Auto-refresh cada 4 queries. Sin instalacion adicional. Node.js 18+.
Docs: [docs/setup-context7.md](docs/setup-context7.md)

### Jira — Integracion con gestion (opcional)

```json
{ "command": "npx", "args": ["-y", "@aashari/mcp-server-atlassian-jira"] }
```

Read/write/search sobre Jira Cloud. Requiere API token.
Docs: [docs/setup-atlassian.md](docs/setup-atlassian.md)

## Instalacion (< 5 minutos)

### 1. Prerequisitos

```bash
# Engram GO (memoria persistente)
brew install gentleman-programming/tap/engram

# Node.js v18+ (Context7 + Jira)
node --version  # debe ser >= 18
```

### 2. Instalar el Power en Kiro

1. Abrir Kiro → Panel de Powers → **Add Custom Power**
2. Seleccionar **Import power from GitHub**
3. Ingresar URL: `https://github.com/andersonlugojacome/kiro-powers-mcp-kit`
4. Click **Install**

Kiro registra automaticamente los MCP servers y carga los steering files.

### 3. Configurar Jira (opcional)

```bash
cp .env.sample .env
# Editar con tu email y API token de Atlassian
```

### 4. Verificar

```bash
# macOS/Linux
./scripts/setup.sh

# O en Kiro, escribir: "estatus"
```

## Skills incluidas

| Skill | Funcion |
|---|---|
| `sdd-init` | Inicializa contexto SDD del proyecto |
| `sdd-explore` | Explora ideas y alternativas |
| `sdd-propose` | Crea propuesta de cambio |
| `sdd-spec` | Escribe especificaciones verificables |
| `sdd-design` | Define diseno y arquitectura |
| `sdd-tasks` | Descompone en tareas por lotes |
| `sdd-apply` | Implementa siguiendo specs |
| `sdd-verify` | Verifica contra specs y tasks |
| `sdd-archive` | Archiva cambio completado |
| `skill-creator` | Crea nuevas skills |
| `mcp-status-assistant` | Muestra estado MCP |
| `kiro-update-assistant` | Guia actualizaciones |

## Estructura del repo

```
├── POWER.md                # Metadata + onboarding (Kiro lo lee)
├── mcp.json                # MCP servers (Kiro los registra)
├── steering/               # Workflows del framework
│   ├── mcp-workflow.md     # Politica de orquestacion MCP
│   └── sdd-workflow.md     # Reglas de proceso SDD
├── .kiro/
│   ├── skills/             # 12 skills SDD + operativas
│   └── steering/           # Steering detallado
├── docs/                   # Guias de setup por server
├── scripts/                # Verificacion cross-platform
└── .github/workflows/      # CI
```

## Actualizar

En Kiro: Panel de Powers → seleccionar power → **Check for updates** → **Install updates**

O escribir en el chat: **"actualizame"**

## Roadmap

| Power | Estado |
|---|---|
| P1 Contexto inteligente | ✅ |
| P2 Memoria persistente | ✅ |
| P3 Documentacion viva | ✅ |
| P4 Health check | ✅ |
| P5 Actualizacion guiada | ✅ |
| P10 Canales de actualizacion | ✅ |
| P6-P9, P11-P12 Team features | 🔲 Pendiente |

[Roadmap completo](docs/powers-roadmap.md)

## Licencia

MIT
