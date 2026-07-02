# Contributing to Kiro Powers MCP Kit

Thanks for your interest in contributing! This project is a Spec-Driven Development framework for Kiro, and we welcome contributions that improve the workflow, fix bugs, or enhance documentation.

## Prerequisites

Before contributing, make sure you have:

- **Node.js 18+** — required for Context7 and Jira MCP
- **Engram GO** — `brew install gentleman-programming/tap/engram` (macOS) or see [docs/setup-engram.md](docs/setup-engram.md)
- **Git** — configured with your GitHub account

## How to Contribute (Fork + PR)

### 1. Fork the repository

Click the **Fork** button on [github.com/andersonlugojacome/kiro-powers-mcp-kit](https://github.com/andersonlugojacome/kiro-powers-mcp-kit).

### 2. Clone your fork

```bash
git clone https://github.com/YOUR-USERNAME/kiro-powers-mcp-kit.git
cd kiro-powers-mcp-kit
```

### 3. Create a branch

```bash
git checkout -b feature/your-change-description
```

Branch naming:
- `feature/description` — new functionality
- `fix/description` — bug fix
- `docs/description` — documentation only

### 4. Make your changes

Follow the project conventions:
- Skills go in `.kiro/skills/<skill-name>/SKILL.md`
- Steering files go in `.kiro/steering/` or `steering/`
- Documentation goes in `docs/`

### 5. Verify before pushing

```bash
# macOS/Linux
./scripts/setup.sh

# Windows (PowerShell)
./scripts/setup.ps1
```

Make sure:
- `mcp.json` is valid JSON
- All skills have a `SKILL.md` file
- Required steering files exist (`AGENTS.md`, `01-mcp-workflow.md`, `02-sdd-orchestrator-runtime.md`)
- Required docs exist (`setup-engram.md`, `setup-atlassian.md`, `setup-context7.md`, `powers-roadmap.md`)

### 6. Commit

Use conventional commits:

```bash
git commit -m "feat: add new skill for X"
git commit -m "fix: correct path in validate workflow"
git commit -m "docs: improve installation instructions"
```

Commit types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

**Never** add "Co-Authored-By" or AI attribution to commits.

### 7. Push to your fork

```bash
git push -u origin feature/your-change-description
```

### 8. Open a Pull Request

1. Go to your fork on GitHub
2. Click **"Compare & pull request"**
3. Base: `andersonlugojacome/kiro-powers-mcp-kit` branch `main`
4. Fill in the PR description explaining what and why
5. Submit

## What Happens Next

1. GitHub Actions runs `validate.yml` on your PR — it must pass green
2. The maintainer reviews your changes
3. If changes are requested, push new commits to the same branch (the PR updates automatically)
4. Once approved, the maintainer merges

## What We Accept

| Type | Welcome | Notes |
|------|---------|-------|
| Bug fixes | ✅ | Include steps to reproduce |
| New SDD skills | ✅ | Must follow SKILL.md format with frontmatter |
| Documentation improvements | ✅ | Typos, clarity, examples |
| New MCP server integrations | ✅ | Add setup doc in `docs/` |
| Steering file improvements | ✅ | Must not break existing workflow |
| Refactors | ⚠️ | Open an issue first to discuss |
| New frameworks/dependencies | ❌ | This is a process framework, not a code framework |

## What We Don't Accept

- Changes that break install/uninstall/update lifecycle of the Power
- Modifications to `POWER.md` frontmatter (`name`, `version`) without maintainer approval
- Hard-coded secrets or credentials in any file
- Skills without proper `SKILL.md` and frontmatter

## Code of Conduct

Be respectful, constructive, and focused on improving the project. We're here to build better development processes together.

## Questions?

Open a [Discussion](https://github.com/andersonlugojacome/kiro-powers-mcp-kit/discussions) or an [Issue](https://github.com/andersonlugojacome/kiro-powers-mcp-kit/issues).
