# Doc Recreation Process v5.0

## Trigger

Run when README.md, `ops/manifest.yaml`, any top-level `ops/*.md` except `ops/SECURITY_REVIEW.md`, or `docs/agents/domain.md` has a missing or stale `DATETIME of last agent review` header.

Also run when nested runtime docs exist under `ops/**` (`*.md` or `*.yaml` below top level).

## Goal

Rebuild the project's documentation map so agents can:
- understand the runtime from a compact startup manifest,
- find deeper docs on demand,
- avoid mixing runtime ops, agent-skill config, domain language, and architecture decisions.

## Why Rebuild vs Patch

Patching stale docs preserves old assumptions. Rebuilding from source of truth keeps docs smaller, current, and easier for agents to trust.

## Documentation Roles

**README.md** = human setup, deploy, and troubleshooting guide.
- Not ingested at startup.
- Can contain detailed install, config, and recovery procedures.

**ops/manifest.yaml** = startup runtime map.
- Ingested at startup.
- Compact facts: what runs, what matters, where to read next.

**ops/TESTING.md** = startup test map.
- Ingested at startup.
- Exact fast-path commands and focused overrides.

**top-level ops/*.md** = runtime notes opened on demand.
- Runtime facts, read-only checks, operator actions, gotchas.
- No architecture essays, issue tracker rules, or domain glossaries.

**ops/SECURITY_REVIEW.md** = security review workflow and latest audit evidence.
- Checked at startup.
- Updated immediately after security reviews.

**docs/agents/*.md** = agent-skill config.
- Issue tracker, triage labels, and domain-doc routing.
- Not runtime ops docs.

**CONTEXT.md** = durable domain language.
- Product/user terms, invariants, workflows, external concepts.
- Used before naming Modules or Seams.

**docs/adr/*.md** = durable decisions.
- Accepted and rejected architecture choices future agents should not re-litigate.

**follow_up.md** = short-lived handover.
- Active mini PRD plus validation checklist.
- Prefer the configured issue tracker for new planned work.

## Structure

```text
README.md
CONTEXT.md
follow_up.md
docs/
  agents/
    domain.md
    issue-tracker.md
    triage-labels.md
  adr/
    YYYYMMDD-short-decision.md
ops/
  manifest.yaml
  TESTING.md
  SECURITY_REVIEW.md
  runtime.md
  integrations.md
```

Rules:
- One root README only.
- No README files in subfolders.
- No nested runtime docs under `ops/**`.
- `ops/manifest.yaml` is the only required runtime ops doc.
- Keep top-level ops docs lean. Default target: manifest, TESTING, SECURITY_REVIEW, and 0 to 3 focused runtime notes.
- Subfolders under `ops/` may contain non-doc runtime assets such as probes, scripts, fixtures, or config, but not `*.md` or `*.yaml` docs.
- Architecture and skill config live under `CONTEXT.md`, `docs/adr/`, and `docs/agents/`, never under `ops/`.
- Vendor, node_modules, dist, build, cache, and venv directories are excluded from doc recreation.

## Process

### 1. Gather Context
- Read existing README.md, `ops/manifest.yaml`, and top-level `ops/*.md`.
- Read `docs/agents/domain.md` if present.
- Read `CONTEXT.md` and relevant ADRs only when current docs or source need domain/architecture clarification.
- Detect forbidden nested docs under `ops/**`.
- Note what useful knowledge exists and where it belongs.

### 2. Crawl Source of Truth

| Target | Extract |
|--------|---------|
| package/composer/pyproject files | stack, scripts, test commands |
| runtime version files | required versions |
| env examples | required config and safe defaults |
| service/supervisor/cron/deploy files | services, timers, restart commands |
| app/src routes/commands/workers | entrypoints and runtime units |
| migrations/schema | operational tables and persisted state |
| tests | fast path and area overrides |
| existing domain docs | durable terms and decisions |

For every named runtime unit, confirm it exists in source or deploy config.

Classify every command:
- read-only check,
- mutating operator action,
- setup/deploy procedure.

Do not put mutating commands in read-only sections.

### 3. Delete and Rebuild Runtime Docs

```bash
rm -f README.md
find ops -mindepth 1 -maxdepth 1 -type f \( -name "*.md" -o -name "manifest.yaml" \) ! -name "SECURITY_REVIEW.md" -delete
find ops -mindepth 2 -type f \( -name "*.md" -o -name "*.yaml" \) -delete
```

Do not delete:
- `follow_up.md` unless the user explicitly asks.
- `CONTEXT.md`.
- `docs/adr/`.
- `docs/agents/`.
- `ops/SECURITY_REVIEW.md` unless running a security review recreation and preserving evidence.

### 4. Recreate README
Use `AGENTS_templates/reed_me.md`.

Preserve human operational knowledge:
- setup,
- deploy,
- config examples,
- troubleshooting,
- common operations.

Do not place domain decisions or runtime maps here beyond short pointers.

### 5. Recreate Runtime Ops Docs
Use `AGENTS_templates/ops_manifest.yaml` for `ops/manifest.yaml`.

Populate:
- short project summary,
- `read_next` pointers,
- entrypoints,
- services/timers,
- env files and state paths,
- read-only health checks,
- default test commands,
- focused gotchas.

Create `ops/TESTING.md` with `AGENTS_templates/ops_doc_testing.md`.

Create optional top-level runtime notes with `AGENTS_templates/ops_runtime_note.md` only when they have:
- a real Open When,
- concrete runtime facts,
- useful checks or operator actions,
- gotchas that prevent likely mistakes.

Merge overlapping notes. Delete notes that cannot justify their existence.

### 6. Ensure Agent-Skill and Domain Docs
Do not recreate these as part of runtime doc cleanup unless they are missing or clearly stale.

If `docs/agents/domain.md` is missing:
- Create it from `AGENTS_templates/agents_domain.md`.
- Record single-context vs multi-context layout.

If `docs/agents/issue-tracker.md` or `docs/agents/triage-labels.md` is missing and issue/PRD/triage skills are needed:
- Use the Matt-style setup skill if available.
- If unavailable, create concise equivalents after confirming tracker and label choices with the user.
- Confirm issue tracker and label vocabulary with the user when required.

If `CONTEXT.md` is missing and domain or Module design work needs it:
- Create it from `AGENTS_templates/context.md`.
- Populate only durable domain language visible in code, UI, external contracts, or user decisions.

If a decision should survive future sessions:
- Create an ADR from `AGENTS_templates/adr.md`.
- Do not create ADRs for routine implementation details.

### 7. Verify
- [ ] README preserves useful setup/deploy/troubleshooting knowledge.
- [ ] README has one root copy only.
- [ ] `ops/manifest.yaml` is compact and can be read in under 60 seconds.
- [ ] `ops/TESTING.md` has exact fast-path test commands.
- [ ] Each runtime note has a real Open When and gotcha.
- [ ] All named services, timers, and entrypoints were cross-checked.
- [ ] Read-only sections contain read-only commands only.
- [ ] No nested docs remain under `ops/**`.
- [ ] `docs/agents/domain.md` exists when skills need domain-doc routing.
- [ ] `CONTEXT.md` exists when domain work needs domain language.
- [ ] ADRs exist only for durable decisions.
- [ ] All recreated docs have fresh timestamps.

## Acceptance Rubric

A recreated doc set is acceptable only if:
- An agent can get the high-level project shape from `ops/manifest.yaml` quickly.
- README contains human deployment and troubleshooting knowledge.
- Runtime notes answer distinct runtime questions.
- Skills know where domain docs and issue tracker config live.
- The new doc set is smaller, clearer, and less duplicated than what it replaced.

## Content Placement Guide

| Content Type | Goes In |
|--------------|---------|
| Install dependencies | README |
| First-time server setup | README |
| Service config examples | README |
| Troubleshooting procedures | README |
| Startup runtime map | `ops/manifest.yaml` |
| Fast tests and area overrides | `ops/TESTING.md` |
| Runtime checks and operator actions | top-level `ops/*.md` |
| Security audit evidence | `ops/SECURITY_REVIEW.md` |
| Issue tracker rules | `docs/agents/issue-tracker.md` |
| Triage label vocabulary | `docs/agents/triage-labels.md` |
| Domain terms and invariants | `CONTEXT.md` |
| Durable architecture decisions | `docs/adr/*.md` |
| Short-lived validation handover | `follow_up.md` |

## What Not To Do

- Do not put agent-skill config in `ops/`.
- Do not put architecture essays in `ops/`.
- Do not put runtime procedures in `CONTEXT.md`.
- Do not put temporary plans in ADRs.
- Do not split runtime notes by feature when one area doc would do.
- Do not create docs that only mirror file names.
- Do not keep nested docs under `ops/**`.
- Do not leave placeholder sections.
- Do not preserve stale docs just because they exist.
