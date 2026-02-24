---
name: pr-comments
description: Retrieve pull request comments and produce a validated action plan.
argument-hint: [pr-number]
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(./scripts/fetch-pr-content.sh:*)
---

## Your Task

Fetch all comments from a pull request and produce a structured plan to address them. If the user provides a pull request number, use it. Otherwise, use the pull request associated with the current branch. It is your responsibility to not blindly fix every comment. You must validate each comment against the current source code before deciding on an action. Think before writing your final plan and ask follow-up questions if you need more information to make an informed decision.

## Arguments

```
${ARGUMENTS}
```

## Steps

1. Execute the following script to retrieve the pull request content: `./scripts/fetch-pr-content.sh <number>`
   - If the user did not provide a pull request number, run the script without arguments to fetch the pull request for the current branch.

2. For each comment:
   - Identify the type of comment (nitpick, suggestion, issue, todo, question, chore, etc.)
   - Locate and inspect the relevant code
   - Determine whether the comment is:
     - Valid and actionable
     - Partially valid
     - Invalid or based on incorrect assumptions
   - Provide clear reasoning for your assessment

3. Go into plan mode and create a structured plan to address the comments.

## Additional Resources

### Scripts

Tools in `./scripts/`:

- `fetch-pr-content.sh` - Fetches pull request content and comments
