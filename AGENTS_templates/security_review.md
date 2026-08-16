# Project Security Review Template v2.0

## Purpose

Perform a short, repeatable security review when required by AGENTS.md.

The review detects obvious deployment, repository, public exposure, secret handling, and access-control risks before development continues.

## Storage

Record this workflow and the latest audit evidence in `ops/SECURITY_REVIEW.md`.

Use this header:

```text
DATETIME of last security audit: DD MMM YYYY HH:MM (Europe/London)
```

Do not store security audit evidence in README unless the project has no `ops/` directory and the user explicitly chooses that layout.

## When To Run

- Missing `ops/SECURITY_REVIEW.md`.
- Missing or stale security audit timestamp.
- Evidence of public exposure.
- Security-sensitive changes.
- Deploy layout, permissions, secret handling, auth, or public endpoint changes.
- User request.

## Stop Conditions

If any are true, halt the session and tell the user remediation is required:

- Public web root can expose private application files.
- Secrets are stored inside the served tree.
- `.env`, `.git`, backups, keys, dumps, logs, vendor archives, or private config files are web-accessible.
- Directory listing is enabled on sensitive paths.
- Deployed layout depends on deny rules alone instead of keeping private files outside public web root.
- Required checks cannot be performed and the unresolved gap could hide critical exposure.

## Principles

- Prefer secure filesystem layout over deny rules.
- Prefer fail-closed defaults.
- Verify with concrete evidence.
- Treat unperformed critical checks as unresolved.
- Keep evidence brief: command, key output, result.

## Required Evidence

For each completed review, capture:
- exact command run,
- key output lines,
- URL checked if applicable,
- result: PASS, FAIL, or UNVERIFIED.

## Review Workflow

### 1. Public Web Root And Deploy Layout

Goal: confirm private files are outside the served tree.

Example checks:
- `sudo apachectl -S`
- `sudo grep -R "DocumentRoot" /etc/apache2/sites-enabled /etc/apache2/sites-available 2>/dev/null`
- `sudo nginx -T 2>/dev/null | grep -n "root "`
- `pwd`
- `find .. -maxdepth 2 \( -name ".env" -o -name ".git" -o -name "*.sql" -o -name "*.pem" -o -name "*backup*" \)`

Pass: document root is a dedicated public directory and sensitive files are outside the served tree.

### 2. Secrets Not Web-Accessible

Goal: secret-bearing files cannot be fetched over HTTP(S).

Example checks:
- `curl -I https://example.com/.env`
- `curl -i https://example.com/.env`
- `curl -I https://example.com/.git/config`
- `curl -I https://example.com/storage/logs/app.log`
- `curl -I https://example.com/backup.zip`

Pass: sensitive paths are unreachable or return safe non-disclosing responses.

### 3. VCS Metadata Protected

Goal: repository metadata cannot be scraped.

Example checks:
- `curl -I https://example.com/.git/`
- `curl -I https://example.com/.git/config`
- `curl -I https://example.com/.git/HEAD`
- `curl -I https://example.com/.svn/entries`

Pass: VCS metadata is not publicly reachable.

### 4. Directory Listing And Predictable Artifacts

Goal: indexing, backups, temp files, and old deploy artifacts are not exposed.

Example checks:
- `curl -I https://example.com/storage/`
- `curl -i https://example.com/uploads/`
- `find public -type f \( -name "*.bak" -o -name "*.old" -o -name "*.orig" -o -name "*.swp" -o -name "*~" -o -name "*.map" \)`

Pass: no sensitive listings or predictable artifacts are exposed.

### 5. Framework And Server Config Hygiene

Goal: production-safe defaults.

Example checks:
- inspect env/config for debug mode,
- inspect rendered error responses,
- review server access-control directives,
- search routes for debug/admin/test/profiler endpoints.

Pass: debug tooling is off or protected, and unsafe directives are absent.

### 6. Secret Storage And Key Handling

Goal: secrets are stored minimally and safely.

Example checks:
- `git ls-files | grep -E '(\.env|id_rsa|\.pem|credentials|secrets?)'`
- `find . -maxdepth 3 \( -name ".env" -o -name "*.pem" -o -name "*.key" -o -name "*secret*" \)`

Pass: secrets are not tracked or exposed and live only in approved locations.

### 7. Repository Hygiene

Goal: sensitive files are excluded from version control and build artifacts.

Example checks:
- `sed -n '1,220p' .gitignore`
- `git status --ignored`
- inspect CI/deploy packaging scope.

Pass: ignore rules and packaging scope are safe.

### 8. Permissions And Ownership

Goal: least privilege for config, secrets, storage, cache, and public files.

Example checks:
- `namei -om /path/to/public`
- `find . -maxdepth 3 -type f -name ".env" -exec ls -l {} \;`
- `find storage bootstrap/cache -maxdepth 2 -printf '%M %u %g %p\n' 2>/dev/null`

Pass: no world-readable secrets or overly broad write access.

### 9. Dangerous Public Endpoints

Goal: admin, debug, test, maintenance, and metrics surfaces are absent or protected.

Example paths:
- `/admin`
- `/phpinfo.php`
- `/server-status`
- `/debug`
- `/horizon`
- `/telescope`
- `/actuator`
- `/metrics`

Pass: sensitive endpoints are absent or strongly protected.

### 10. Transport And Headers

Goal: basic web hardening.

Example checks:
- `curl -I http://example.com`
- `curl -I https://example.com`
- inspect HSTS, X-Content-Type-Options, and cookie flags.

Pass: HTTPS and basic hardening are present for sensitive surfaces.

## Audit Outcome

Use one:
- PASS: no critical issues found.
- PASS WITH NOTES: non-critical issues or unresolved low-risk gaps.
- FAIL: critical finding; halt further work.
- UNVERIFIED: critical checks could not be completed; halt if unresolved risk is material.
