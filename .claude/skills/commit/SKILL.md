---
name: commit
description: Commit open changes, grouping logical changes together and matching the repository's existing commit style (defaulting to conventional commits for new repos).
argument-hint: [<filter>]
disable-model-invocation: false
user-invocable: true
allowed-tools: Bash(git add:*), Bash(git branch:*), Bash(git checkout:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git status:*)
---

## Your Task

Commit the open changes in the working tree, grouping them into logical commits. Match the repository's existing commit style. For repos with no history yet, default to conventional commits. If the user passes an argument (e.g. "only the readme", "just the scripts folder"), narrow the commit scope to match and leave everything else untouched.

## Arguments

```
${ARGUMENTS}
```

## Context

**Branch:** !`git branch --show-current`

**Diff:**

```
!`git diff HEAD`
```

**Status:**

```
!`git status --short`
```

## Steps

1. Review the context above. If nothing has changed, tell the user and stop.

2. If the user passed an argument, resolve which files match it and commit only those. Leave everything else untouched.

3. Detect the repo's commit style, in this order of precedence:
   - If the user explicitly asked for a specific style in the arguments, use it.
   - If `AGENTS.md` or `CLAUDE.md` (root or nested) documents a commit convention, follow it.
   - Otherwise run `git log --oneline -20` and match the existing style.
   - If there are no commits yet, default to conventional commits.

4. If the branch shown in the context is `main` or `master`, ask whether to create a new branch first. If yes:
   - Infer a name from the changes. Use conventional-commit prefixes plus a short kebab-case description (e.g. `feat/add-mfa-support`).
   - Confirm the name with the user.
   - Run `git checkout -b <branch>`.

5. Group the in-scope changes into logical commits.
   - Prefer more, smaller commits. Group files by concern (dependencies, source, tests, deployment, tooling).
   - One purpose per commit. If you need `and` to describe it, split it.
   - Intermediate commits don't need to leave the repo in a working state.
   - Unrelated changes split apart even within the same file.
   - Do not stash or reorder.
   - Stage only the files that belong to each commit.

6. Stage and commit each group:
   - Stage files explicitly by path, never `git add -A` or `git add .`.
   - Write a single-line message:
     - Fully lowercase.
     - No trailing period.
     - ~72 chars max.
     - No body.
     - Describe what changed, not why.
   - Do not amend, do not skip hooks, do not alter git config. If a hook fails, fix the cause and create a new commit.

7. After all commits, run `git status` and `git log --oneline -<n>` (where `n` is the number of commits made) and report the result back to the user.

## Additional Resources

### Conventional Commits

#### Types

- `feat`: new feature.
- `fix`: bug fix.
- `refactor`: code change, no behavior change
- `perf`: performance improvement
- `docs`: documentation only
- `style`: formatting, no logic change
- `test`: tests added/updated
- `build`: build system/deps
- `ci`: ci/cd config
- `chore`: maintenance
- `revert`: revert commit

#### Scope (optional)

- Area affected. Keep short and consistent
- Examples: `api`, `ui`, `auth`, `db`

#### Breaking (optional)

- Add ! after type/scope

#### Subject

- Imperative, concise, no period
- ~72 chars max
