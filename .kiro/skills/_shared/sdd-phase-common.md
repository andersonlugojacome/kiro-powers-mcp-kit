# SDD Phase — Common Protocol

Boilerplate identical across all SDD phase skills. Load alongside phase-specific SKILL.md.

---

## Skill Registry

The orchestrator pre-resolves skill paths before launching you. You receive a `SKILL: Load {path}` instruction. Load that file. If no path provided, proceed without (not an error).

---

## Engram Upsert Note

When saving artifacts with `mem_save`, always set `topic_key` to the canonical key (e.g., `sdd/{change-name}/proposal`).

`topic_key` enables upserts — saving again updates, not duplicates.

---

## Return Envelope

Every phase MUST return a structured envelope:

| Field | Description |
|---|---|
| `status` | `success`, `partial`, or `blocked` |
| `executive_summary` | 1-3 sentence summary |
| `detailed_report` | (optional) Full phase output |
| `artifacts` | List of artifact keys/paths written |
| `next_recommended` | Next SDD phase to run, or "none" |
| `risks` | Risks discovered, or "None" |

Example:

```markdown
**Status**: success
**Summary**: Proposal created for `{change-name}`.
**Artifacts**: Engram `sdd/{change-name}/proposal`
**Next**: sdd-spec or sdd-design
**Risks**: None
```
