# Release Versioning

DATETIME of last agent review: 16 Aug 2026 16:29 (Europe/London)

## Trigger

Read and apply this rule before committing any repository change.

## Rule

Increment the final numeric segment of `## Version` in `111timer.toc` once for every committed change set.

- Preserve the major and minor segments unless the user explicitly requests a larger release bump.
- Carry the patch segment normally: `1.0.0` becomes `1.0.1`, and `1.0.9` becomes `1.0.10`.
- Include the manifest version change in the same commit as the code, test, or documentation change.
- Verify that `111timer.toc` contains the new version before pushing.

Completion criterion: every pushed change commit has a manifest patch version newer than its first parent.
