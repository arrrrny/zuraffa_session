# Bug Assessment: after_specify worktree hook fails on a commit-less repo

- **Slug**: worktree-create-empty-repo
- **Created**: 2026-08-23
- **Source**: pasted text (observed during `/skill:speckit-specify` run)
- **Verdict**: valid
- **Severity**: high

## Report (verbatim or summarized)

Observed while running `/skill:speckit-specify` for the new `zikzak_session` package.

The mandatory `after_specify` hook (`speckit.worktrees.create`) failed with:

```
Error: git worktree add -b '001-portable-browser-sessions' at '/Users/ahmettok/Developer/zikzak_session/.worktrees/001-portable-browser-sessions' from 'HEAD' failed.
Run 'git fetch' or use --in-place if worktrees are not available.
```

The spec itself was written successfully to `specs/001-portable-browser-sessions/spec.md`, but the post-spec worktree isolation step aborts.

## Symptom

When `/skill:speckit-specify` finishes on a repository that has **no commits yet**, the `after_specify` worktree hook cannot create the feature worktree and exits non-zero with a misleading "Run 'git fetch'" message. Expected: the hook either creates the worktree, or fails with a clear, actionable message about the missing commit.

## Reproduction

1. `git init` a fresh repository (or use a scaffolded package such as `zikzak_session` that has never been committed).
2. Run `/skill:speckit-specify` to produce a spec (this registers `feature.json` and triggers the `after_specify` hook).
3. The hook invokes `create-worktree.sh --json --layout nested 001-portable-browser-sessions`.
4. `git worktree add -b 001-portable-browser-sessions .worktrees/001-portable-browser-sessions HEAD` fails because `HEAD` is an unborn branch (no commits).

Confirmed on this machine:
- `git log` → `fatal: your current branch 'master' does not have any commits yet`
- `git worktree list` → `0000000 [master]`

## Suspected Code Paths

- `.specify/extensions/worktrees/scripts/bash/create-worktree.sh:167-175` — `resolve_base_ref()` checks `origin/main`, `main`, `origin/master`, `master` and, when none exist, falls through to `echo "HEAD"`. On a commit-less repo, `HEAD` is unborn, so the chosen base ref does not resolve.
- `.specify/extensions/worktrees/scripts/bash/create-worktree.sh:207-223` — the create-worktree block runs `git worktree add -b "$BRANCH_NAME" "$WT_TARGET" "$RESOLVED_BASE"` (RESOLVED_BASE = `HEAD`) for a new branch, which fails on an unborn `HEAD`, then prints the generic "Run 'git fetch'" error.
- `.specify/extensions/worktrees/worktree-config.yml` — `auto_create: true` causes the `after_specify` hook to invoke the script without prompting, so the failure is unavoidable for new repos.

## Root Cause Hypothesis

The worktree script assumes an existing commit to branch from. On a brand-new Zuraffa package scaffolded via `zfa` (which generates files but may leave the repo with zero commits), there is no `HEAD` commit, so `git worktree add -b <branch> <path> HEAD` cannot succeed. The error message ("Run 'git fetch'") is misleading because the real cause is the absent initial commit, not a missing remote. Confidence: high (reproduced and traced to the exact lines above).

## Proposed Remediation

**Preferred**: Add an explicit unborn-HEAD guard in `create-worktree.sh`. Before attempting `git worktree add`, detect the commit-less state with `git rev-parse --verify HEAD >/dev/null 2>&1`. If it fails, emit a precise, actionable error — e.g. "Repository has no commits yet; create an initial commit (or pass --in-place) before spawning a worktree" — and exit non-zero. This replaces the misleading "Run 'git fetch'" message and makes the root cause self-evident. Optionally, the `after_specify` hook could treat a commit-less repo as a no-op (skip worktree) with a clear notice, so `/skill:speckit-specify` still completes cleanly for brand-new packages.

**Alternatives**:
- Make the worktree script support an orphan/empty base (e.g., `git worktree add --orphan` style or create a throwaway empty commit) — more invasive and adds side effects the script should avoid.
- Document in the workflow that an initial commit is required before `/skill:speckit-specify`; lower effort but still leaves the current cryptic failure in place.

**Files likely to change**:
- `.specify/extensions/worktrees/scripts/bash/create-worktree.sh` (unborn-HEAD detection near `resolve_base_ref` / the create-worktree block)

**Tests to add or update**:
- A script test that runs `create-worktree.sh` against a `git init`'d, commit-less repo and asserts a clear "no commits" error (not the generic fetch message).
- A test asserting successful worktree creation still works on a repo with ≥1 commit.

## Risks & Considerations

- Any fix must remain non-destructive (no implicit commits created by the script).
- Changing the default `after_specify` behavior (skipping worktree on commit-less repos) affects all new packages in this ecosystem — coordinate with the spec-kit workflow expectations.
- This is a workflow/tooling limitation, not a defect in the `zikzak_session` package source. It has a trivial local workaround (create an initial commit, or pass `--in-place`), but it hard-blocks the mandated Specify → Worktree automation for every new Zuraffa package.

## Open Questions

- Should the preferred fix be a precise error message, or should the `after_specify` hook skip worktree creation on commit-less repos? (Operational choice; either unblocks the workflow.)
- Where should the issue be filed? The affected script lives in the spec-kit worktrees extension; the `zikzak_session` repo currently has no GitHub remote configured, so a live issue cannot be created from here without adding a remote + an initial commit first.
