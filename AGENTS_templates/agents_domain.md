# Agents Domain Template v2.0

## Purpose

`docs/agents/domain.md` tells agent skills how to consume domain and architecture docs in this repo. It is repo-local skill wiring, not the domain model itself.

This file should make skills predictable without bloating bootstrap.

## Template

```markdown
# Agent Domain Docs

DATETIME of last agent review: DD MMM YYYY HH:MM (Europe/London)

## Layout
- Mode: single-context
- Domain context: `CONTEXT.md`
- ADR directory: `docs/adr/`
- Runtime docs: `ops/`
- Short-lived handover: `follow_up.md`
- Issue tracker config: `docs/agents/issue-tracker.md`
- Triage labels config: `docs/agents/triage-labels.md`

## Read Rules
- At startup, read only this file plus the bootstrap ops docs.
- Before non-trivial domain or Module design, read `CONTEXT.md`.
- Read only ADRs relevant to the touched area.
- Read `follow_up.md` when a task may touch active handover or validation work.
- Read runtime notes under `ops/` only when the task touches runtime behavior, deploy, logs, services, integrations, or tests.
- Read issue tracker and triage config only when using issue, PRD, or triage skills.

## Write Rules
- Add durable domain terms to `CONTEXT.md`.
- Add durable accepted or rejected architecture decisions to `docs/adr/`.
- Add skill routing and tracker vocabulary to `docs/agents/`.
- Add runtime facts and operator checks to top-level `ops/*.md`.
- Add short-lived handover and validation checklists to `follow_up.md`.
- Do not put architecture essays or issue-tracker config in `ops/`.
- Do not put runtime procedures in `CONTEXT.md` or ADRs.

## Architecture Vocabulary
- Module: anything with an Interface and Implementation.
- Interface: everything callers must know to use a Module correctly.
- Implementation: code inside the Module.
- Depth: behavior behind a small Interface.
- Seam: where an Interface lives.
- Adapter: concrete thing satisfying an Interface at a Seam.
- Leverage: what callers get from Depth.
- Locality: where change, bugs, knowledge, and tests concentrate.

## Default Module Shaping
- Keep normal agent work autonomous.
- Build deep Modules by default: meaningful behavior behind small Interfaces.
- Avoid shallow pass-through Modules and fake Seams.
- Use the deletion test before extracting or keeping a Module.
- Treat the Interface as the test surface.
- Keep cohesive deep Modules together even when the Implementation is internally rich.
- Split files only when the extracted Module has its own Interface, Locality, or test surface.
- Update `CONTEXT.md` or ADRs inline only when durable terms or decisions emerge.
```

## Quality Bar

- Skills know where to read before design work.
- Skills know where to write durable domain and architecture knowledge.
- The repo does not confuse runtime ops docs with agent-skill config or domain architecture docs.
- The file is short enough to ingest at startup.
