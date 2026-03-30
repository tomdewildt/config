---
name: pr-pipeline
description: Retrieve ci/cd pipeline status and logs for a pull request and produce a plan to fix failures.
argument-hint: <pr-number>
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(./scripts/fetch-pr-pipeline.sh:*)
---

## Your Task

Fetch the ci/cd pipeline status for a pull request, diagnose any failures, and produce a structured plan to fix them. If the user provides a pull request number, use it. Otherwise, use the pull request associated with the current branch. It is your responsibility to thoroughly investigate each failure before proposing a fix. Think before writing your final plan and ask follow-up questions if you need more information to make an informed decision.

## Arguments

```
${ARGUMENTS}
```

## Steps

1. Execute the overview script to retrieve pipeline status: `${CLAUDE_SKILL_DIR}/scripts/fetch-pr-pipeline.sh <number>`
   - If the user did not provide a pull request number, run the script without arguments to fetch the pipeline for the current branch.

2. If there are failed jobs, fetch logs for each one:
   - Run `${CLAUDE_SKILL_DIR}/scripts/fetch-pr-pipeline.sh --logs <job-id>` to get the last 200 lines.
   - The response includes a `before` field. To scroll backwards, pass it as `--before <before>` to get the previous page.
   - Use `--limit N` to control page size (default: 200).
   - Identify the root cause of each failure from the log output.

3. For each failure:
   - Identify the type (build error, test failure, lint error, type check, security scan, etc.)
   - Locate and inspect the relevant source code in the repository
   - Determine the root cause and whether it is:
     - A code issue that needs fixing
     - A flaky test or infrastructure issue
     - A configuration problem
   - Provide clear reasoning for your assessment

4. Go into plan mode and create a structured plan to fix the failures.

## Additional Resources

### Scripts

Tools in `${CLAUDE_SKILL_DIR}/scripts/`:

- `fetch-pr-pipeline.sh` - Fetches pipeline status and job logs
  - `fetch-pr-pipeline.sh <number>` - Overview of all workflow runs/pipelines and their jobs
  - `fetch-pr-pipeline.sh --logs <job-id>` - Fetch last 200 lines of logs for a job
  - `fetch-pr-pipeline.sh --logs <job-id> --before N` - Fetch 200 lines before line N
  - `fetch-pr-pipeline.sh --logs <job-id> --before N --limit 50` - Fetch 50 lines before line N
