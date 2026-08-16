# Ops Doc Testing Template v4.0

## Purpose

`ops/TESTING.md` is startup-ingested. It should tell an agent the fastest safe verification path and the few area overrides worth knowing before editing.

This is runtime verification guidance, not architecture documentation and not a test inventory.

Critical rule: after any new feature or behavior change, run relevant tests and fix failures immediately.

## Template

```markdown
# Testing

DATETIME of last agent review: DD MMM YYYY HH:MM (Europe/London)

## Purpose
One sentence describing the repo's testing surface.

## Fast Path
- `exact command` - default quick verification
- `exact command` - build/type/compile smoke

## Area Overrides
- `path/or/subsystem` -> `exact command` - what it validates
- `path/or/subsystem` -> `exact command` - when to use it

## Read-Only Runtime Checks
- `exact command` - prod-safe smoke or health query
Delete section if empty.

## Key Test Locations
- `tests/` - primary suite
- `path/to/special-tests` - optional area-specific tests
Delete lines that do not apply.

## Known Gaps
- Real gaps or caveats only.
Delete section if empty.

## Agent Testing Protocol
**MANDATORY:** Run relevant tests after every new feature or behavior change; fix failures immediately.
```

## Forbidden Content

- Deploy or restart procedures.
- DB migrations or write-heavy operator actions.
- Vague commands such as `run relevant tests`.
- Long file inventories.
- Test lists with no guidance on when to use them.
- Architecture notes that belong in `CONTEXT.md` or ADRs.
- Issue tracker or triage workflow. Use `docs/agents/`.

## Validation Rules

- `Fast Path` should be enough for most small code changes.
- Every override must map a path or subsystem to an exact command.
- `Read-Only Runtime Checks` must be safe on production hosts.
- The doc should scan in under 60 seconds.
- Target 60 lines max.

## Principles

1. Startup useful: high signal only.
2. Speed over completeness: commands must support agent iteration.
3. Exact commands: no guessing.
4. Mandatory post-change testing persists through doc recreation.
