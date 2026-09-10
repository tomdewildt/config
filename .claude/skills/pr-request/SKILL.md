---
name: pr-request
description: Open a pull request (GitHub) or merge request (GitLab) for the current branch, inferring title and body from the changes.
argument-hint: [<issue-number>] [<commit-filter>]
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(git branch:*), Bash(git diff:*), Bash(gh pr:*), Bash(git push:*), Bash(git remote:*), Bash(git rev-parse:*), Bash(git status:*), Bash(glab mr:*), Bash(git log:*)
disallowed-tools: Bash(git add:*), Bash(git commit:*), Bash(git stash:*)
---

## Your Task

Open a pull request on GitHub or a merge request on GitLab for the current branch. First commit any pending changes by invoking the `/commit` skill, then push the branch and create the PR/MR using the project's template. Infer the title and body from the actual commits and diff. Do not just echo the branch name. Ask follow-up questions if the change type or template is ambiguous.

## Arguments

```
${ARGUMENTS}
```

## Context

**Base:** !`git rev-parse --abbrev-ref origin/HEAD`

**Branch:** !`git branch --show-current`

**Remote:** !`git remote get-url origin`

**Status:**

```
!`git status --short`
```

**Commits since base:**

```
!`git log --oneline origin/HEAD..HEAD`
```

**Changed files:**

```
!`git diff --stat origin/HEAD...HEAD`
```

## Steps

1. Review the context above. If the status shows uncommitted changes, invoke the `commit` skill to handle them, passing any commit-filter argument through so the user's narrowing instruction is respected.
   - That skill also offers to create a branch when the user is on `main`/`master`.
   - After it returns, re-read `git branch --show-current` and `git log --oneline origin/HEAD..HEAD` — the context above was captured before the commit ran and is now stale.
   - If there are still no commits on the branch after that, stop there is nothing to PR.

2. Detect the platform from the remote shown in the context:
   - `github.com` → use `gh`.
   - `gitlab.com` or `gitlab.*` → use `glab`.
   - Stop if neither matches.

3. Resolve the issue number: use the argument if given, otherwise ask the user.

4. Identify the dominant change type from the commits and changed files in the context. Read the full `git diff origin/HEAD...HEAD` if you need more detail to write the body.

5. Write the title to match how the commits on the branch look:
   - Keep it under 72 characters with no trailing period.
   - If the branch mixes change types, pick the one that best summarises it.

6. Read the template:
   - GitHub: `.github/PULL_REQUEST_TEMPLATE.md`. If missing, use a minimal default with the same sections.
   - GitLab: list `.gitlab/merge_request_templates/*.md`, read each, pick the one that fits the change type. Fall back to `default.md` or the only available template.

7. Fill the template from the commits and diff:
   - Tick any checkboxes that match the change type(s). Multiple may apply.
   - Fill prose sections (what/why, summary, description, etc.) with a one-sentence summary followed by one bullet per logical change, grounded in the actual changes. 
   - Write like a colleague summarising the change, not generated docs:
     - Say what and why. The diff already shows how.
     - One clause per bullet, ~15 words. No parenthetical lists of settings or attributes.
     - Name the effect, not the machinery. No packages, classes, or files unless the bullet is meaningless without them.
     - Backticks are rare: at most one per bullet, only for an env var, config key, or flag the reader will grep.
     - Reviewer notes only hold what changes the review: a gating flag, a migration, a deploy order. Cut known limitations.
     - Never reference the coding session: plan files, phases, steps, or task names exist only in this conversation, not in the diff, and mean nothing to the reviewer.
   - Insert the issue reference: `Fixes #<n>` for GitHub or `Closes #<n>` for GitLab (both auto-close on merge). Leave empty if the user said "none".
   - Leave optional or context sections blank unless reviewers genuinely need the info (migrations, deploy order, feature flags, user-visible impact).

8. Push the branch:
   - No upstream: `git push -u origin <branch>`.
   - Has upstream: `git push`.
   - Never force-push unless the user explicitly asks.

9. Create the PR/MR:
   - GitHub: `gh pr create --title "<title>" --body "..."`.
   - GitLab: `glab mr create --title "<title>" --description "..." --target-branch <base>`.

10. Report the PR/MR URL back to the user.
