---
name: judgment-day
description: "Trigger: judgment day, dual review, adversarial review, juzgar. Run explicit blind dual review with at most two scoped fix/re-judgment rounds."
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- User says "judgment day", "dual review", "adversarial review", or "juzgar"
- A high-risk change needs independent verification before delivery
- The team wants confidence beyond single-reviewer approval

## Critical Rules

| Rule | Requirement |
|------|-------------|
| Two blind judges | Run in parallel on identical frozen scope |
| Read-only judges | Judges NEVER modify code — only the fix actor does |
| Orchestrator merges | Only the parent orchestrator merges findings and launches fixes |
| Both must agree | Fix only severe findings confirmed by BOTH judges |
| Max 2 rounds | At most 2 fix rounds + 2 scoped re-judgments |
| Terminal verdicts | Only `APPROVED` or `ESCALATED` — nothing in between |
| No delivery authority | Judgment carries no commit/push/PR gate — it's informational |

## Execution Flow

```
1. FREEZE target (snapshot the exact files/diff to review)
2. LAUNCH 2 parallel judges on identical frozen scope
3. MERGE findings into frozen ledger
4. EVALUATE:
   - Both agree on severe issue → ask user before fix
   - One judge only → record as suspect, no auto-fix
   - Judges contradict → escalate to human
5. If fix approved:
   - LAUNCH bounded fix actor (scoped to confirmed findings)
   - RE-JUDGE over ledger + delta (one more round max)
6. FINAL VERDICT:
   - All severe fixed → APPROVED
   - Issues remain after round 2 → ESCALATED (stop)
```

## Severity Classification

| Severity | Both judges agree | One judge only |
|----------|-------------------|----------------|
| **BLOCKER** | Must fix before delivery | Suspect — surface to human |
| **CRITICAL** | Should fix, high priority | Record, do not auto-fix |
| **WARNING** | Informational, no fix required | Note in report |
| **SUGGESTION** | Optional improvement | Ignore |

## Judge Output Format

Each judge returns:

```json
{
  "findings": [
    {
      "severity": "BLOCKER|CRITICAL|WARNING|SUGGESTION",
      "file": "path/to/file.ts",
      "line": 42,
      "description": "What's wrong",
      "evidence": "Why this is a problem",
      "suggested_fix": "How to resolve (optional)"
    }
  ],
  "overall": "PASS|FAIL",
  "confidence": "HIGH|MEDIUM|LOW"
}
```

## Fix Actor Rules

1. Fix ONLY confirmed findings (both judges agree, severity BLOCKER or CRITICAL).
2. Scope fix to the minimum change that resolves the finding.
3. Do not refactor, improve, or touch unrelated code.
4. Report what was fixed and what was not fixable.

## Escalation Triggers

- Judges contradict each other on severity of same finding
- One judge finds BLOCKER, the other doesn't mention it at all
- Fix actor cannot resolve within scope
- Round 2 still has unresolved BLOCKER findings
- Judgment scope is ambiguous or too broad

## Skill Dependencies

This skill works with sub-agents for judges and fix:
- Judge A and Judge B run in parallel with identical frozen context
- Fix actor runs sequentially after merge + user approval
- All share the frozen ledger but cannot modify each other's output

## Commands

```bash
# Freeze the target for review
git diff --stat main...HEAD

# Check what would be reviewed
git diff main...HEAD --name-only
```
