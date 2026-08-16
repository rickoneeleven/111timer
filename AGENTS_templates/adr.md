# ADR Template v2.0

## Purpose

ADRs record durable architecture decisions so future agents do not re-litigate the same choice.

Create one only when a decision affects Module shape, Interface design, Seam placement, Adapter choice, data ownership, external contract handling, deploy layout, or testing strategy.

Do not create ADRs for routine style, temporary plans, issue tracking, or choices obvious from the framework.

## Filename

Use:

```text
docs/adr/YYYYMMDD-short-slug.md
```

Example:

```text
docs/adr/20260502-market-card-selection-module.md
```

## Template

```markdown
# ADR: <Decision Title>

DATETIME of last agent review: DD MMM YYYY HH:MM (Europe/London)

## Status
Accepted | Superseded | Rejected

## Context
- What pressure forced this decision?
- What domain terms from `CONTEXT.md` matter?
- Which Modules, Interfaces, Seams, or Adapters are involved?
- What evidence was considered?

## Decision
- The durable decision in plain language.
- Where the main Seam lives, if relevant.
- Which Adapter or Implementation owns the behavior, if relevant.

## Consequences
- Leverage gained:
- Locality gained:
- Test surface:
- Tradeoffs accepted:

## Rejected Options

### <Option>
- Why rejected:
- When to reconsider:

## Links
- Related files:
- Related tests:
- Related issue/follow-up:
```

## Quality Bar

- A future architecture review can use the ADR to avoid suggesting a rejected path again.
- The decision is stated without needing to read the whole diff.
- Benefits are described in terms of Leverage, Locality, and test surface.
- Runtime procedures stay in README or `ops/`; domain terms stay in `CONTEXT.md`.
