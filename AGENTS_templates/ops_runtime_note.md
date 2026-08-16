# Runtime Note Template v3.0

## Purpose

Focused runtime notes are opened on demand. They exist only when operational knowledge is expensive to rediscover from code, deploy config, or logs.

Runtime notes are not domain docs, architecture docs, issue-tracker docs, or file inventories.

## Constraints

- Must live at top-level `ops/` only.
- Target 20 to 25 lines, hard max 35.
- Prefer merged area docs over one doc per feature.
- No setup guides or long explanations.
- File paths are optional and should appear only when operationally important.
- If the note cannot justify `Open When` and at least one real `Gotcha`, delete it.

## Template

````markdown
# [Area]

DATETIME of last agent review: DD MMM YYYY HH:MM (Europe/London)

## Purpose
One sentence describing the runtime area.

## Open When
- Touching:
- Investigating:
- Deploying:

## Runtime Facts
- Service / timer / supervisor:
- Env file / secret path:
- External dependency:
- State / log / queue path:

## Read-Only Checks
```bash
exact command
exact command
```

## Operator Actions
```bash
exact command
```
Delete section if empty.

## Gotchas
- Only non-derivable facts that prevent bad decisions.
````

## Forbidden Content

- File inventories or code tours.
- Setup instructions that belong in README.
- Architecture essays.
- Domain terms that belong in `CONTEXT.md`.
- Issue tracker or triage config that belongs in `docs/agents/`.
- Commands that mutate state under `Read-Only Checks`.
- A note that only repeats `ops/manifest.yaml`.

## Validation Rules

- `Open When` names real trigger conditions.
- `Read-Only Checks` are read-only.
- `Operator Actions` are clearly mutating.
- Overlapping notes are merged.
- If this note does not save a future agent from a real mistake, delete it.

## Good Uses

- Service behavior not obvious from code.
- External integration contracts and failure modes.
- Runtime state files, queues, or lock behavior.
- DB-backed runtime toggles or caches.
