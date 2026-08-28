# Chaining Details — Reference

## Branch Commands (Stacked to Main)

```bash
# PR #1
git checkout -b feat/auth-token-model main
# ... implement + commit
git push -u origin feat/auth-token-model
gh pr create --base main --title "feat(auth): add token model" --body "Closes #N"

# PR #2 (after PR #1 merged)
git checkout main && git pull
git checkout -b feat/auth-login-flow main
# ... implement + commit
git push -u origin feat/auth-login-flow
gh pr create --base main --title "feat(auth): wire login flow" --body "Closes #N"
```

## Branch Commands (Feature Branch Chain)

```bash
# Create tracker branch
git checkout -b feat/auth main
git push -u origin feat/auth
gh pr create --base main --title "feat(auth): complete auth system" --body "Tracker PR — do not merge until all children integrate" --draft

# PR #1 targets tracker
git checkout -b feat/auth-token-model feat/auth
# ... implement + commit
git push -u origin feat/auth-token-model
gh pr create --base feat/auth --title "feat(auth): add token model" --body "Closes #N"

# PR #2 targets PR #1 branch for focused diff
git checkout -b feat/auth-login-flow feat/auth-token-model
# ... implement + commit
git push -u origin feat/auth-login-flow
gh pr create --base feat/auth-token-model --title "feat(auth): wire login flow" --body "Closes #N"
```

## Rebase Workflow (keeping chain clean)

```bash
# After PR #1 merged to tracker, rebase PR #2
git checkout feat/auth-login-flow
git rebase feat/auth
git push --force-with-lease origin feat/auth-login-flow
# Retarget PR #2 base to feat/auth
gh pr edit <pr-number> --base feat/auth
```

## Reviewer Guidance

For reviewers of chained PRs:

1. **Read the Chain Context** section first to understand position and scope.
2. **Review only the current work unit** — earlier work was reviewed in prior PRs.
3. **Check the dependency diagram** to understand what's merged and what's coming.
4. **Verify the diff is clean** — only current work unit changes should appear.
5. **Approve in order** — don't approve PR #3 before PR #2 is reviewed.

## Size Metrics

- **Budget threshold**: 400 changed lines (additions + deletions).
- **Target review time**: ≤60 minutes per PR.
- **Ideal size**: 200-300 changed lines for focused review.
- **Exception**: `size:exception` label required for PRs that cannot split cleanly (migrations, generated code, vendor updates).

## SDD Integration

When working with SDD:
- `sdd-tasks` produces a Review Workload Forecast.
- If forecast says `Chained PRs recommended: Yes`, load this skill.
- Follow the cached `delivery_strategy` from the SDD session.
- Map SDD task groups to PR boundaries (one task group ≈ one PR).
