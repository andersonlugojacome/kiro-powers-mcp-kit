---
name: comment-writer
description: "Write warm, direct collaboration comments. Trigger: PR feedback, issue replies, reviews, Slack messages, or GitHub comments."
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

Load this skill when writing any collaboration comment:

- PR review feedback
- Issue replies and triage comments
- Code review suggestions
- GitHub discussion responses
- Slack/Teams messages about code

## Critical Rules

| Rule | Requirement |
|------|-------------|
| Lead with action | Start with the actionable point, no recap preamble |
| Warm and direct | Thoughtful teammate tone, not corporate bot |
| Tight format | 1-3 short paragraphs or tight bullet list |
| Explain WHY | When requesting changes, explain the reason |
| One focus | Comment on highest-value issue only, no pile-ons |
| Match language | Follow target context language (Spanish thread → Spanish) |
| No em dashes | Use commas, periods, or semicolons instead |

## Comment Formula

```
<Direct observation or request>
<Why it matters — only if non-obvious>
<Concrete next action or suggestion>
```

## Examples

### PR Review (requesting change)

```
This query rebuilds the full user list on every request.
Consider adding pagination — the table has ~50k rows in prod
and this will timeout under load.

Something like `LIMIT :size OFFSET :page * :size` with defaults
would keep response times under 200ms.
```

### PR Review (approval with note)

```
Clean implementation. The retry logic handles the edge cases well.

One small thing for a follow-up: the backoff multiplier is
hardcoded at 2x. A config constant would make tuning easier
later without touching this logic.
```

### Issue Triage

```
Reproduced on Node 20.11 with the steps described.
The root cause looks like the stream isn't closing on timeout.

I'll pick this up in the next sprint — marking as confirmed.
```

## Anti-Patterns

| Anti-pattern | Problem | Better |
|---|---|---|
| "Great job! I have a few minor suggestions..." | Buries the point | Lead with the suggestion |
| Commenting on 10 things at once | Overwhelms the author | Pick the highest-value item |
| "Can you fix this?" without why | Author can't learn | Explain the reasoning |
| Corporate tone ("Please be advised...") | Creates distance | Write like a teammate |
| Restating what the PR already says | Wastes time | Add new information only |
