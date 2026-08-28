# Delegated Workflow Actions — Reference

## When Actions Require Delegation

Post-publication actions on issues (label changes, milestone assignment, project board moves) may require delegated authority. This reference defines the boundaries.

## Authority Model

| Action | Self-service | Requires delegation |
|--------|--------------|---------------------|
| Create issue | Yes (any contributor) | — |
| Comment on issue | Yes (any contributor) | — |
| Add `type:*` label | Yes (issue author + maintainers) | — |
| Add `priority:*` label | Maintainers only | Yes, if not maintainer |
| Add `status:approved` | Maintainers only | Yes, always verify authority |
| Add `size:exception` | Maintainers only | Yes, always verify authority |
| Close issue | Author + maintainers | — |
| Reopen issue | Author + maintainers | — |
| Assign issue | Maintainers + assignee self | Verify membership |
| Move to project board | Project members | Verify membership |

## Delegation Flow

```
1. Identify action needed
2. Check if current authority is sufficient
3. If insufficient:
   a. Report to user: "This requires maintainer authority"
   b. Suggest: ask a maintainer, or provide evidence for the request
   c. Do NOT attempt the action
4. If sufficient:
   a. Execute the action
   b. Verify readback
   c. Report result
```

## Protected Labels

These labels have special workflow meaning and MUST NOT be applied without verified authority:

| Label | Meaning | Authority |
|-------|---------|-----------|
| `status:approved` | Issue is approved for work | Maintainer explicit approval |
| `status:blocked` | Issue cannot proceed | Anyone who identifies blocker |
| `size:exception` | PR may exceed 400-line budget | Maintainer explicit acceptance |

## Evidence Requirements

When requesting delegation or protected label application:

1. State the evidence that supports the action
2. Link to the relevant code, PR, or discussion
3. Do not assume the outcome — present evidence and let the authority decide
