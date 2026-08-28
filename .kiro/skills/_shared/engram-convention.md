# Engram Artifact Convention (Engram GO)

> Reference documentation for SDD artifact naming, recovery, and save protocol.
> Backend: Engram GO (Go binary, SQLite + FTS5, 20+ MCP tools via stdio).
> Minimum version: v1.15.3+

## Prompt Capture Protocol (v1.15.3+)

### `capture_prompt` parameter

`mem_save` accepts an optional `capture_prompt` parameter (default: `true`):

- **`true` (default)**: Engram attempts to associate the user's prompt context with the observation. Used for human-driven decisions, discoveries, bug fixes, preferences.
- **`false`**: Skip prompt capture. Used for **automated artifacts** that are not direct responses to a user prompt.

### When to use `capture_prompt: false`

| Artifact type | Example | capture_prompt |
|---|---|---|
| SDD phase output | proposal, spec, design, tasks, apply-progress | `false` |
| sdd-init context | Project detection result | `false` |
| Skill registry output | Cached skill index | `false` |
| Verify/archive reports | Automated verification result | `false` |
| Lessons learned (ELC post-mortem) | Auto-extracted from loop | `false` |

### When to use `capture_prompt: true` (default)

| Artifact type | Example | capture_prompt |
|---|---|---|
| Human decisions | Architecture choice, tradeoff accepted | `true` (default) |
| Bug fixes | Root cause + fix with user context | `true` (default) |
| Discoveries | Non-obvious behavior found during work | `true` (default) |
| User preferences | Convention or workflow preference | `true` (default) |

### `mem_save_prompt` tool

Records the user's prompt for session activity and deduplication:

```
mem_save_prompt(content: "user prompt text", project: "{project}")
```

- Call BEFORE derived `mem_save` calls when prompt context is needed.
- Engram deduplicates — safe to call multiple times with same content.
- Feeds SessionActivity so later `mem_save` calls can capture it.
- If prompt context already exists for the session, `mem_save` captures it automatically.

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
  capture_prompt: false,
  content: "{full markdown content}"
)
```

`topic_key` enables upserts — saving again updates, not duplicates.
`capture_prompt: false` because SDD artifacts are automated, not direct user responses.

### Human Decisions (proactive saves)

```
mem_save(
  title: "{Verb + what}",
  topic_key: "{stable-key}",
  type: "decision",
  project: "{project}",
  content: "**What**: ...\n**Why**: ...\n**Where**: ...\n**Learned**: ..."
)
```

No `capture_prompt` needed — defaults to `true` for human-driven observations.

### Update Existing (by ID)

```
mem_update(
  id: {observation-id},
  content: "{updated full content}"
)
```

## Engram GO Tools Reference (20+ tools)

| Category | Tools |
|---|---|
| Save & Update | `mem_save`, `mem_update`, `mem_delete`, `mem_suggest_topic_key` |
| Search & Retrieve | `mem_search`, `mem_context`, `mem_timeline`, `mem_get_observation` |
| Session Lifecycle | `mem_session_start`, `mem_session_end`, `mem_session_summary` |
| Prompt Capture | `mem_save_prompt`, `mem_capture_passive` |
| Conflict Surfacing | `mem_judge`, `mem_compare` |
| Lifecycle Review | `mem_review` |
| Utilities | `mem_stats`, `mem_merge_projects`, `mem_current_project`, `mem_doctor` |

### Key Tools for SDD Workflow

| Tool | When to use |
|---|---|
| `mem_save` | Persist any SDD artifact (upsert via topic_key). Use `capture_prompt: false` for automated artifacts. |
| `mem_save_prompt` | Record user prompt before derived saves (feeds SessionActivity for auto-capture) |
| `mem_search` | Find artifacts by query (returns previews + IDs) |
| `mem_get_observation` | Get full artifact content by ID |
| `mem_update` | Update existing artifact by ID (e.g., mark tasks done) |
| `mem_context` | Get recent session context for a project |
| `mem_session_start` | Begin SDD session tracking |
| `mem_session_end` | Close session with summary |
| `mem_session_summary` | Comprehensive session close (MANDATORY before ending) |
| `mem_stats` | Check memory stats (observation count, project list) |
| `mem_merge_projects` | Fix project name drift (merge name variants) |
| `mem_doctor` | Health check for Engram DB |

## Why This Convention Exists

- **Deterministic titles** -> recovery works by exact match
- **`topic_key`** -> enables upserts without duplicates
- **`sdd/` prefix** -> namespaces SDD artifacts from other observations
- **Two-step recovery** -> `mem_search` previews are truncated; `mem_get_observation` for full content
