# OpenSpec File Convention (shared across all SDD skills)

## Directory Structure

```
openspec/
├── config.yaml              <- Project-specific SDD config
├── specs/                   <- Source of truth (main specs)
│   └── {domain}/
│       └── spec.md
└── changes/                 <- Active changes
    ├── archive/             <- Completed changes (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       <- Active change folder
        ├── state.yaml       <- DAG state (orchestrator)
        ├── exploration.md   <- (optional) from sdd-explore
        ├── proposal.md      <- from sdd-propose
        ├── specs/           <- from sdd-spec
        │   └── {domain}/
        │       └── spec.md
        ├── design.md        <- from sdd-design
        ├── tasks.md         <- from sdd-tasks
        └── verify-report.md <- from sdd-verify
```

## Artifact File Paths

| Skill | Creates / Reads | Path |
|---|---|---|
| orchestrator | Creates/Updates | `openspec/changes/{change-name}/state.yaml` |
| sdd-init | Creates | `openspec/config.yaml`, `openspec/specs/`, `openspec/changes/` |
| sdd-explore | Creates (optional) | `openspec/changes/{change-name}/exploration.md` |
| sdd-propose | Creates | `openspec/changes/{change-name}/proposal.md` |
| sdd-spec | Creates | `openspec/changes/{change-name}/specs/{domain}/spec.md` |
| sdd-design | Creates | `openspec/changes/{change-name}/design.md` |
| sdd-tasks | Creates | `openspec/changes/{change-name}/tasks.md` |
| sdd-apply | Updates | `openspec/changes/{change-name}/tasks.md` (marks `[x]`) |
| sdd-verify | Creates | `openspec/changes/{change-name}/verify-report.md` |
| sdd-archive | Moves | `-> openspec/changes/archive/YYYY-MM-DD-{change-name}/` |

## Reading Artifacts

```
Proposal:   openspec/changes/{change-name}/proposal.md
Specs:      openspec/changes/{change-name}/specs/ (all domains)
Design:     openspec/changes/{change-name}/design.md
Tasks:      openspec/changes/{change-name}/tasks.md
Config:     openspec/config.yaml
Main specs: openspec/specs/{domain}/spec.md
```

## Writing Rules

- ALWAYS create change directory before writing artifacts
- If file exists, READ first and UPDATE (don't overwrite)
- If change directory has artifacts, the change is being CONTINUED
- Use `openspec/config.yaml` rules for project-specific constraints

## Config File Reference

```yaml
# openspec/config.yaml
schema: spec-driven

context: |
  Tech stack: {detected}
  Architecture: {detected}
  Testing: {detected}

rules:
  proposal:
    - Include rollback plan for risky changes
  specs:
    - Use Given/When/Then for scenarios
    - Use RFC 2119 keywords
  design:
    - Include sequence diagrams for complex flows
  tasks:
    - Group by phase, hierarchical numbering
    - Keep tasks completable in one session
  apply:
    tdd: false
    test_command: ""
  verify:
    test_command: ""
    build_command: ""
    coverage_threshold: 0
  archive:
    - Warn before merging destructive deltas
```

## Archive Structure

Archived changes move to:
```
openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Archive is an AUDIT TRAIL — never delete or modify archived changes.
