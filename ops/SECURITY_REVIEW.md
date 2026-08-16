# Security Review

DATETIME of last security audit: 16 Aug 2026 15:53 (Europe/London)

## Scope

This repository is a client-side World of Warcraft addon. It has no web server, HTTP routes, deployment service, environment files, credentials, or network integration. Web-root, endpoint, TLS, and HTTP-header checks are therefore not applicable to this runtime.

## Workflow

When this review is triggered:

1. Confirm the runtime and deployment shape from tracked files and `111timer.toc`.
2. Search the repository and its immediate parent for secrets, keys, dumps, backups, and environment files.
3. Inspect tracked files, ignored files, unexpected artifacts, and file permissions.
4. Search product code for credentials, dynamic code execution, outbound communication, and debug or administrative surfaces.
5. Run the behavioural harness and `git diff --check`.
6. Record exact evidence and classify the outcome as PASS, PASS WITH NOTES, FAIL, or UNVERIFIED.

Halt development on any exposed secret, unexpected network or dynamic-execution path, unsafe distributable artifact, or material check that cannot be completed.

## Latest Audit Evidence

### Runtime and exposure

- Command: `pwd`
- Key output: `/home/loopnova/repo/WoW/111timer`
- Command: `rg -n '(SavedVariables|## Interface|dofile\\(|CreateFrame|RegisterEvent|SlashCmdList)' 111timer.toc 111timer.lua tests/test.lua`
- Key output: product runtime is one `Interface: 30300` addon file using WoW frames, events, a slash command, and `OneElevenTimerDB`; `dofile` occurs only in the test harness.
- Result: PASS. There is no served tree, server configuration, public endpoint, or transport layer to audit.

### Secrets and artifacts

- Command: `find .. -maxdepth 2 \( -name '.env' -o -name '*.sql' -o -name '*.pem' -o -name '*.key' -o -iname '*backup*' -o -iname '*secret*' \) -print`
- Key output: no matches.
- Command: `git ls-files | rg -i '(^|/)(\\.env|id_rsa|.*\\.pem|.*\\.key|credentials|secrets?)(\\.|/|$)' || true`
- Key output: no matches.
- Command: `find . -maxdepth 3 -type f \( -name '.env' -o -name '*.pem' -o -name '*.key' -o -iname '*secret*' -o -name '*.bak' -o -name '*.old' -o -name '*.orig' -o -name '*.swp' -o -name '*~' \) -not -path './.git/*' -print`
- Key output: no matches.
- Result: PASS.

### Code and repository hygiene

- Command: `git ls-files`
- Key output: only `111timer.lua`, `111timer.toc`, `LICENSE`, `README.md`, and `tests/test.lua` were tracked at audit time.
- Command: `rg -n -i '(password|passwd|api[_-]?key|secret|token|authorization|bearer|private[_-]?key|loadstring|dofile|runScript|SendChatMessage|debug|admin|http://|https://)' --glob '!AGENTS.md' --glob '!AGENTS_REVIEW.md' --glob '!AGENTS_templates/**' --glob '!ops/SECURITY_REVIEW.md' . || true`
- Key output: only the test harness's fixed `dofile("111timer.lua")` matched.
- Command: `find . -maxdepth 3 -type f -not -path './.git/*' -printf '%M %u %g %p\\n' | sort`
- Key output: reviewed files were owner-writable and world-readable (`-rw-r--r--`), appropriate for source and addon distribution; no secret-bearing files exist.
- Command: `git status --ignored --short`
- Key output: expected documentation changes only; no ignored sensitive or generated artifact was reported.
- Note: `.gitignore` is absent. This is non-critical because the repository has no generated build output or local secret/config file, but ignore rules should be added if either is introduced.
- Result: PASS WITH NOTES.

### Verification

- Command: `npx --yes --package=fengari-node-cli fengari tests/test.lua`
- Key output: `111timer behavioural tests passed`.
- Command: `git diff --check`
- Key output: no errors.
- Result: PASS.

## Outcome

PASS WITH NOTES: no critical security findings or exposed secrets were found. Web-specific checks are not applicable to this client-only addon. The missing `.gitignore` is a low-risk repository-hygiene note under the current project shape.
