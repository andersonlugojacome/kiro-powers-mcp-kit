# SDD Workflow — Orchestration & Runtime

## Implementation Routing

SDD es el workflow estructurado para cambios con ambiguedad sustancial. No es la unica ruta — Kiro elige la mas liviana que resuelva el problema:

| Ruta | Cuando | Ejemplo |
|---|---|---|
| **Direct inline** | 1–3 archivos, cambio mecanico, patron claro | Fix typo, rename variable, agregar campo |
| **Delegated direct** | 4+ archivos, o 2+ writes no-triviales | Rename global, refactor de imports |
| **Optional SDD** | Ambiguedad de diseno, scope complejo, multiples decisiones | Auth system, feature compleja, migration |

SDD se activa SOLO por:
- Solicitud explicita del usuario (`/sdd-*` o "usá SDD")
- Propuesta del agente aceptada por el usuario

File count, lineas, o riesgo percibido NUNCA fuerzan SDD por si solos.

## Politica de Orquestacion

1. Consultar Engram (`mem_search`) en cada query antes de responder.
2. Mantener contador de consultas del usuario en sesion.
3. Refrescar Context7 cada 4 consultas.
4. Si hay incertidumbre tecnica, consultar Context7 de inmediato.
5. Evaluar ruta de implementacion (direct / delegated / SDD) antes de actuar.
6. Guardar decisiones en Engram (`mem_save`) al cerrar cada bloque.
7. Usar `mem_session_start`/`mem_session_end` para sesiones largas.

## SDD Commands

| Comando | Accion |
|---|---|
| `/sdd-init` | Inicializar proyecto |
| `/sdd-explore <topic>` | Explorar un tema |
| `/sdd-new <change>` | Explore + Propose |
| `/sdd-continue [change]` | Siguiente artefacto faltante |
| `/sdd-ff [change]` | Propose > Spec > Design > Tasks |
| `/sdd-apply [change]` | Implementar por lotes |
| `/sdd-verify [change]` | Verificar implementacion |
| `/sdd-archive [change]` | Archivar cambio |

## Concurrencia Permitida

| Combinacion | Permitido | Condicion |
|---|---|---|
| `sdd-spec` + `sdd-design` | SI | Proposal existe |
| `sdd-explore` + `sdd-propose` | NO | Mismo cambio |
| `sdd-tasks` | Solo despues de spec + design | |
| `sdd-apply` | Lotes secuenciales | Sin solape de archivos |
| `sdd-verify` | Despues de apply | Nunca durante apply activo |

## Gating por Fase

| Fase | Requiere |
|---|---|
| `sdd-propose` | Exploracion o scope claro |
| `sdd-spec` | Proposal |
| `sdd-design` | Proposal |
| `sdd-tasks` | Spec + Design |
| `sdd-apply` | Tasks + Spec + Design |
| `sdd-verify` | Apply-progress |
| `sdd-archive` | Verify-report |

## Persistence Convention

Todos los artefactos SDD se guardan en Engram con:
```
title:     sdd/{change-name}/{phase}
topic_key: sdd/{change-name}/{phase}
type:      architecture
project:   {project-name}
```

`topic_key` habilita upserts — guardar actualiza, no duplica.

## Recovery (post-compaction)

```
mem_search(query: "sdd/{change-name}/state", project: "{project}")
mem_get_observation(id: {id}) -> parse state -> restore
```

## Reporte Estandar

Cada fase devuelve: `status` (OK/WARN/BLOCKED), `executive_summary`, `artifacts`, `next_recommended`, `risks`, `skill_resolution`.

## Delegation Stop Rules

| Regla | Trigger | Accion |
|---|---|---|
| **Bounded read** | 1–3 archivos para decidir/verificar | Leer inline |
| **4-file rule** | Entender requiere 4+ archivos | Delegar exploracion acotada |
| **Write rule** | 2+ archivos no-triviales | Delegar un writer |
| **Context rule** | Lectura que prepara un write | Delegar junto con el write |
| **Per-action rule** | Tests, builds, installs | Worker fresco por accion |
| **Optional SDD rule** | Ambiguedad sustancial | Proponer SDD al usuario |

## Review Workload Guard

Despues de `sdd-tasks`, ANTES de `sdd-apply`:
- Si estimated changed lines > 400 → pausar, preguntar split vs exception.
- Delivery strategies: `ask-on-risk` (default), `auto-chain`, `single-pr`, `exception-ok`.
