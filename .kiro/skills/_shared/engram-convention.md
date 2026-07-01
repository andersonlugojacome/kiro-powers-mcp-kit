# Engram Artifact Convention (Engram GO)

> Reference documentation for SDD artifact naming and recovery.
> Backend: Engram GO (Go binary, SQLite + FTS5, 20 MCP tools via stdio).

## Naming Rules

ALL SDD artifacts persisted to Engram MUST follow this deterministic naming:

```
title:     sdd/{change-name}/{artifact-type}
topic_key: sdd/{change-name}/{artifact-type}
type:      architecture
project:   {detected or current project name}
```

### Artifact Types (exact strings)

| Artifact Type | Produced By | Description |
|---|---|---|
| `explore` | sdd-explore | Exploration analysis |
| `proposal` | sdd-propose | Change proposal |
| `spec` | sdd-spec | Delta specifications |
| `design` | sdd-design | Technical design |
| `tasks` | sdd-tasks | Task breakdown |
| `apply-progress` | sdd-apply | Implementation progress |
| `verify-report` | sdd-verify | Verification report |
| `archive-report` | sdd-archive | Archive closure with lineage |
| `state` | orchestrator | DAG state for recovery after compaction |

**Exception**: `sdd-init` uses `sdd-init/{project-name}` as both title and topic_key.

### State Artifact

The orchestrator persists DAG state after each phase transition:

```
mem_save(
  title: "sdd/{change-name}/state",
  topic_key: "sdd/{change-name}/state",
  type: "architecture",
  project: "{project}",
  content: "change: {change-name}\nphase: {last-phase}\n..."
)
```

Recovery: `mem_search("sdd/{change-name}/state")` -> `mem_get_observation(id)` -> parse -> restore.

## Recovery Protocol (2 steps)

```
Step 1: Search
  mem_search(query: "sdd/{change-name}/{artifact-type}", project: "{project}")
  -> Returns truncated preview (300 chars) with observation ID

Step 2: Get full content
  mem_get_observation(id: {observation-id from step 1})
  -> Returns complete untruncated content
```

### Retrieving Multiple Artifacts

Group searches first, then retrievals:

```
STEP A — SEARCH (get IDs only):
  1. mem_search(query: "sdd/{change-name}/proposal", project: "{project}") -> save ID
  2. mem_search(query: "sdd/{change-name}/spec", project: "{project}") -> save ID
  3. mem_search(query: "sdd/{change-name}/design", project: "{project}") -> save ID

STEP B — RETRIEVE FULL CONTENT:
  4. mem_get_observation(id: {proposal_id}) -> full proposal
  5. mem_get_observation(id: {spec_id}) -> full spec
  6. mem_get_observation(id: {design_id}) -> full design
```

### Loading Project Context

```
mem_search(query: "sdd-init/{project}", project: "{project}") -> get ID
mem_get_observation(id) -> full project context
```

## Writing Artifacts

### Standard Write (new or upsert)

```
mem_save(
  title: "sdd/{change-name}/{artifact-type}",
  topic_key: "sdd/{change-name}/{artifact-type}",
  type: "architecture",
  project: "{project}",
  content: "{full markdown content}"
)
```

`topic_key` enables upserts — saving again updates, not duplicates.

### Update Existing (by ID)

```
mem_update(
  id: {observation-id},
  content: "{updated full content}"
)
```

## Engram GO Tools Reference (20 tools)

| Category | Tools |
|---|---|
| Save & Update | `mem_save`, `mem_update`, `mem_delete`, `mem_suggest_topic_key` |
| Search & Retrieve | `mem_search`, `mem_context`, `mem_timeline`, `mem_get_observation` |
| Session Lifecycle | `mem_session_start`, `mem_session_end`, `mem_session_summary` |
| Conflict Surfacing | `mem_judge`, `mem_compare` |
| Lifecycle Review | `mem_review` |
| Utilities | `mem_save_prompt`, `mem_stats`, `mem_capture_passive`, `mem_merge_projects`, `mem_current_project`, `mem_doctor` |

### Key Tools for SDD Workflow

| Tool | When to use |
|---|---|
| `mem_save` | Persist any SDD artifact (upsert via topic_key) |
| `mem_search` | Find artifacts by query (returns previews + IDs) |
| `mem_get_observation` | Get full artifact content by ID |
| `mem_update` | Update existing artifact by ID (e.g., mark tasks done) |
| `mem_context` | Get recent session context for a project |
| `mem_session_start` | Begin SDD session tracking |
| `mem_session_end` | Close session with summary |
| `mem_stats` | Check memory stats (observation count, project list) |

## Why This Convention Exists

- **Deterministic titles** -> recovery works by exact match
- **`topic_key`** -> enables upserts without duplicates
- **`sdd/` prefix** -> namespaces SDD artifacts from other observations
- **Two-step recovery** -> `mem_search` previews are truncated; `mem_get_observation` for full content
