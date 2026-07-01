---
inclusion: always
---

# Kiro AGENTS (kiro-powers-mcp-kit)

## Objetivo

Guiar a Kiro para trabajar con alta confiabilidad tecnica, minimo consumo de tokens y seguridad MCP en equipos Windows y macOS.

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

Each phase returns: `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`.

## Criterio de Calidad

- Configuracion reproducible para teammates nuevos.
- Documentacion corta, verificable y sin ambiguedades.
- Scripts con mensajes claros de error y recuperacion.

## Actualizacion del Power

- Metodo oficial: Import Power From Github (`andersonlugojacome/kiro-powers-mcp-kit`)
- En la primera interaccion del dia, informar si hay actualizacion disponible.
- No repetir alerta mas de una vez por dia.
