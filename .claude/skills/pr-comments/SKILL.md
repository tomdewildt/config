---
name: pr-comments
description: Retrieve pull request comments and produce a validated action plan.
argument-hint: <pr-number>
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

1. Execute the following script to retrieve the pull request content: `${CLAUDE_SKILL_DIR}/scripts/fetch-pr-content.sh <number>`
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

4. For each comment worth a reply, draft a suggested response in the reply style below and present it in the chat. Do NOT post it. Only post replies to the PR/MR if the user explicitly asks you to ("push the comments", "post the replies"); otherwise the drafts are for the user to send.

## Additional Resources

### Reply Style

- Be short.
  - If you simply fixed something say the thing and stop.
  - If a comment is wrong use 1 to 2 sentences.
- Lead with technical substance:
  - If a comment is wrong or incomplete, say why plainly.
- Sound natural, no engineering jargon:
  - If a reviewer might have to look a word up, use plain words instead.
  - Do not polish your reply too much.
- Avoid bot-like phrasing:
  - No marketing tone.
  - No em-dashes
  - Don't restate the reviewer's comment before answering.
- Reference code plainly:
  - Mention files, functions, and symbols bare.
  - No backticks unless they're actually useful.

Examples:

> Only ever counts up here since it's incremented in order, so it can't go backwards.

> Changed it!

> Fixed!

### Scripts

Tools in `${CLAUDE_SKILL_DIR}/scripts/`:

- `fetch-pr-content.sh` - Fetches pull request content and comments
