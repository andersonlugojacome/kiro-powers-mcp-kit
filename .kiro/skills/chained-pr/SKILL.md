---
name: chained-pr
description: "Trigger: PRs over 400 lines, stacked PRs, review slices. Split oversized changes into chained PRs that protect review focus."
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Activation Contract

Load this skill when a planned PR may exceed **400 changed lines**, SDD forecasts `400-line budget risk: High` or `Chained PRs recommended: Yes`, or the user asks for chained/stacked PRs, review slices, or reviewer-load control.

## Hard Rules

- Split PRs over **400 changed lines** unless a maintainer explicitly accepts `size:exception`.
- Keep each PR reviewable in about **≤60 minutes**.
- Use one deliverable work unit per PR; keep tests/docs with the unit they verify.
- State start, end, prior dependencies, follow-up work, and out-of-scope items in every chained PR.
- Every child PR must include a dependency diagram marking the current PR with `📍`.
- In Feature Branch Chain, create a draft/no-merge tracker PR; child PR #1 targets the tracker branch, later children target the immediate parent branch.
- Treat polluted diffs as base bugs: retarget or rebase until only the current work unit appears.
- Do not mix chain strategies after the user chooses one.

## Chain Strategies

### Stacked PRs to Main

Each PR merges directly to `main` in order. Best for speed-first teams and independent slices.

```
main ← PR #1 ← PR #2 ← PR #3
```

- Each PR can land independently.
- Fast iteration, fix on the go.
- No tracker needed.

### Feature Branch Chain

A feature/tracker branch accumulates the final integration. Child PRs target the immediate parent branch for focused review diffs. Only the tracker merges to `main`.

```
main ← tracker (draft) ← PR #1 ← PR #2 ← PR #3
```

- Best for rollback control and coordinated releases.
- Tracker stays draft until all children integrate.
- Review diff stays focused (only the current work unit appears).

## Decision Gates

| Condition | Action |
|---|---|
| PR ≤400 changed lines and focused | Keep single PR. |
| PR >400, each slice can land independently | Use Stacked PRs to main. |
| PR >400, feature must integrate before main | Use Feature Branch Chain with tracker. |
| Generated/vendor/migration diff cannot split cleanly | Ask maintainer for `size:exception`. |
| SDD provides `delivery_strategy` | Follow it before apply/PR creation. |

## Execution Steps

1. Estimate changed lines and identify independent work units.
2. Ask for a chain strategy when none is cached and the budget is exceeded.
3. Create branches/PRs using the chosen strategy only.
4. Add Chain Context to each PR (see below) without replacing the repo PR template.
5. Verify each PR independently: CI/tests/docs/manual checks, rollback scope, and clean diff.
6. Keep tracker PR draft/no-merge until all child PRs are reviewed and integrated.

## Chain Context (add to each PR body)

```markdown
## Chain Context

**Strategy:** [stacked-to-main | feature-branch-chain]
**Position:** PR #N of M

### Dependency Diagram
- [ ] PR #1: feat(auth): add token model ← merged
- [x] 📍 PR #2: feat(auth): wire login flow ← this PR
- [ ] PR #3: feat(auth): add refresh tokens ← next

### Scope
- **Start state:** [what existed before this PR]
- **End state:** [what this PR delivers]
- **Out of scope:** [what comes in later PRs]
```

## Output Contract

Return the chosen strategy, PR order, current PR boundary, dependency diagram, review budget (`additions + deletions`), verification plan, and any `size:exception` rationale.

## References

- [references/chaining-details.md](references/chaining-details.md) — branch commands, reviewer guidance, rebase workflow.
