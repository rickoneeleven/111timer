# Follow Up Template v2.0

## Purpose

`follow_up.md` is short-lived handover:
1. a compact mini PRD for active work,
2. a validation checklist that may span sessions,
3. incident or rollout monitoring that is not done yet.

It is not a backlog, issue tracker, ADR, domain glossary, or permanent ops note. When a feature is validated, delete its section.

Prefer the configured issue tracker in `docs/agents/issue-tracker.md` for new planned work. Use `follow_up.md` when continuity across agent sessions matters more than long-term tracking.

## Session Protocol

- Read `follow_up.md` at startup if it exists.
- Prioritize relevant unchecked validation items.
- Remove finished sections.
- Keep each feature section small.
- Every validation checkbox must include:
  - exact command, URL, or query,
  - expected success signal,
  - evidence slot.
- Update `Last validation run:` when validation work is performed.

## Conventions

- Use `- [ ]` for unchecked and `- [x]` for complete.
- Link to issues, ADRs, docs, or code paths instead of copying large context.
- Put durable domain terms in `CONTEXT.md`.
- Put accepted or rejected architecture decisions in `docs/adr/`.
- Put runtime facts in top-level `ops/*.md`.
- Put issue workflow and label vocabulary in `docs/agents/`.

---

# Feature Section Template

## Feature: <short name>
Status: Planning | Implementing | Validating | Done
Target env: prod | staging | local
Owner:
Issue:
Created:
Deployed:
Last touched:
Last validation run:

### Problem
- What is broken or missing.
- Who it affects.
- Why it matters.

### Proposal
- What changes at a high level.
- Non-goals.
- Module, Interface, Seam, or Adapter notes if relevant.
- ADR link if a durable decision has been accepted.

### Acceptance Criteria
- [ ] AC1:
- [ ] AC2:

### Implementation Plan
- [ ] Stage 1:
- [ ] Stage 2:
- [ ] Stage 3:

### Rollout
- [ ] Deployment steps:
- [ ] Config/env changes:

### Validation Checklist
- [ ] Check: <name>
  - Command/URL:
  - Expect:
  - Evidence:

- [ ] Check: <name>
  - Command/URL:
  - Expect:
  - Evidence:

### Monitoring Window
- [ ] Monitor for <duration>:
  - Metric/log:
  - Expect:
  - Evidence:

### Rollback Plan
- Trigger:
- Action:
- Verification:

### Cleanup
- [ ] All validation items done.
- [ ] Monitoring window complete.
- [ ] No open incidents.
