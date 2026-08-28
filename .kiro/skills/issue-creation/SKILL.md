---
name: issue-creation
description: "Create and triage GitHub issues from repository evidence. Trigger: issue creation, bug reports, feature requests, or issue approval."
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when:
- Creating a GitHub issue (bug report, feature request, task)
- Triaging or classifying an existing issue
- Commenting on an issue with new evidence
- Approving or labeling issues based on repository evidence

## Critical Rules

| Rule | Requirement |
|------|-------------|
| Evidence-based | Never invent facts, labels, approval, or policy |
| Duplicate search first | Mandatory open+closed duplicate search before any write |
| One attempt only | One create/comment attempt, classified as `confirmed / no_write / unknown` |
| YAML forms authority | If repo has `.github/ISSUE_TEMPLATE/` YAML forms, use them as format authority |
| Privacy scan | Scrub local paths, usernames, credentials before mutation |
| Protected labels | `status:approved`, `size:exception` require verified maintainer authority |
| Resolve target | Must confirm exact `OWNER/REPO` before any read/write |

## Execution Flow

```
1. RESOLVE target repository (OWNER/REPO)
2. DISCOVER issue templates (YAML forms in .github/ISSUE_TEMPLATE/)
3. SEARCH duplicates (open + closed issues with relevant keywords)
4. DECIDE:
   - Duplicate found → comment on existing instead of new issue
   - No duplicate → proceed with creation
   - Unclear → classify as `unknown` and STOP
5. SELECT appropriate template/form
6. BUILD issue body from evidence (not assumptions)
7. PRIVACY SCAN — scrub paths, usernames, secrets
8. CREATE issue (or comment on existing)
9. VERIFY — readback the created/updated issue
10. REPORT result with classification
```

## Decision Gates

| Condition | Action |
|---|---|
| Exact duplicate found (open) | Comment with new evidence, do not create |
| Exact duplicate found (closed) | Reopen if new evidence warrants, otherwise comment |
| Similar but not duplicate | Create new issue, reference the similar one |
| No template matches | Create with plain markdown, note missing template |
| Unsure about classification | Mark `unknown`, report to user, STOP |
| Protected label needed | Verify maintainer authority first |

## Issue Body Quality

### Required sections

1. **Title**: Action-oriented, searchable (verb + noun + context)
2. **Description**: What happened / what's needed (evidence, not assumption)
3. **Reproduction** (bugs): Steps, environment, expected vs actual
4. **Acceptance criteria** (features): Concrete, testable conditions
5. **Context**: Links to related code, PRs, or issues

### Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Vague title ("Bug in auth") | Specific: "Login fails with expired refresh token on mobile" |
| No reproduction steps | Add exact steps, environment, versions |
| Assumptions as facts | Prefix with "Hypothesis:" or investigate first |
| Missing context | Link to file/line/PR where the issue manifests |

## Labels Strategy

| Category | Labels | When |
|---|---|---|
| Type | `type:bug`, `type:feature`, `type:docs`, `type:chore` | Always apply one |
| Priority | `priority:high`, `priority:medium`, `priority:low` | If triaging |
| Status | `status:triage`, `status:approved`, `status:blocked` | Workflow state |
| Size | `size:small`, `size:medium`, `size:large`, `size:exception` | If estimating |

## Privacy Scan Checklist

Before creating/commenting, verify none of these appear:
- [ ] Absolute local file paths (`/Users/`, `C:\Users\`)
- [ ] Usernames or email addresses
- [ ] API keys, tokens, or credentials
- [ ] Internal hostnames or IPs
- [ ] Proprietary code snippets (use minimal reproduction)

## Commands

```bash
# Search for duplicates
gh issue list --search "keywords" --state all --limit 10

# Create issue from template
gh issue create --template "bug_report.yml" --title "..." --body "..."

# Add label
gh issue edit <number> --add-label "type:bug"

# Comment on existing
gh issue comment <number> --body "New evidence: ..."
```
