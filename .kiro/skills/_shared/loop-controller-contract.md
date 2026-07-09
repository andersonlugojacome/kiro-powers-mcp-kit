# Execution Loop Controller (ELC) — Interface Contract

**Version:** 1.0.0
**Status:** Active
**Location:** `.kiro/skills/_shared/loop-controller-contract.md`
**Purpose:** Govern the `apply ⇄ verify` sub-loop deterministically — prevent infinite loops, manage state rollback, accumulate constraints, and persist architectural lessons.

---

## 1. Flow Overview

The ELC operates as a module within the Orchestrator Runtime (`02-sdd-orchestrator-runtime.md`). It intercepts `sdd-verify` output after each task execution and decides the next operational state algorithmically.

```
┌──────────────────────────────┐
│   sdd-apply (Task + Context) │◄────────────────────────┐
└──────────────┬───────────────┘                         │
               │                                         │
               ▼                                         │
┌──────────────────────────────┐                         │
│          sdd-verify          │                         │
└──────────────┬───────────────┘                         │
               │                                         │
               ▼ (loop_feedback)                         │
┌──────────────────────────────┐                         │
│   Execution Loop Controller  ├─ [FAIL, Iter < Max] ───┼─ Rollback / Patch
└──────────────┬───────────────┘   + Constraint Accum    │
               │                                         │
       [FAIL, Iter >= Max]  [PASS]                       │
               │              │                          │
               ▼              ▼                          │
      ┌───────────────┐ ┌───────────────┐               │
      │ Escalar Humano│ │  Engram GO    ├───────────────┘
      └───────────────┘ │ (Post-Mortem) │
                        └───────────────┘
```

**Scope**: The ELC loops at the INDIVIDUAL TASK level within a batch. Task 1.1 failing does NOT block or regress Task 1.2.

---

## 2. Data Exchange Schemas

### 2.1. `loop_feedback` — Output from `sdd-verify`

Every `sdd-verify` execution MUST return this object in its return envelope under the key `loop_feedback`:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "LoopFeedback",
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["PASS", "FAIL"]
    },
    "error_criticality": {
      "type": "string",
      "enum": ["NONE", "LOW", "HIGH", "CRITICAL"],
      "description": "NONE=pass, LOW=typo/syntax, HIGH=logic error, CRITICAL=design violation"
    },
    "suggested_action": {
      "type": "string",
      "enum": ["NONE", "PATCH_FORWARD", "ROLLBACK_AND_RETRY"],
      "description": "NONE=pass, PATCH_FORWARD=keep code and fix on top, ROLLBACK_AND_RETRY=discard and restart with new approach"
    },
    "raw_error_summary": {
      "type": "string",
      "maxLength": 200,
      "description": "Compressed single-string summary of compiler/linter/test error"
    },
    "extracted_constraints": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "approach_id": {
            "type": "string",
            "description": "Unique identifier for this attempt (e.g. Approach_01)"
          },
          "failure_cause": {
            "type": "string",
            "description": "Root cause of failure in one sentence"
          },
          "constraint_directive": {
            "type": "string",
            "description": "Explicit negation instruction (e.g. 'Do NOT use abstract classes for this')"
          }
        },
        "required": ["approach_id", "failure_cause", "constraint_directive"]
      }
    },
    "trigger_context_refresh": {
      "type": "boolean",
      "description": "True if error indicates API signature mismatch, deprecated method, or missing attribute — forces Context7 lookup before re-apply"
    }
  },
  "required": ["status", "error_criticality", "suggested_action", "raw_error_summary", "extracted_constraints", "trigger_context_refresh"]
}
```

**Decision matrix for `suggested_action`:**

| Condition | Action |
|-----------|--------|
| Syntax error, missing import, undeclared variable, minor test assertion | `PATCH_FORWARD` |
| Design pattern violation, wrong architectural approach, severe regressions in adjacent files | `ROLLBACK_AND_RETRY` |
| All checks pass | `NONE` |

**Decision matrix for `trigger_context_refresh`:**

| Error pattern | Value |
|---------------|-------|
| `undefined function`, `no attribute`, `deprecated`, `MethodNotFound`, `SignatureMismatch`, `module has no exported member` | `true` |
| All other errors | `false` |

### 2.2. `loop_constraints_input` — Injected into `sdd-apply` on re-execution

When the Orchestrator re-invokes `sdd-apply` on iteration N+1, it injects this block at the TOP of the execution prompt:

```markdown
### [LOOP_CONTROLLER_NOTICE] — RE-EXECUTION ITERATION {N}

The previous attempt failed verification. You MUST adjust your code respecting the following accumulated constraints from prior attempts:

| Attempt | Failure Cause | Mandatory Constraint (What you MUST NOT do) |
|---------|---------------|----------------------------------------------|
| Approach_01 | {raw_error_summary} | {constraint_directive} |
| Approach_02 | {raw_error_summary} | {constraint_directive} |

**Action mode**: {PATCH_FORWARD | ROLLBACK_AND_RETRY}
- If PATCH_FORWARD: The working directory contains your previous code. Fix on top of it.
- If ROLLBACK_AND_RETRY: The working directory has been rolled back to pre-attempt state. Implement a fundamentally different approach.

{IF trigger_context_refresh was true}
**Updated API context** (from Context7):
{refreshed_documentation_snippet}
{/IF}
```

---

## 3. Algorithmic Control Policies

### 3.1. Termination Criteria (Gating)

| Criterion | Default | Max | Notes |
|-----------|---------|-----|-------|
| Max iterations per task | 3 | 5 | Configurable in tasks artifact per-task |
| Budget cap per task | — | — | If token/cost tracking available, halt on exceed |

**On termination by failure**, the ELC generates a structured escalation report:

1. `git diff` of the last attempt's changes
2. Full `loop_constraints_input` table (all accumulated attempts)
3. Last verify's `raw_error_summary` and recommendation
4. Suggested next action for the human

### 3.2. State Modification Policy (Rollback vs. Patch Forward)

**PATCH_FORWARD** (Low-intensity errors):
- Condition: Syntax errors, missing imports, undeclared variables, minor test failures that do NOT violate the original architectural design.
- Action: ELC keeps modified files intact in working directory. Re-invokes `sdd-apply` allowing the model to build a patch on top of existing progress.

**ROLLBACK_AND_RETRY** (Critical/structural errors):
- Condition: Code violates a fundamental design directive (e.g. direct DB calls instead of repository pattern), or causes severe regressions in adjacent files.
- Action: ELC executes `git checkout -- {modified_files}` or `git stash` scoped to the task's file set. Working directory returns to clean state before re-invoking `sdd-apply` with the new accumulated constraint.
- Logging: Every rollback MUST be preceded by a console log with prefix `[ELC_ROLLBACK]` detailing which files were restored and why.

### 3.3. Context7 Conditional Refresh

If `trigger_context_refresh` is `true`:
1. ELC extracts the method/module name from `raw_error_summary`
2. Executes a focused Context7 query on that specific API/method
3. Appends the refreshed documentation to the next `sdd-apply` context
4. This prevents the model from assuming outdated API signatures during correction attempts

This is a FALLBACK mechanism — it does NOT run on every iteration, only when the error pattern indicates documentation staleness.

---

## 4. Post-Mortem Persistence in Engram GO

### When to persist

ONLY when a task requires **2 or more iterations** to reach PASS status AND the resolution involved an **architectural or dependency insight** (not a typo fix).

### What NOT to persist

- Syntax errors ("forgot to close parenthesis on line 45")
- Missing imports that were simply added
- Variable name typos
- Any fix that is purely mechanical with no transferable knowledge

### What TO persist

- Library X version Y requires initializing client Z before auth (contrary to docs)
- Module A's interface changed in v3 — must use new factory pattern
- Component B does not support concurrent writes — must serialize
- Design pattern X does not work with framework constraint Y

### Persistence format

```
mem_save(
  title: "sdd/lessons-learned/{affected-component}",
  topic_key: "sdd/lessons-learned/{affected-component}",
  type: "discovery",
  project: "{project}",
  content: "### LOOP LESSON (Auto-resolved)\n- **Change context:** Implementation of {task_description} in `{module_name}`.\n- **Failure pattern:** Initial approach using {approach_id} failed because {failure_cause}.\n- **Effective solution:** {description_of_what_worked}.\n- **Future directive:** When interacting with this component, AVOID {constraint_directive}."
)
```

### Topic key rationale

Using `sdd/lessons-learned/{affected-component}` (not `sdd/{change-name}/loop-lesson`) ensures lessons are indexed BY COMPONENT, making them discoverable across different changes that touch the same module.

---

## 5. Compliance Matrix (Acceptance Criteria)

Any implementation of this contract in the orchestrator, apply, or verify phases MUST satisfy:

- [ ] `sdd-verify` NEVER returns empty or plain-text when result is FAIL. The `loop_feedback` object MUST be present and well-formed.
- [ ] The Orchestrator isolates the loop at the sub-task level. Failure and retry of Task 1.1 MUST NOT cause regression or alter pre-computed clean inputs for Task 1.2.
- [ ] Every physical rollback command executed by the ELC MUST be preceded by an informational console log with prefix `[ELC_ROLLBACK]` detailing exactly which files were restored and why.
- [ ] Post-mortem persistence ONLY fires for architectural/dependency insights, NEVER for mechanical fixes.
- [ ] `trigger_context_refresh` ONLY activates Context7 when error patterns match API signature/deprecation indicators.
- [ ] Accumulated constraints are compressed (max 200 chars per `raw_error_summary`) — never pass full error logs to the next iteration.
