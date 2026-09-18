# RDD Contract — Receipt-Driven Development (Reference)

> Reference documentation for RDD awareness in Kiro Powers MCP Kit.
> RDD is provided by the `gentle-ai` CLI. This document enables the agent to understand
> and participate in RDD when the CLI is available, or work without it when it's not.

## What is RDD

Receipt-Driven Development is an **opt-in, informational** review system:

- Review outcomes are **evidence about the completed transaction**, not delivery authority.
- Approval never commits, pushes, opens a PR, or overrides repository policy.
- Delivery remains human-owned under ordinary repository policy.
- Review is informational — it never blocks delivery.

## CLI Detection

At session start or before first review-aware action, detect `gentle-ai` availability:

```bash
# Check if gentle-ai is installed
gentle-ai --version

# Check RDD mode status
gentle-ai review mode status --cwd .
```

### Behavior by availability

| `gentle-ai` installed | RDD enabled | Behavior |
|---|---|---|
| No | N/A | Use 4R lens skills as standalone review guides. No native RDD lifecycle. |
| Yes | No (disabled) | Respect the kill switch. Do not start reviews. Implement organically. |
| Yes | Yes (enabled) | Full native RDD lifecycle via CLI commands. |

## Kill Switch

The user controls RDD:

```bash
gentle-ai review mode enable --scope global    # turns on
gentle-ai review mode disable --cwd .          # turns off for this repo
gentle-ai review mode status --cwd .           # read-only check
```

- **Off by default.** Until explicitly enabled, review does not govern.
- When disabled: keep implementing organically, do not start reviews, do not retry, do not reactivate.
- Never enable RDD on the user's behalf unless explicitly asked.

## Risk Tiers and Lens Selection

Risk is frozen at START based on what the candidate touches:

| Risk tier | Lenses | Behavior |
|---|---|---|
| **Low** | 0 lenses | Structural readback only, silent, no consent needed |
| **Standard** | 1 focus lens + consent | Single lens chosen by risk assessment |
| **High** | Canonical 4R (all 4) + consent + forecast | Full: Risk, Readability, Reliability, Resilience |

### What triggers High risk:
- Auth/payments/security paths touched
- Change size > 400 lines
- Infrastructure or deployment config changes
- Database schema changes

## 4R Lens System

| Lens | ID | Focus |
|---|---|---|
| **Risk** | R1 | Security, privilege boundaries, data exposure, dependencies |
| **Readability** | R2 | Naming, complexity, intention, maintainability |
| **Reliability** | R3 | Tests, coverage value, edge cases, determinism, contracts |
| **Resilience** | R4 | Fallbacks, retry/backoff, degradation, observability, rollback |

Each lens is a read-only reviewer skill in `.kiro/skills/review-{lens}/SKILL.md`.

## Severity Levels (shared across all lenses)

| Severity | Meaning |
|---|---|
| **BLOCKER** | Must fix — exploitable, outage risk, misleading, or zero test coverage on critical path |
| **CRITICAL** | High priority — requires specific conditions but significant impact |
| **WARNING** | Informational — reported once, never blocks, never re-reviewed |
| **SUGGESTION** | Optional improvement — reported once, status `info` |

Only BLOCKER/CRITICAL survive into the fix loop. WARNING/SUGGESTION are reported once with status `info`.

## Findings Ledger Schema

```json
{
  "id": "{LENS}-{NNN}",
  "lens": "risk | readability | reliability | resilience",
  "location": "path/to/file.ext:line",
  "severity": "BLOCKER | CRITICAL | WARNING | SUGGESTION",
  "status": "open | fixed | verified | refuted | wont-fix | info",
  "description": "what's wrong",
  "evidence": "why it matters"
}
```

## Consent Model

- **Low risk**: No consent needed — silent structural readback.
- **Standard/High risk**: Consent envelope relayed to the human. The human decides.
- Global RDD mode permits reviews; it never grants per-candidate consent.
- A decline is scoped to that candidate — NOT the kill switch.

## Correction Budget

- Max **2 fix rounds** per review.
- Only BLOCKER/CRITICAL findings that survive adversarial verification enter the fix loop.
- Anything still open after round 2 is reported to the user as open — the loop never extends.
- Standard review: 1 general refuter per finding.
- Full-4R: 3 refuters (correctness, exploitability/impact, reproducibility) with 2-of-3 vote.

## Integration with Existing Skills

| Skill | RDD integration |
|---|---|
| `judgment-day` | Dual-blind review uses same severity/ledger format, feeds into RDD if enabled |
| `chained-pr` | RDD respects 400-line boundary — each PR reviewed independently |
| `work-unit-commits` | Each work unit is a review candidate boundary |
| `sdd-verify` | SDD verification is independent of RDD — both can run |

## Native Lifecycle (when CLI available)

```
STATUS → START (freezes candidate) → bound lens collection → finalize → ordinary repo policy
```

- START freezes the candidate immutably (lineage + worktree + target)
- Reviewers inspect only immutable trees (never live worktree)
- No receipt or delivery authority survives — approval is just evidence
- The agent uses CLI commands; never fabricates review results

## Without CLI (documentation-only mode)

When `gentle-ai` is NOT installed:
- Use 4R lens skills as **standalone review checklists** during implementation
- Apply precision gates from each lens when writing code
- Report findings in the same ledger format for consistency
- No native lifecycle, no consent, no correction budget
- The agent simply applies the principles as quality guidance
