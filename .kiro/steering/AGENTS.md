---
inclusion: always
---

# Kiro AGENTS (kiro-powers-mcp-kit)

## Objetivo

Guiar a Kiro para trabajar con alta confiabilidad tecnica, minimo consumo de tokens y seguridad MCP en equipos Windows y macOS. Elegir la ruta de implementacion mas liviana que resuelva el problema — SDD es una herramienta poderosa, no un requisito universal.

## MCP Servers Disponibles

| Server | Funcion | Prerequisito |
|---|---|---|
| **engram** | Memoria persistente (Engram GO, 20 tools) | `engram` binary instalado |
| **context7** | Documentacion actualizada de librerias | Node.js 18+ |
| **atlassian** | Jira + Confluence (read/write/search) | Atlassian Cloud + auth |

## Reglas Operativas

- Verifica primero: no afirmes nada tecnico sin comprobar archivos, comandos o docs.
- Cambios idempotentes: ejecutar dos veces no rompe ni duplica.
- Seguridad MCP: no hardcodees secretos en archivos del proyecto.
- Menos ruido, mas senal: respuestas compactas y con evidencia.
- No edites fuera del alcance pedido.

## Politica de Seguridad

- Nunca escribas API keys en `.kiro/settings/mcp.json` ni en steering.
- Usa variables de entorno para credenciales.
- Redacta logs sin datos sensibles.
- Si detectas material sensible en texto plano, reportalo y propone remediacion.

## Verificacion Tecnica Obligatoria

1. Confirmar prerequisitos (`engram`, `node`, `npx`).
2. Validar JSON antes de guardar configuraciones.
3. Probar MCP servers con chequeo rapido cuando aplique.
4. Informar resultado: OK, WARN o BLOQUEO.

## Eficiencia de Tokens

- Prioriza contexto local y archivos del proyecto antes de buscar afuera.
- Evita repetir diagnosticos; reusa hallazgos ya verificados.
- Resume salidas largas y conserva solo lineas relevantes.
- Para tareas grandes, dividir en pasos cortos con checkpoints.

## Uso de Contexto Local

- Leer primero `.kiro/steering/` y `.kiro/skills/` del repo activo.
- Si hay conflicto entre global y local, priorizar local del equipo.
- Mantener rutas portables dentro de `.kiro/skills`.

## Reuso Inteligente (Engram + Context7)

- En cada consulta, consultar Engram primero para contexto previo.
- Refrescar Context7 cada 4 consultas o ante incertidumbre tecnica.
- Si tarea es repetida, recuperar enfoque anterior y evitar retrabajo.
- Priorizar: 1) contexto local, 2) memoria Engram, 3) docs en Context7.

## Integracion Atlassian

- Usar Jira para buscar issues, crear tickets, actualizar estados.
- Usar Confluence para buscar documentacion del equipo, crear/actualizar paginas.
- Configurar cloudId y project key en AGENTS.md del proyecto especifico para reducir tool calls.
- Recordar: Atlassian es opcional. Si no esta configurado, no bloquea.

## SDD Workflow (Spec-Driven Development)

SDD es el workflow estructurado para cambios con ambiguedad sustancial. NO es obligatorio para todo cambio — ver "Implementation Routing" en `02-sdd-orchestrator-runtime.md`.

### Cuando usar SDD vs Direct

| Señal | Ruta |
|---|---|
| Cambio mecanico, patron claro, 1-3 archivos | Direct inline |
| Multiples archivos, sin ambiguedad de diseno | Delegated direct |
| Ambiguedad de diseno, multiples decisiones, scope complejo | SDD (proponer al usuario) |
| Usuario dice "usá SDD" o "/sdd-*" | SDD (solicitud explicita) |

### Artifact Store Policy

| Mode | Behavior |
|---|---|
| `engram` | Default. Persistent memory across sessions. |
| `openspec` | File-based. Solo cuando usuario lo pide explicitamente. |
| `hybrid` | Ambos backends. Mas tokens por operacion. |
| `none` | Inline only. Recomendar habilitar engram. |

### Commands

- `/sdd-init` -> run `sdd-init`
- `/sdd-explore <topic>` -> run `sdd-explore`
- `/sdd-new <change>` -> run `sdd-explore` then `sdd-propose`
- `/sdd-continue [change]` -> create next missing artifact
- `/sdd-ff [change]` -> propose -> spec -> design -> tasks
- `/sdd-apply [change]` -> run `sdd-apply` in batches
- `/sdd-verify [change]` -> run `sdd-verify`
- `/sdd-archive [change]` -> run `sdd-archive`

### Dependency Graph

```
proposal -> specs --> tasks -> apply -> verify -> archive
             ^
             |
           design
```

### Result Contract

Each phase returns: `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`, `skill_resolution`.

### Review Workload Guard

Despues de `sdd-tasks` y ANTES de `sdd-apply`, evaluar el forecast de carga de review:

- Si estimated changed lines > 400: pausar y preguntar al usuario si quiere split en chained PRs o continuar con `size:exception`.
- Delivery strategies disponibles: `ask-on-risk` (default), `auto-chain`, `single-pr`, `exception-ok`.
- Automatico no overridea esta proteccion.

### Delivery Strategy

| Strategy | Comportamiento |
|---|---|
| `ask-on-risk` | Default. Pregunta si tasks forecasts >400 lineas |
| `auto-chain` | Continua con chained PRs sin preguntar |
| `single-pr` | Un PR; requiere `size:exception` si >400 lineas |
| `exception-ok` | PR grande con aprobacion explicita del maintainer |

## Criterio de Calidad

- Configuracion reproducible para teammates nuevos.
- Documentacion corta, verificable y sin ambiguedades.
- Scripts con mensajes claros de error y recuperacion.

## RDD (Receipt-Driven Development)

### Deteccion al inicio de sesion

Verificar si `gentle-ai` CLI y Go estan disponibles:

```bash
go version          # Go runtime
gentle-ai --version # gentle-ai CLI
```

Si ambos estan instalados, verificar estado de RDD:

```bash
gentle-ai review mode status --cwd .
```

### Comportamiento

| Disponibilidad | Accion |
|---|---|
| `gentle-ai` NO instalado | Usar 4R lens skills como guias standalone de calidad |
| Instalado + RDD disabled | Respetar kill switch. No iniciar reviews. |
| Instalado + RDD enabled | Usar lifecycle nativo via CLI |

### Principio core

> Review es informativo. NUNCA bloquea delivery. Approval es evidencia, no autoridad.

### 4R Lens System

Skills de review en `.kiro/skills/review-{lens}/`:

| Lens | Foco |
|---|---|
| `review-risk` (R1) | Seguridad, auth, data exposure, dependencies |
| `review-readability` (R2) | Naming, complejidad, intencion |
| `review-reliability` (R3) | Tests, edge cases, contratos |
| `review-resilience` (R4) | Fallbacks, retry, observabilidad |

Sin CLI: las 4R skills sirven como checklists de calidad durante implementacion.
Con CLI + RDD enabled: las lenses se seleccionan por riesgo (0 para low, 1 para standard, 4 para high).

Contrato completo: `.kiro/skills/_shared/rdd-contract.md`

## Actualizacion del Power

- Mecanismo nativo: Powers panel > Check for updates > Install updates
- Notificacion proactiva (P10): en la primera interaccion del dia, consultar GitHub releases API para detectar nueva version.
- Flujo: GET `https://api.github.com/repos/andersonlugojacome/kiro-powers-mcp-kit/releases/latest` > comparar tag > si nuevo, informar al usuario > guardar en Engram para no repetir ese dia.
- Canales: `main` = stable (default), `canary` = pre-release.
- No repetir alerta mas de una vez por dia.
