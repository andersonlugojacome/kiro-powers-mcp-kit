# Powers Roadmap

## Estado actual

| Power | Nombre | Estado | Notas |
|---|---|---|---|
| P1 | Contexto inteligente por proyecto | ✅ Implementado | Via Engram GO `mem_context` + `sdd-init` |
| P2 | Reuso con memoria (Engram-first) | ✅ Implementado | Skills SDD + persistence contract v2 |
| P3 | Documentacion viva (Context7) | ✅ Implementado | Refresh cada 4 queries, steering automatizado |
| P4 | Health check ampliado | ✅ Implementado | `scripts/setup.sh` + `mcp-status-assistant` |
| P5 | Actualizacion guiada | ✅ Implementado | `kiro-update-assistant` via Import Power From Github |
| P6 | Perfil de equipo (Team preset) | 🔲 Pendiente | Presets por tipo de proyecto |
| P7 | Team governance | 🔲 Pendiente | Politicas por equipo |
| P8 | Perfiles por tipo de proyecto | 🔲 Pendiente | Templates frontend/backend/data/mobile |
| P9 | Memoria con trazabilidad | 🔲 Pendiente | Origen visible en reutilizacion |
| P10 | Canales de actualizacion | ✅ Implementado | GitHub releases API + branch canary |
| P11 | Diagnostico corporativo | 🔲 Pendiente | Proxy/certs/npm check previo |
| P12 | Reporte para soporte | 🔲 Pendiente | Salida estandar para mesa de ayuda |

## Detalle por Power implementado

### P1 — Contexto inteligente

- `sdd-init` detecta stack, frameworks, test runner
- `mem_context` recupera contexto reciente del proyecto
- Steering aplica reglas de contexto local first

### P2 — Reuso con memoria

- `mem_search` antes de proponer cambios nuevos
- `topic_key` para evitar duplicados
- Sessions para tracking de ciclos de trabajo

### P3 — Documentacion viva

- Context7 integrado como MCP server
- Refresh automatico cada 4 queries (steering rule)
- Fallback a contexto local si no disponible

### P4 — Health check

- `scripts/setup.sh` verifica: engram, node, npx, mcp.json, skills
- `mcp-status-assistant` skill para check in-chat
- Reporta OK / WARN / BLOCKED con acciones

### P5 — Actualizacion guiada

- `kiro-update-assistant` skill
- Metodo: Powers panel > Check for updates
- Verificacion post-update con setup script

### P10 — Canales de actualizacion

- Notificacion proactiva: en primera interaccion del dia, consulta GitHub releases API
- Compara `tag_name` del ultimo release vs version guardada en Engram
- Si hay update: informa al usuario con accion directa
- No repite alerta mas de una vez por dia (persiste en Engram)
- Canales: `main` = stable, `canary` = pre-release (branch al importar)

## Powers futuros (P6-P12)

Estos Powers requieren diseño adicional y posiblemente infraestructura de equipo. Se implementaran en iteraciones futuras cuando haya demanda clara.

Prioridad sugerida: P6 (team presets) > P8 (project templates) > P9 (trazabilidad) > resto.
