---
name: find-frequently-used-commands
description: Find frequently used commands and suggest permission changes.
argument-hint: [command]
disable-model-invocation: true
user-invocable: true
allowed-tools: Bash(./scripts/find-frequent-commands.py *), Bash(./scripts/find-full-commands.py *)
---

## Your Task

Analyze frequently used Bash commands from Claude Code conversation history and suggest permission changes for `~/.claude/settings.json`. If no argument is provided, find all frequently used commands and suggest which ones should be added to the allow list. If a specific command name is provided as an argument, find all full invocations of that command and suggest a permission rule for it.

## Arguments

```
${ARGUMENTS}
```

## Steps

### When no argument is provided

1. Run `./scripts/find-frequent-commands.py` to retrieve command frequencies across all projects.

2. Read `~/.claude/settings.json` to get the current permission rules (the `permissions.allow`, `permissions.deny`, and `permissions.ask` arrays).

3. Output the command frequency results as a ranked list showing each command and its count.

4. Compare the frequent commands against the current permissions and suggest changes:
   - Identify commands that are used frequently but not yet in the `allow` list — suggest adding them as `Bash(command *)`.
   - Identify commands that are in the `allow` list but never or rarely used — flag them as candidates for removal.
   - Do NOT suggest adding commands that are already in the `allow`, `deny`, or `ask` lists.
   - Do NOT suggest allowing commands that could be destructive (e.g., `rm`, `chmod`, `chown`, `sudo`).

5. Present the suggestions as a clear list of recommended additions and removals with rationale.

### When a command argument is provided

1. Run `./scripts/find-full-commands.py <command>` to retrieve all full invocations of the given command.

2. Read `~/.claude/settings.json` to get the current permission rules.

3. Output the list of full command invocations found for the given command.

4. Analyze the invocations and suggest permission changes:
   - If the command is not in any permission list, suggest adding it as `Bash(command *)` to the `allow` list.
   - If the command is already allowed, confirm that and note whether the current rule covers all observed invocations.
   - If certain subcommands or flags appear dangerous, suggest putting those specific patterns in the `ask` or `deny` list instead (e.g., `Bash(git push --force *)` in `ask`).

5. Present the suggestions with examples from the actual invocations to justify the recommendation.

## Additional Resources

### Docs

- [Claude Code Permissions Documentation](https://code.claude.com/docs/en/permissions) - Reference for how permissions work in Claude Code and best practices for configuring them.

### Scripts

Tools in `./scripts/`:

- `find-frequent-commands.py` - Finds frequently used commands across all projects. Outputs a JSON object mapping command names to their frequency counts.
- `find-full-commands.py <command>` - Finds all full command invocations matching a given command name. Outputs a JSON array of full command strings.
