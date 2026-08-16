# Agent Domain Docs

DATETIME of last agent review: 16 Aug 2026 15:51 (Europe/London)

## Layout

- Mode: single-context
- Domain context: create `CONTEXT.md` only when non-trivial domain or Module design requires it
- ADR directory: create `docs/adr/` entries only for durable accepted or rejected decisions
- Runtime docs: `ops/`
- Short-lived handover: `follow_up.md` when present
- Issue tracker and triage config: not configured

## Read Rules

- At startup, read this file plus `ops/manifest.yaml` and `ops/TESTING.md`.
- Before non-trivial domain or Module design, read `CONTEXT.md` when present.
- Read only ADRs relevant to the touched area.
- Read `follow_up.md` when present and relevant to active validation work.
- Open other top-level `ops/*.md` only for the runtime concern they describe.

## Write Rules

- Put durable domain terms in `CONTEXT.md` and durable architecture decisions in `docs/adr/`.
- Put skill routing and tracker vocabulary in `docs/agents/`.
- Put runtime facts and operator checks in top-level `ops/*.md`.
- Put short-lived handover and validation checklists in `follow_up.md`.
- Do not mix runtime procedures, domain language, architecture decisions, or issue-tracker configuration.

## Architecture Vocabulary

- A Module hides its Implementation behind an Interface; Depth is complexity removed from callers.
- A Seam is where behavior varies, and an Adapter is a concrete implementation at that Seam.
- Prefer Leverage and Locality; avoid shallow pass-through Modules and hypothetical Seams.
- Treat the Interface as the test surface and apply the deletion test before extracting a Module.
