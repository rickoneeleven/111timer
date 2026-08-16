# README Template v5.0

## Purpose

README.md gets a human from clone to running code and records first-time setup, deploy, and troubleshooting procedures.

README is not ingested by agents at startup. Agent startup awareness lives in `ops/manifest.yaml`, testing guidance in `ops/TESTING.md`, skill config in `docs/agents/`, domain language in `CONTEXT.md`, and durable decisions in `docs/adr/`.

## Principles

1. Source of truth is the repo. Scan for commands; do not invent them.
2. Omit sections with no evidence. No placeholders.
3. Section budgets prevent bloat.
4. Operational depth is allowed for humans.
5. Point to agent docs instead of duplicating them.
6. Do not store domain glossaries, architecture decisions, or issue-tracker rules here.

## Section Budgets

| Section | Max Lines | Required | Purpose |
|---------|-----------|----------|---------|
| Title + Purpose | 5 | Yes | Project name, one-line description |
| Stack | 8 | Yes | Runtime versions, dependencies |
| Quick Start | 12 | Yes | Clone to running, happy path only |
| First-Time Server Setup | 60 | If applicable | Services, cron, capabilities, system tweaks |
| Configuration | 25 | If applicable | Env vars and config files needing explanation |
| Common Operations | 20 | If applicable | Restart, cache clear, deploy checks |
| Troubleshooting | 40 | If applicable | Known issues with tested solutions |
| Links | 5 | If applicable | Dashboards, related repos |
| Agent Docs | 8 | Yes | Pointers to agent/runtime docs |

Total target: ~175 lines. Most READMEs should be shorter.

## Section Guidelines

### Title + Purpose

```markdown
# Project Name

One sentence: what this does and for whom.
```

### Stack

List runtime requirements with version sources:

```markdown
## Stack
- Node 22 (see `.nvmrc`)
- PostgreSQL
- systemd timers
```

### Quick Start

Happy path only. Assume dependencies are installed.

````markdown
## Quick Start
```bash
git clone <repo>
cp .env.example .env
npm install
npm test
npm run dev
```
````

### First-Time Server Setup

Use for operational depth:
- service installation,
- systemd/supervisor examples,
- capability or permission setup,
- crontab entries,
- system tweaks.

### Configuration

Document env vars that need explanation beyond their name.

```markdown
## Configuration
Required env vars - see `.env.example`:
- `API_BASE_URL` - upstream API root used by workers.
- `WORKER_CONCURRENCY` - max concurrent jobs per worker.
```

### Common Operations

Copy-paste commands for routine human operations.

````markdown
## Common Operations
```bash
sudo systemctl restart app.service
npm run build
```
````

### Troubleshooting

Known issues with tested solutions:
- symptom,
- diagnosis,
- exact fix command.

### Agent Docs

Short pointers only:

```markdown
## Agent Docs
- Runtime map: `ops/manifest.yaml`
- Testing map: `ops/TESTING.md`
- Agent skill config: `docs/agents/`
- Domain language: `CONTEXT.md`
- Architecture decisions: `docs/adr/`
```

## Skeleton

````markdown
# Project Name

One sentence: what this does and for whom.

## Stack
- Runtime 1
- Runtime 2

## Quick Start
```bash
git clone <repo>
cp .env.example .env
# install commands
# run command
```

## First-Time Server Setup

### Service
```ini
[Unit]
Description=App
```

## Configuration
Required env vars - see `.env.example`:
- `VAR_NAME` - explanation

## Common Operations
```bash
exact command
```

## Troubleshooting

### Issue Name
Symptom and diagnosis steps.
Fix: `exact command`

## Agent Docs
- Runtime map: `ops/manifest.yaml`
- Testing map: `ops/TESTING.md`
- Agent skill config: `docs/agents/`
- Domain language: `CONTEXT.md`
- Architecture decisions: `docs/adr/`
````

## Validation Checklist

- [ ] Every command is tested or verified from repo/deploy config.
- [ ] Section budgets are respected.
- [ ] Empty sections are omitted.
- [ ] Agent docs are linked, not duplicated.
- [ ] No marketing copy, badges, screenshots, or placeholders.
