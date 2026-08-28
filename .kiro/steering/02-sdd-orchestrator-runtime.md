---
inclusion: always
---

# SDD Orchestrator Runtime Policy

## Objetivo

Escalar sesiones largas con alta calidad: hilo principal liviano, trabajo pesado delegado y control estricto de concurrencia. Elegir la ruta de implementacion mas liviana que resuelva el problema sin ceremonia innecesaria.

## Implementation Routing (Routing Organico)

Cada cambio toma EXACTAMENTE UNA ruta de implementacion. SDD es una opcion valiosa, no un default obligatorio.

### Tres rutas disponibles

| Ruta | Cuando aplica | Que hace |
|---|---|---|
| **Direct inline** | 1–3 archivos, cambio mecanico ya entendido, sin ambiguedad de diseno | Editar directamente sin crear artefactos SDD |
| **Delegated direct** | 4+ archivos para entender, 2+ archivos no-triviales para escribir, research amplio | Delegar a un worker acotado, sin artefactos SDD |
| **Optional SDD** | Ambiguedad sustancial donde proposal/spec/design/tasks reducen riesgo materialmente | Proponer SDD, ejecutar SOLO tras aceptacion del usuario |

### Regla de oro

- File count, lineas cambiadas, tamaño o riesgo percibido NUNCA fuerzan SDD por si solos.
- SDD se selecciona SOLO por solicitud explicita del usuario O propuesta aceptada.
- Direct y delegated NUNCA crean artefactos SDD, prompts de fase, ni runs sinteticos.

### Ejemplos de routing

| Pedido del usuario | Ruta |
|---|---|
| "Corregí el typo en utils.ts" | Direct inline |
| "Renombrá getUserName a getUsername en todo el repo" | Delegated direct (grep revela 15 ocurrencias en 8 archivos) |
| "Agregá paginación al endpoint /users" | Direct inline o delegated direct (2-3 archivos, patron claro) |
| "Implementá autenticación con JWT, refresh tokens, y roles" | Optional SDD (ambiguedad en diseño, multiples decisiones) |
| "Usá SDD para agregar dark mode" | Optional SDD (solicitud explicita) |

## Delegation Stop Rules

Reglas que determinan CUANDO delegar en vez de hacer inline.

| Regla | Trigger | Accion |
|---|---|---|
| **Bounded read** | 1–3 archivos para decidir/verificar | Leer inline |
| **4-file rule** | Entender requiere 4+ archivos | Delegar un task de exploracion acotado |
| **Write rule** | 2+ archivos no-triviales para escribir | Delegar un writer |
| **Context rule** | Lectura que prepara un write, o research amplio | Delegar junto con el write |
| **Per-action rule** | Tests, builds, installs | Worker fresco por accion, sin cambiar ruta |
| **Optional SDD rule** | Ambiguedad sustancial donde proposal/spec/design reducen riesgo | Proponer SDD al usuario |

### Principio core

> ¿Esto infla el contexto padre sin necesidad? SI → delegar un worker acotado. NO → hacerlo inline.

## Checklist Operativo

1. Consultar Engram en cada query antes de responder.
2. Incrementar `mcp_query_count`.
3. Refrescar Context7 cada 4 consultas.
4. Si duda tecnica, refrescar Context7 de inmediato.
5. Evaluar ruta de implementacion (direct / delegated / SDD) antes de actuar.
6. Delegar fases no bloqueantes en background.
7. Correr `sdd-spec` + `sdd-design` en paralelo (requiere proposal listo).
8. Ejecutar `sdd-apply` en lotes secuenciales sin solape de archivos.
9. Reportar estado por fase: OK, WARN o BLOCKED.
10. Guardar decisiones/hallazgos en Engram al cerrar cada bloque.
11. Si falla: 1 reintento, luego escalar con alternativa.

## Rol del Orquestador

1. Coordina, sintetiza y pide decisiones.
2. Evalua ruta de implementacion ANTES de actuar — no toda tarea necesita SDD.
3. Para direct inline: resuelve directo sin ceremonia.
4. Para delegated direct: lanza worker(s) acotados sin artefactos SDD.
5. Para optional SDD: propone, espera aceptacion, LUEGO ejecuta fases.
6. Usa delegacion como estrategia para escalar, no como ceremonia obligatoria.

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

## Execution Loop Controller (ELC)

El ELC gobierna el sub-bucle `apply ⇄ verify` de forma determinista a nivel de sub-tarea individual. Contrato completo: `.kiro/skills/_shared/loop-controller-contract.md`.

### Flujo operativo

```
orchestrator recibe tasks → lanza apply(batch)
  ├── apply ejecuta task N
  │   └── orchestrator lanza verify(task N)
  │       ├── loop_feedback.status == PASS → siguiente task
  │       └── loop_feedback.status == FAIL →
  │           ├── iteration < max_iterations?
  │           │   ├── SI → aplicar rollback policy + accumulate constraint + re-apply
  │           │   └── NO → escalar al humano con contexto estructurado
  │           └── [post-mortem si resuelto después de >1 iteración]
  └── batch completo → verify(full batch) → archive
```

### Politicas clave

1. **Max iterations**: 3 por defecto, configurable hasta 5 por tarea.
2. **Rollback policy**: Basada en `loop_feedback.suggested_action`:
   - `PATCH_FORWARD`: Mantener archivos, fix encima del progreso existente.
   - `ROLLBACK_AND_RETRY`: `git checkout -- {files}` antes de re-apply con approach diferente.
3. **Constraint accumulation**: Cada fallo se comprime a max 200 chars. Se inyecta como `[LOOP_CONTROLLER_NOTICE]` al inicio del prompt de re-apply.
4. **Context7 conditional refresh**: Si `loop_feedback.trigger_context_refresh == true`, consultar Context7 con el metodo/modulo especifico antes del re-apply.
5. **Post-mortem to Engram**: Solo si iteraciones > 1 Y la resolucion fue arquitectonica/dependencia (no typos). Topic key: `sdd/lessons-learned/{componente}`.
6. **Aislamiento**: El fallo de Task 1.1 NO afecta inputs pre-computados de Task 1.2.

### Escalamiento al humano

Cuando se agotan iteraciones sin PASS, el ELC genera:
1. `git diff` del ultimo intento
2. Tabla de restricciones acumuladas
3. Ultimo `raw_error_summary` del verify
4. Recomendacion de siguiente accion

### Logging obligatorio

Todo rollback fisico se loguea con prefijo `[ELC_ROLLBACK]` indicando archivos restaurados y motivo.
