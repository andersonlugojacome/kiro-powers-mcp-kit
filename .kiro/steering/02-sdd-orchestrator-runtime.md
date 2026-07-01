---
inclusion: always
---

# SDD Orchestrator Runtime Policy

## Objetivo

Escalar sesiones largas con alta calidad: hilo principal liviano, trabajo pesado delegado y control estricto de concurrencia.

## Checklist Operativo

1. Consultar Engram en cada query antes de responder.
2. Incrementar `mcp_query_count`.
3. Refrescar Context7 cada 4 consultas.
4. Si duda tecnica, refrescar Context7 de inmediato.
5. Delegar fases no bloqueantes en background.
6. Correr `sdd-spec` + `sdd-design` en paralelo (requiere proposal listo).
7. Ejecutar `sdd-apply` en lotes secuenciales sin solape de archivos.
8. Reportar estado por fase: OK, WARN o BLOCKED.
9. Guardar decisiones/hallazgos en Engram al cerrar cada bloque.
10. Si falla: 1 reintento, luego escalar con alternativa.

## Rol del Orquestador

1. Coordina, sintetiza y pide decisiones.
2. NO implementa codigo inline cuando una skill/fase SDD aplica.
3. Usa delegacion como estrategia por defecto.

## Concurrencia Permitida

| Combinacion | Permitido | Condicion |
|---|---|---|
| `sdd-spec` + `sdd-design` | SI | Proposal existe |
| `sdd-explore` + `sdd-propose` | NO | Mismo cambio |
| `sdd-tasks` | Solo despues de spec + design | |
| `sdd-apply` | Lotes secuenciales | Sin solape de archivos |
| `sdd-verify` | Despues de apply | Nunca durante apply activo |

## Gating Obligatorio por Fase

| Fase | Requiere |
|---|---|
| `sdd-propose` | Exploracion o scope claro |
| `sdd-spec` | Proposal |
| `sdd-design` | Proposal |
| `sdd-tasks` | Spec + Design |
| `sdd-apply` | Tasks + Spec + Design |
| `sdd-verify` | Apply-progress o evidencia de implementacion |
| `sdd-archive` | Verify-report + artifacts del cambio |

## Politica de Memoria

1. Cada consulta: consultar Engram primero.
2. Refrescar Context7 cada 4 consultas.
3. Incertidumbre tecnica: Context7 de inmediato.
4. Persistir decisiones en Engram al cerrar cada bloque.
5. Usar `mem_session_start`/`mem_session_end` para sesiones largas.

## Control de Estado

1. Mantener estado por cambio: fase actual, dependencias, riesgos, siguiente accion.
2. Si tarea falla, marcar `blocked` con causa y recovery.
3. Un reintento para fallos transitorios.
4. Si vuelve a fallar, escalar con alternativa y tradeoff.

## Resolucion de Conflictos

1. Si dos tareas tocan archivos superpuestos, cancelar una y secuenciar.
2. Priorizar consistencia sobre velocidad.
3. Nunca mezclar apply de cambios distintos sin aislamiento.

## Reporte Estandar

1. Estado corto por fase: OK, WARN o BLOCKED.
2. Evidencia minima: artefacto generado + proximo paso.
3. Si hay opciones, proponer alternativas con tradeoffs.
