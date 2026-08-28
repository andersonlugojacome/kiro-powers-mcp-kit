---
name: cognitive-doc-design
description: "Design docs that reduce cognitive load. Trigger: writing guides, READMEs, RFCs, onboarding, architecture, or review-facing docs."
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when writing or reviewing any document that a human must read and act on:

- README files
- Architecture Decision Records (ADRs)
- RFCs and proposals
- Onboarding guides
- PR descriptions and review docs
- API documentation
- Runbooks and troubleshooting guides

## Critical Patterns

| Pattern | Rule | Why |
|---------|------|-----|
| Lead with the answer | Decision/action/outcome first, context after | Readers need the "what" before the "why" |
| Progressive disclosure | Happy path first, then details/edge cases | Reduces initial cognitive load |
| Chunking | Small sections, short flat lists (max 5-7 items) | Working memory limit |
| Signposting | Clear headings, labels, callouts, one-line summaries | Scannable navigation |
| Recognition over recall | Tables, checklists, examples > prose | Faster pattern matching |
| Review empathy | Reviewers verify intent without reconstructing the story | Reduces review fatigue |

## Documentation Shape (default structure)

```markdown
# Title (action or outcome, not topic)

One-paragraph summary: what this does, who it's for, what problem it solves.

## Quick Path

1. Step one (concrete action)
2. Step two
3. Step three

## Details

| Aspect | Value |
|--------|-------|
| ... | ... |

## Checklist

- [ ] Condition A met
- [ ] Condition B verified

## Next Step

[Link to what comes after →](./next.md)
```

## PR and Review Docs

When writing PR descriptions or review-facing docs:

1. **State what to review first** — the highest-risk or most important file/section.
2. **Declare out of scope** — what this PR does NOT touch and why.
3. **Link prev/next** — in chained PRs, link the chain so reviewers have context.
4. **One decision per section** — don't bundle unrelated choices.
5. **Checklists for acceptance** — concrete yes/no items, not prose.

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Wall of prose | Nobody reads it | Break into sections + table |
| Burying the action | Reader scans, misses the point | Lead with the answer |
| Context-first | Forces reader to hold state | Outcome first, context after |
| No signposting | Reader loses position | Add headings and summaries |
| Exhaustive detail upfront | Overwhelms beginners | Progressive disclosure |

## Commands

```bash
# Check doc structure before committing
# Verify: title is action-oriented, summary exists, quick path has steps
head -20 docs/new-guide.md
```
