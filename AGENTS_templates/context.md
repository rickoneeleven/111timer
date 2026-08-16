# Context Template v2.0

## Purpose

`CONTEXT.md` is the repo's domain language source. Agents use it during non-trivial domain or Module design work to name Modules, choose Seams, and avoid inventing weak terms.

It is not startup-ingested by default. It is opened when domain language matters.

It is not a runtime map, file inventory, implementation tour, backlog, issue tracker, or architecture essay.

## Rules

- Keep durable domain terms only.
- Name concepts from user workflows, product UI, stored facts, external contracts, and business rules.
- Use this file before naming new Modules.
- If a design session sharpens or adds a durable term, update this file inline.
- Do not add code-only helper names unless they represent a real domain concept.
- Do not record temporary implementation plans here. Use issues or `follow_up.md`.
- Do not record accepted or rejected architecture choices here. Use `docs/adr/`.
- Do not record runtime procedures here. Use README or `ops/`.

## Template

```markdown
# Context

DATETIME of last agent review: DD MMM YYYY HH:MM (Europe/London)

## Purpose
One sentence describing the product/domain in user language.

## Domain Terms

### <Term>
- Meaning:
- Invariants:
- Common sources:
- Common actions:
- Related terms:

### <Term>
- Meaning:
- Invariants:
- Common sources:
- Common actions:
- Related terms:

## Workflows

### <Workflow Name>
- User goal:
- Inputs:
- Output:
- Failure modes:
- Modules that should usually be involved:

## External Concepts

### <External Concept>
- Source:
- Meaning in this repo:
- Contract facts:
- Failure modes:

## Naming Rules
- Prefer these terms when naming Modules:
- Avoid these ambiguous terms:
- Terms that need user clarification before reuse:
```

## Quality Bar

- A new agent can use the same domain words as the operator.
- Each term helps choose Module names or Seams.
- Removing any section would cause future agents to invent weaker names.
- The file stays short enough to scan before design work.
