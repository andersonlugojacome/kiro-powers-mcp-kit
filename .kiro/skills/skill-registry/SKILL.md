---
name: skill-registry
description: "Trigger: update skills, skill registry, actualizar skills, after skill changes. Index available skills by trigger and path."
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- Skills have been added, removed, or modified
- User asks to update or refresh the skill registry
- Starting a new session that needs skill awareness
- The orchestrator needs to resolve which skills to pass to sub-agents

## Purpose

The skill registry is a cached index of all available skills — both project-level (`.kiro/skills/`) and user-level. It enables:

1. **Fast skill resolution**: The orchestrator matches skills by file context and task context without reading every SKILL.md.
2. **Sub-agent injection**: Resolved skill paths are passed to sub-agents so they load instructions BEFORE doing work.
3. **Cache invalidation**: A fingerprint hash detects when skills change and the registry needs refresh.

## Registry Location

| File | Purpose |
|---|---|
| `.atl/skill-registry.md` | Human-readable index (skill name, trigger, scope, path) |
| `.atl/.skill-registry.cache.json` | Fingerprint hash for cache invalidation |

Both are gitignored (`.atl/` is local). The registry is rebuilt on demand.

## Execution Steps

### Build / Refresh Registry

```
1. SCAN `.kiro/skills/` for all SKILL.md files
2. PARSE each SKILL.md frontmatter (name, description, metadata)
3. EXTRACT trigger conditions from description field
4. SCAN user-level skill dirs if accessible
5. BUILD registry index with: name, trigger/description, scope (project|user), exact path
6. COMPUTE fingerprint hash from all SKILL.md mtimes + paths
7. WRITE `.atl/skill-registry.md` (readable index)
8. WRITE `.atl/.skill-registry.cache.json` (fingerprint for invalidation)
9. PERSIST to Engram: mem_save(title: "skill-registry", topic_key: "skill-registry/{project}", type: "config", project: "{project}", capture_prompt: false, content: "{registry content}")
```

### Resolve Skills (for sub-agent injection)

```
1. CHECK cache: is `.atl/.skill-registry.cache.json` still valid?
   - If stale → rebuild first
   - If valid → use cached registry
2. MATCH skills by:
   - File context: extensions/paths the sub-agent will touch
   - Task context: what the sub-agent is being asked to do
3. RETURN matching SKILL.md absolute paths for injection
```

## Registry Format

```markdown
# Skill Registry — {project}

Last updated: {ISO date}
Skills indexed: {count}

## Project Skills (.kiro/skills/)

| Skill | Trigger | Path |
|-------|---------|------|
| sdd-init | sdd init, initialize project | .kiro/skills/sdd-init/SKILL.md |
| branch-pr | creating PRs, preparing branches | .kiro/skills/branch-pr/SKILL.md |
| ... | ... | ... |

## User Skills (~/.config/opencode/skills/ or ~/.kiro/skills/)

| Skill | Trigger | Path |
|-------|---------|------|
| ... | ... | ... |
```

## Skill Resolution Rules

| Context | Matching strategy |
|---|---|
| Writing code | Match by file extensions in target paths |
| Creating PRs | `branch-pr`, `chained-pr` (if >400 lines) |
| Writing commits | `work-unit-commits` |
| Writing docs | `cognitive-doc-design` |
| Creating issues | `issue-creation` |
| Reviewing code | `judgment-day` (if adversarial), `comment-writer` (for feedback) |
| SDD phases | Direct invoke by phase name (not via registry) |

## Cache Invalidation

The fingerprint hash changes when:
- A SKILL.md is added, removed, or modified
- The `.kiro/skills/` directory structure changes
- User explicitly requests refresh (`/skill-registry` or "actualizar skills")

## Critical Rules

- SDD phase skills (sdd-init through sdd-archive) are NOT in the registry — they are invoked directly by the orchestrator by phase name.
- The registry is a delegator-only artifact — sub-agents receive resolved paths, never the registry itself.
- Registry rebuild is idempotent — safe to run multiple times.
- Always persist to Engram with `capture_prompt: false` (automated artifact).
