# after_specify worktree hook fails on a commit-less repo

**Severity**: high
**Labels**: bug, severity:high

---

## Symptom

When `/skill:speckit-specify` finishes on a repository that has **no commits yet**, the mandatory `after_specify` worktree hook (`speckit.worktrees.create`) cannot create the feature worktree and exits non-zero with a misleading message:

```
Error: git worktree add -b '001-portable-browser-sessions' at '.../.worktrees/001-portable-browser-sessions' from 'HEAD' failed.
Run 'git fetch' or use --in-place if worktrees are not available.
```

Expected: the hook either creates the worktree, or fails with a clear, actionable message about the missing commit. The spec itself is written successfully; only the post-spec worktree isolation step aborts.

## Reproduction

1. `git init` a fresh repository (or use a scaffolded package such as `zikzak_session` that has never been committed).
2. Run `/skill:speckit-specify` to produce a spec (registers `feature.json` and triggers the `after_specify` hook).
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

## Severity

high — blocks the mandated Specify → Worktree automation for every new Zuraffa package scaffolded with no commits; has a trivial local workaround (create an initial commit, or pass `--in-place`).

## Proposed Remediation

Add an explicit unborn-HEAD guard in `create-worktree.sh`. Before attempting `git worktree add`, detect the commit-less state with `git rev-parse --verify HEAD >/dev/null 2>&1`. If it fails, emit a precise, actionable error (e.g. "Repository has no commits yet; create an initial commit or pass --in-place before spawning a worktree") and exit non-zero, replacing the misleading "Run 'git fetch'" message. Optionally, the `after_specify` hook could skip worktree creation on commit-less repos with a clear notice so `/skill:speckit-specify` still completes cleanly for brand-new packages.

Refs: `Assessment: .specify/bugs/worktree-create-empty-repo/assessment.md`
