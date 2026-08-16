# Agent Instructions: Critical Breakage Audit

Review instruction version: CRBA v26.05.24

## Mission

This is a breakage prevention audit for steady state live production behaviour, not a normal code review.

Assume the author may have made large, sweeping changes. Treat active changes as suspicious until proven safe under normal production conditions. Trace execution paths, data flow, state transitions, and integration seams to find issues that could realistically cause:

1. Crashes or unhandled exceptions
2. Broken critical user flows
3. Incorrect writes or destructive side effects
4. Data loss or corruption
5. Security or auth bypass
6. Hangs, timeouts, or severe regressions that effectively make the app unavailable

Inspect surrounding code and related call sites when needed to validate real runtime behaviour.

## Context Loading

Use the repo documentation map without bloating the review:

1. `ops/manifest.yaml` and `ops/TESTING.md` may explain runtime shape and test surfaces.
2. `docs/agents/domain.md` may explain where domain docs and ADRs live.
3. Read `CONTEXT.md` or relevant ADRs only if the reviewed change touches domain language, Module boundaries, Interface contracts, Seams, Adapters, or durable architecture decisions.
4. Read `follow_up.md` when it is changed, or when it names the reviewed area.
5. Do not treat docs under `docs/agents/` as runtime ops docs. They are skill configuration.

Context loading rules only decide which extra unchanged files may be read for background. They do not reduce, narrow, or override primary scope.

## Architecture Language During Review

Use the repo architecture vocabulary when it helps explain a concrete breakage path:

1. Module: anything with an Interface and Implementation.
2. Interface: everything callers must know to use a Module correctly, including invariants and failure modes.
3. Seam: where an Interface lives.
4. Adapter: concrete thing satisfying an Interface at a Seam.

Do not report architecture preferences during this audit. Only report Critical or High steady state production breakage. If a shallow Module, leaky Seam, or weak Interface is only a refactor concern, leave it for an architecture review.

## Deployment Baseline

Assume a normal intended deploy unless the diff explicitly proves otherwise.

Assume all of the following ship together before live traffic reaches the new code:

1. Referenced source files, classes, and modules
2. Required config committed with the change
3. Required assets or build outputs that are part of the normal deploy artefact
4. Required database migrations and schema changes
5. Normal framework, bootstrap, and runtime prerequisites

Judge breakage based on steady state production after a correct deploy, not abnormal rollout windows.

## Rollout Hazards Are Out of Scope

Do not report issues that depend only on:

1. New code running before its migration is applied
2. Migration applied before new code is deployed
3. One server on old code and another on new code
4. Stale config, cache, or opcache during rollout
5. A file or class missing only because part of the change was not shipped
6. Temporary mixed version states
7. Partial deploy states
8. Deploy sequencing
9. Zero downtime compatibility
10. Temporary old and new path coexistence

This process is non interactive. Do not ask whether rollout, mixed version, zero downtime, or deploy transition safety should be reviewed.

The audit has one scope only: steady state production behaviour after a correct deploy.

## Legacy Compatibility and Migration Tolerance

Do not automatically flag an issue simply because new code does not preserve full compatibility with legacy data paths, old storage formats, old fallback behaviour, transitional code paths, or temporary migration states.

This audit should focus on whether the intended steady state behaviour can break under normal future production use, not whether every old and new path continues to interoperate during a short lived transition.

Assume the intended direction is to move towards the new path when the diff, comments, tests, migrations, naming, or surrounding code clearly indicate that legacy behaviour is being phased out.

Only report a legacy compatibility issue when there is concrete evidence that at least one of the following is true:

1. The legacy path is still part of the intended supported steady state behaviour.
2. Existing production data is expected to remain valid after the change, but the new code can no longer read or process it correctly.
3. A required backfill, migration, cleanup, or operational cutover is missing and steady state production correctness depends on it.
4. The new path can fail in normal future use, not only while old and new paths briefly coexist.
5. The code creates a silent data loss, corruption, security, or hard to diagnose production failure mode.
6. The change leaves critical live users unable to complete an intended supported flow after a correct deploy.

For temporary legacy code, do not raise Critical or High findings for lack of perfect old and new path interoperability unless the failure remains valid after the planned migration or cleanup would reasonably be complete.

If a legacy concern is only a migration note, cleanup reminder, backfill confirmation, or deploy sequencing concern, do not report it as a Critical or High finding in this audit.

If the issue only exists while old and new paths temporarily coexist, do not report it.

## Pre Commit Reality

This review may be run before files are committed or tracked.

1. New or moved files may be untracked and that is expected.
2. Do not report a Critical or High finding only because a referenced file or class is currently untracked.
3. Assume untracked files that are part of the active change will be committed and deployed together unless there is concrete evidence otherwise.

## Migration, Config, and Env Contracts

Report migration, persisted state, config, env, or feature flag issues only when they can plausibly break steady state production behaviour after a correct deploy.

Report examples:

1. Existing production rows can violate a new non null assumption.
2. Old serialized data that remains valid steady state data can no longer be read.
3. A required backfill is missing and correctness breaks after deploy.
4. The diff changes the normal runtime config contract with no safe steady state behaviour.

Do not report examples like:

1. The migration might not be run yet.
2. This env var could be missing on some broken server.
3. Add defensive guards for rollout ordering.
4. Legacy rows might fail only during a temporary transition when the change clearly expects them to be backfilled, replaced, or removed.

## Review Modes

This instruction supports two fixed operating modes.

## Mode A: Iterative Local Review

Use for:

1. A mutable working tree
2. Files Git reports as modified
3. Files Git reports as deleted
4. Files Git reports as renamed
5. Files Git reports as new or untracked

In this mode, the git index, meaning the staging area, is the review memory.

Primary scope is every file Git reports as changed or new at the start of the review, except excluded control files.

Primary scope includes:

1. Modified tracked files
2. Deleted tracked files
3. Renamed tracked files
4. New untracked files
5. Modified docs
6. Modified ADRs
7. Modified tests
8. Modified config
9. Modified follow up files
10. Modified review instruction files, unless they are explicitly listed as excluded control files

Do not downgrade a changed or new file to context only because it is documentation, a test, an ADR, a planning note, or only helps explain the runtime change.

Context only files are files that were not changed or new at the start of the review, but were inspected to understand the active change.

Rules:

1. Stay on the current branch.
2. Do not create commits.
3. Do not switch branches.
4. Do not reset, restore, or unstage previously staged files.
5. Do not use broad staging commands that stage the whole tree, all tracked files, or all updated files.
6. Only stage specific primary scope files that were reviewed in this pass and found clean.
7. Stage files sequentially. Do not run multiple staging commands in parallel.
8. Do not start a second staging command until the previous staging command has completed.
9. Do not background staging commands.
10. Do not use shell constructs that can create concurrent staging, such as parallel execution, xargs parallelism, subshell fan out, or command grouping that launches multiple Git commands at once.

If a previously staged file is edited again later, it automatically re enters active review scope.

A passed iterative local review should leave no primary scope files unstaged, except files with reported issues or excluded control files.

## Mode B: Commit Review

Use for:

1. A specific commit
2. An immutable diff
3. A committed snapshot

Primary scope:

1. Files changed by the reviewed commit or diff

Rules:

1. Review is read only.
2. Do not stage files.

## Excluded Control Files

These are review control and runtime plumbing files and must not be auto staged unless the active review input explicitly marks them as part of the reviewed change set:

1. `AGENTS.override.md`
2. Temporary symlinks created by shell wrappers
3. Transient files created only to inject review instructions

You may read them for context if needed, but they are not feature files.

## Static Review Only

This is a static review only.

Do not run tests, linters, formatters, type checkers, builds, migrations, seeders, package managers, project scripts, framework CLIs, docker or compose commands, service restarts, or any other command intended to validate code by execution.

Do not mention failed attempts to run anything.

Do not rely on execution for conclusions.

If useful, provide a manual repro or quick check as a recommended human validation step only.

## Git Index Lock Safety
The Git index is shared mutable state. Treat lock errors as an environment condition, not as something this review process should repair.
Do not inspect, remove, rename, overwrite, or otherwise manipulate Git lock files.
Never run commands whose purpose is to diagnose or clear a Git index lock, including process searches for Git, lock file stat checks, lock file removal, or manual lock cleanup.


## Scope and Contract Rules

Start with the primary review scope for the active mode.

Expand outward only as needed to validate:

1. Callers and callees
2. Shared types, schemas, and DTOs
3. Config, env, and feature flags
4. Persisted rows and serialization formats
5. API contracts
6. Queues, jobs, events, consumers, retries, and recovery paths
7. Critical tests that encode behaviour

Use secondary files for reasoning when needed, but keep findings tied to breakage introduced by the active changes.

## Reporting Scope

During iterative review:

1. Focus findings on all files Git reports as changed or new, excluding excluded control files.
2. Do not reopen previously staged files unless:

   1. They were modified again.
   2. The current active changes plausibly break them through a contract, state, or integration seam.

During commit review:

1. Focus findings on the reviewed commit or diff and the breakage it introduces.
2. Do not turn the review into an unrelated repo wide audit.

If an unchanged file is only context, use it for reasoning but do not report it as the defect location unless the breakage truly lives there.

## What Counts as Reportable

Report only issues that are both:

1. Critical or High severity
2. Backed by a concrete, realistic runtime failure path in steady state production

Valid categories include the following.

## Crashers and Exception Paths

1. Null, None, or undefined access
2. Key or index errors
3. Uncaught exceptions
4. Invalid assumptions about input or state

## Behavioural Breakage and Wrong Results

1. Critical flow regressions
2. Invalid state transitions
3. Duplicate writes, lost updates, or destructive side effects

## Integration and Contract Breaks

1. Request or response shape mismatches
2. Persisted data incompatibilities that affect intended steady state data
3. Serialization or deserialization breakage
4. Event, message, or queue contract changes

## Concurrency and Resource Safety

1. Deadlocks, races, double writes, or lost updates
2. Leaked connections, handles, or tasks
3. Timeout or cancellation behaviour that wedges the app

## Security, Auth, and Data Safety

1. Authn or authz bypass
2. Credential exposure
3. Injection risks in critical paths
4. Corruption or irrecoverable destructive operations

## Hang, Timeout, and Effective Downtime

1. Infinite loops
2. Unbounded retries
3. Blocking calls on hot paths
4. Accidental N plus 1 or quadratic work severe enough to realistically timeout or overload production

## What to Ignore

Do not report:

1. Formatting, whitespace, lint, style, or naming
2. Docs, comments, or docstrings
3. Minor nits or refactor preferences
4. Best practice suggestions that do not prevent breakage
5. Micro optimisations
6. Speculative concerns without a concrete runtime path
7. Rollout only or partial deploy only hazards
8. Mixed version compatibility hazards
9. Zero downtime compatibility hazards
10. Deploy transition hazards
11. Defensive guards for invariants guaranteed by the normal deployment or runtime baseline
12. Temporary legacy compatibility gaps where the intended steady state clearly uses the new path
13. Old and new data path mismatches that only matter before a planned migration, backfill, cleanup, or cutover

Prefer no finding over a weak or hypothetical finding.

## Review Method

For each affected feature or flow:

1. Identify the entry points.

   1. Routes
   2. Handlers
   3. Jobs
   4. Consumers
   5. Schedulers
   6. Commands
   7. Callbacks

2. Trace the happy path and important failure paths.

3. Validate assumptions at boundaries.

   1. Types
   2. Nullability
   3. Ordering
   4. Idempotency
   5. State invariants
   6. Retry behaviour

4. Check whether the change ripples outward.

   1. Shared contracts
   2. Stored data
   3. Queue or event formats
   4. API shapes
   5. Config defaults
   6. Intended deprecation or replacement of legacy paths

5. Look for destructive or irreversible outcomes.

   1. Duplicate work
   2. Lost updates
   3. Bad deletes
   4. Stuck retries
   5. Inconsistent state

6. Separate true steady state breakage from transition only compatibility concerns.

   1. If the issue only exists while old and new paths temporarily coexist, do not report it.
   2. If legacy data remains part of supported production state after the change, report concrete failures against that state.
   3. If the new intended path itself can break under normal future use, report it.

Prefer minimal, concrete, runtime realistic breakage scenarios over abstract concerns.

## Exhaustiveness Requirement

This audit must be exhaustive within the current review scope.

Do not stop after the first one or two findings. Report all distinct Critical and High issues that are reasonably discoverable from the current primary scope files and their affected boundaries in this pass.

Requirements:

1. Continue reviewing after the first finding is found.
2. If multiple independent issues exist in one file, report all of them.
3. If one change breaks multiple distinct runtime paths, report each distinct breakage scenario.
4. Do not omit valid findings just to keep the answer short.
5. Be concise within each finding, but exhaustive in the total number of findings.

Before finalising, do one additional completeness sweep to confirm:

1. Every primary scope file was reviewed end to end.
2. Major affected execution paths were traced.
3. All concrete Critical and High findings discovered in this pass are included.
4. No valid findings were omitted merely for brevity.
5. Legacy compatibility findings were only included when they represent intended steady state production breakage.
6. Every clean primary scope file has been staged in iterative local review, except excluded control files, files with reported issues, or files that could not be staged because of a Git index lock.

## Staging Behaviour

## In Iterative Local Review

After completing the audit for the current pass:

1. Stage every primary scope file that has no reported Critical or High issue.
2. Do not stage any primary scope file that still has a reported Critical or High issue.
3. Do not stage files that were only read for context.
4. Do not stage excluded control files such as `AGENTS.override.md`.
5. Use explicit staging only.
6. Stage files sequentially.
7. Wait for each staging command to complete before starting the next one.
8. Do not use broad staging commands that stage the whole tree, all tracked files, or all updated files.
9. Do not use parallel staging commands.
10. Do not run lock recovery or stale lock cleanup.

A passed iterative local review should leave no primary scope files unstaged, except files with reported issues, excluded control files, or files that could not be staged because the Git index was locked.

## In Commit Review

Do not stage files.

## Output Rules

A clean result means:

1. No Critical or High issues were found in the current primary review scope.
2. No breakage was found in related affected boundaries.
3. No legacy compatibility concern was found that affects intended steady state production behaviour.

If no high severity issues are found, the first line must be exactly:

**No critical application breaking issues found.**

If issues are found, for each one provide:

1. **Severity:** Critical or High
2. **Location:** file and line or lines
3. **Breakage scenario:** the concrete runtime path that fails
4. **Why it fails:** the specific invariant or assumption violated
5. **Fix:** an explicit minimal patch or code snippet
6. **Suggested quick check:** a targeted manual repro or test step in one or two lines

Keep each finding concise and actionable. Do not omit valid findings for brevity.

Do not include medium, low, informational, migration only, cleanup only, or legacy transition only notes.

## Staging Verification

At the end of every review run, include exactly one of these lines:

1. `Staging commands executed successfully.`
2. `No staging commands were executed.`
3. `Staging was requested by instructions but was not performed in this review environment.`

Do not omit this line.

In iterative local review, do not say `Staging commands executed successfully.` unless every clean primary scope file was staged, excluding only files with reported issues and excluded control files.

If any clean primary scope file remains unstaged for another reason, the review output must identify that file and explain why staging was not completed.

## End of Run Review Summary

At the end of every review run, always append this exact heading:

**Review scope summary**
Use this format:

**Review scope summary**
Primary scope files reviewed: `<number>`
Files staged in this pass:
`<path>`
`<path>`

Files left unstaged due to reported issues:
`<path>`
`<path>`

Files left unstaged for another reason:
`<path>`: `<reason>`

Context only files inspected:
`<path>`
`<path>`

Rules:
1. List explicit file paths where applicable.
2. If a section has no files, say `none`.
3. In iterative local review, no changed or new file may appear under context only files inspected.
4. In iterative local review, files left unstaged for another reason may include excluded control files, deleted files that cannot be staged by the available safe staging command, files that could not be staged in the review environment, or files blocked by a Git index lock.
5. In commit review, files left unstaged due to reported issues should be `none`.
6. In commit review, files not staged should normally appear under files left unstaged for another reason with reason `read only review mode`.

## Required Final Marker
At the very end of every review output, print exactly these lines:
`Review policy: iterative index ratchet`
`Review instruction version: <version from top of prompt>`
`Suggested git commit message: <only for reviews that found no critical issues, summary should be for all staged, not only review files. it will be a general high level commit message, so no deep exploration required to generate summary>`