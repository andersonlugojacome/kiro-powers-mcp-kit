# Engram Artifact Convention (Engram GO)

> Reference documentation for SDD artifact naming, recovery, and save protocol.
> Backend: Engram GO (Go binary, SQLite + FTS5, 20+ MCP tools via stdio).
> Minimum version: v1.15.3+

NOTE: Critical engram calls (`mem_search`, `mem_save`, `mem_get_observation`) are inlined directly in each skill's SKILL.md. This document is supplementary reference — sub-agents do NOT need to read it to function.

## Prompt Capture Protocol (v1.15.3+)

### `capture_prompt` parameter

`mem_save` accepts an optional `capture_prompt` parameter (default: `true`):

- **`true` (default)**: Engram attempts to associate the user's prompt context with the observation. Used for human-driven decisions, discoveries, bug fixes, preferences.
- **`false`**: Skip prompt capture. Used for **automated artifacts** that are not direct responses to a user prompt.

Set `capture_prompt: false` when the Engram tool schema supports it; if an older schema rejects or does not expose the field, omit it rather than failing.

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
scope:     project
capture_prompt: false
```

### Artifact Types (exact strings)

| Artifact Type | Produced By | Description |
|---|---|---|
| `explore` | sdd-explore | Exploration analysis |
| `proposal` | sdd-propose | Change proposal |
| `spec` | sdd-spec | Delta specifications (all domains concatenated) |
| `design` | sdd-design | Technical design |
| `tasks` | sdd-tasks | Task breakdown |
| `apply-progress` | sdd-apply | Implementation progress (one per batch) |
| `verify-report` | sdd-verify | Verification report |
| `archive-report` | sdd-archive | Archive closure with lineage |
| `state` | orchestrator | Optional recovery hint; actual artifacts remain authoritative |

**Exception**: `sdd-init` uses `sdd-init/{project-name}` as both title and topic_key.

### Research artifacts

Use `sdd/{change-name}/research` for optional source-backed notes when persistence is requested. Preserve historical research and preproposal observations. Their schema, revision or agreement with files is not proposal admission authority.

### Optional State Hint

An existing `sdd/{change-name}/state` observation is an optional recovery hint, not a required YAML snapshot or a second authority. Recover using native status and its resolved artifact locators; retrieve full observations with `mem_get_observation`. Preserve historical snapshots, but verify their claims against actual artifacts. A state-only observation does not establish active work; the actual `archive-report` remains the closure marker.

```
mem_save(
  title: "sdd/{change-name}/state",
  topic_key: "sdd/{change-name}/state",
  type: "architecture",
  project: "{project}",
  content: "change: {change-name}\nphase: {last-phase}\n..."
)
```

## Recovery Protocol (2 steps)

Memory lifecycle rule (when Engram exposes lifecycle metadata/tooling):
- At session start or before architecture-sensitive work, call `mem_review` with action `list` for the current project when the tool is available.
- If `mem_review` is unavailable, do not fail the task. Continue with normal `mem_context`/`mem_search`, and still apply lifecycle metadata from any returned observations when present.
- `active` memories may be used normally.
- `needs_review` memories are stale context, not trusted facts.
- Surface `needs_review` context and verify it against current evidence before relying on it.
- Do NOT call `mem_review` with action `mark_reviewed` automatically. Only call `mark_reviewed` after explicit user confirmation or through a dedicated memory maintenance command.

```
Step 1: mem_search(query: "sdd/{change-name}/{artifact-type}", project: "{project}") → truncated preview + ID
Step 2: mem_get_observation(id: {observation-id}) → complete content
```

### Retrieving Multiple Artifacts

Group searches first, then retrievals:

```
STEP A — SEARCH (get IDs only):
  mem_search(query: "sdd/{change-name}/proposal", ...) → save ID
  mem_search(query: "sdd/{change-name}/spec", ...) → save ID
  mem_search(query: "sdd/{change-name}/design", ...) → save ID

STEP B — RETRIEVE FULL CONTENT (mandatory):
  mem_get_observation(id: {proposal_id})
  mem_get_observation(id: {spec_id})
  mem_get_observation(id: {design_id})
```

### Loading Project Context

```
mem_search(query: "sdd-init/{project}", project: "{project}") → get ID
mem_get_observation(id) → full project context
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
`capture_prompt: false` because SDD artifacts are automated, not direct user responses. Do not infer this from `type` because both SDD artifacts and human architecture decisions use `architecture`. If an older schema rejects or does not expose `capture_prompt`, omit it rather than failing.

Concrete example — saving a proposal for `add-dark-mode`:
```
mem_save(
  title: "sdd/add-dark-mode/proposal",
  topic_key: "sdd/add-dark-mode/proposal",
  type: "architecture",
  project: "my-app",
  capture_prompt: false,
  content: "## Proposal\n\nAdd dark mode toggle..."
)
```

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

Use `mem_update` when you have the exact ID. Use `mem_save` with same `topic_key` for upserts.

### Browsing All Artifacts for a Change

```
mem_search(query: "sdd/{change-name}/", project: "{project}")
→ Returns all artifacts for that change
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

## Project Name Resolution (engram v1.11.0+)

Engram auto-detects the project name from the git remote at MCP startup. The `--project` flag and `ENGRAM_PROJECT` env var can override detection. All project names are normalized to lowercase and trimmed.

If the agent saves a memory under a project name that doesn't match existing observations, engram warns about potential name drift. Use `mem_merge_projects` (MCP tool) or `engram projects consolidate` (CLI) to merge variants.

## Upsert Behavior

Same `topic_key` + `project` + `scope` → UPDATE (overwrite), not INSERT. Previous content is lost — `revision_count` increments but old content is NOT saved. This is by design — engram is working memory, not an audit trail. For iteration history or team collaboration, use `openspec` or `hybrid` mode.

## Why This Convention Exists

- **Deterministic titles** → recovery works by exact match
- **`topic_key`** → enables upserts without duplicates
- **`sdd/` prefix** → namespaces SDD artifacts from other observations
- **Two-step recovery** → `mem_search` previews are truncated; `mem_get_observation` for full content
- **Lineage** → archive-report includes all observation IDs for complete traceability
