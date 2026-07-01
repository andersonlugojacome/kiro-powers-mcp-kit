# Persistence Contract (shared across all SDD skills)

## Mode Resolution

The orchestrator passes `artifact_store.mode` with one of: `engram | openspec | hybrid | none`.

Default resolution (when orchestrator does not explicitly set a mode):
1. If Engram GO is available -> use `engram`
2. Otherwise -> use `none`

`openspec` and `hybrid` are NEVER used by default — only when explicitly passed.

## Behavior Per Mode

| Mode | Read from | Write to | Project files |
|---|---|---|---|
| `engram` | Engram GO (see `engram-convention.md`) | Engram GO | Never |
| `openspec` | Filesystem (see `openspec-convention.md`) | Filesystem | Yes |
| `hybrid` | Engram (primary) + Filesystem (fallback) | Both | Yes |
| `none` | Orchestrator prompt context | Nowhere | Never |

### Hybrid Mode

Persists to BOTH Engram GO and OpenSpec simultaneously:
- **Read priority**: Engram first. Filesystem fallback if no results.
- **Write**: Both backends. Both MUST succeed.
- **Token cost**: Higher than single backend. Use when you need cross-session persistence AND local files.

## State Persistence (Orchestrator)

| Mode | Persist State | Recover State |
|---|---|---|
| `engram` | `mem_save(topic_key: "sdd/{change-name}/state")` | `mem_search` -> `mem_get_observation` |
| `openspec` | Write `openspec/changes/{change-name}/state.yaml` | Read file |
| `hybrid` | Both | Engram first; filesystem fallback |
| `none` | Not possible | Not possible — warn user |

## Common Rules

- `none` mode: do NOT create/modify project files. Return inline only.
- `engram` mode: do NOT write project files. Persist to Engram only.
- `openspec` mode: write ONLY to paths in `openspec-convention.md`.
- `hybrid` mode: persist to BOTH. Follow both conventions.
- NEVER force `openspec/` creation unless mode is `openspec` or `hybrid`.

## Sub-Agent Context Rules

Sub-agents launch with fresh context. The orchestrator controls what they receive.

### Who reads, who writes

| Context | Who reads | Who writes |
|---|---|---|
| Non-SDD (general task) | Orchestrator searches, passes summary | Sub-agent saves via `mem_save` |
| SDD (phase with deps) | Sub-agent reads directly | Sub-agent saves artifact |
| SDD (phase without deps) | Nobody | Sub-agent saves artifact |

### Orchestrator prompt for sub-agents

**Non-SDD:**
```
PERSISTENCE (MANDATORY):
If you make important discoveries/decisions/fixes, save them:
  mem_save(title: "{description}", type: "{decision|bugfix|discovery}",
           project: "{project}", content: "{What, Why, Where, Learned}")
```

**SDD (with dependencies):**
```
Artifact store mode: {engram|openspec|hybrid|none}
Read artifacts (two-step):
  mem_search(query: "sdd/{change-name}/{type}", project: "{project}") -> get ID
  mem_get_observation(id) -> full content (REQUIRED)

PERSISTENCE (MANDATORY):
  mem_save(
    title: "sdd/{change-name}/{artifact-type}",
    topic_key: "sdd/{change-name}/{artifact-type}",
    type: "architecture",
    project: "{project}",
    content: "{your full artifact}"
  )
```

## Engram GO vs server-memory Migration

| Old (server-memory) | New (Engram GO) | Notes |
|---|---|---|
| `create_entities` | `mem_save` | title + content |
| `add_observations` | `mem_update` | By observation ID |
| `read_graph` | `mem_context` / `mem_stats` | Project context or stats |
| `search_nodes` | `mem_search` | FTS5 query, returns previews |
| `open_nodes` | `mem_get_observation` | Full content by ID |
| `delete_entities` | `mem_delete` | Soft delete default |
| `create_relations` | N/A | Implicit via topic_key |
