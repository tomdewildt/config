#!/usr/bin/env python3
import argparse
import json
import shlex
import sys
from collections import Counter
from pathlib import Path

DEFAULT_PATH = str(Path.home() / ".claude" / "projects")


def _is_command(block: dict) -> bool:
    return (
        isinstance(block, dict)
        and block.get("type") == "tool_use"
        and block.get("name") == "Bash"
    )


def _split_command(command: str) -> list[str]:
    try:
        lexer = shlex.shlex(command, posix=True)
        lexer.whitespace += ";\n"
        lexer.whitespace_split = True
        tokens = list(lexer)
    except ValueError:
        return [command]

    commands = []
    pending_tokens: list[str] = []
    for token in tokens:
        if token in ("&&", "||", "|", "&"):
            if pending_tokens:
                commands.append(" ".join(pending_tokens))
                pending_tokens = []
        else:
            pending_tokens.append(token)

    # Add any remaining tokens as a command
    if pending_tokens:
        commands.append(" ".join(pending_tokens))

    return [cmd for cmd in commands if cmd]


def extract_commands(file_path: Path) -> list[str]:
    commands = []

    with open(file_path) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            # Skip user messages
            if obj.get("type") != "assistant":
                continue

            # Extract commands from blocks
            for block in obj.get("message", {}).get("content", []):
                if _is_command(block):
                    command = block.get("input", {}).get("command")
                    if command:
                        commands.extend(_split_command(command))

    return commands


def strip_commands(commands: list[str]) -> list[str]:
    stripped = []

    for command in commands:
        try:
            tokens = shlex.split(command)
        except ValueError:
            tokens = command.split()

        for token in tokens:
            if "=" not in token or token.startswith("="):
                stripped.append(token)
                break

    return stripped


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Find frequently used commands by Claude Code."
    )
    parser.add_argument(
        "-p",
        "--path",
        default=DEFAULT_PATH,
        help=f"Path to the projects folder (default: {DEFAULT_PATH})",
    )
    args = parser.parse_args()

    # Validate arguments
    path = Path(args.path)
    if not path.exists():
        sys.exit(f'"{path}" does not exist')

    # Find '.jsonl' files
    files = list(path.rglob("*.jsonl"))
    if not files:
        sys.exit(f'no ".jsonl" files found in "{path}"')

    # Extract commands from files
    all_commands = []
    for jsonl_file in files:
        all_commands.extend(extract_commands(jsonl_file))

    # Strip arguments from commands
    stripped_commands = strip_commands(all_commands)

    # Count command frequencies
    frequencies = Counter(stripped_commands)

    # Sort commands by frequency (descending) and alphabetically
    sorted_commands = sorted(frequencies.items(), key=lambda item: (-item[1], item[0]))

    # Output results
    result = {cmd: count for cmd, count in sorted_commands}
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
