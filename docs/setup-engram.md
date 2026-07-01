# Setup: Engram GO

Engram GO es la memoria persistente del kit. Un Go binary con SQLite + FTS5 que expone 20 MCP tools via stdio.

## Instalacion

### macOS (Homebrew)

```bash
brew install gentleman-programming/tap/engram
```

### Windows

Descargar el binary desde [releases](https://github.com/Gentleman-Programming/engram/releases) y agregar al PATH.

### Linux

```bash
brew install gentleman-programming/tap/engram
# o descargar binary de releases
```

## Setup para Kiro

```bash
engram setup kiro
```

Esto escribe la configuracion MCP automaticamente en `~/.kiro/settings/mcp.json`.

## Verificacion

```bash
engram --version
engram doctor
engram stats
```

## Configuracion MCP manual (si no usas `engram setup`)

```json
{
  "mcpServers": {
    "engram": {
      "command": "engram",
      "args": ["mcp"]
    }
  }
}
```

## Tools disponibles (20)

| Categoria | Tools |
|---|---|
| Save & Update | `mem_save`, `mem_update`, `mem_delete`, `mem_suggest_topic_key` |
| Search & Retrieve | `mem_search`, `mem_context`, `mem_timeline`, `mem_get_observation` |
| Session Lifecycle | `mem_session_start`, `mem_session_end`, `mem_session_summary` |
| Conflict Surfacing | `mem_judge`, `mem_compare` |
| Lifecycle Review | `mem_review` |
| Utilities | `mem_save_prompt`, `mem_stats`, `mem_capture_passive`, `mem_merge_projects`, `mem_current_project`, `mem_doctor` |

## Uso basico

```
# Guardar una observacion
mem_save(title: "mi decision", type: "decision", project: "mi-proyecto", content: "...")

# Buscar
mem_search(query: "decision sobre X", project: "mi-proyecto")

# Leer completo (el search retorna previews truncados)
mem_get_observation(id: "obs-id-from-search")
```

## Troubleshooting

| Problema | Solucion |
|---|---|
| `engram: command not found` | Reinstalar con brew o agregar binary al PATH |
| DB corrupta | `engram doctor` para diagnostico |
| Memorias de otro proyecto | Verificar `--project` flag o `mem_current_project` |

## Mas info

- [Documentacion completa](https://github.com/Gentleman-Programming/engram/blob/main/DOCS.md)
- [Agent Setup](https://github.com/Gentleman-Programming/engram/blob/main/docs/AGENT-SETUP.md)
- [Arquitectura](https://github.com/Gentleman-Programming/engram/blob/main/docs/ARCHITECTURE.md)
