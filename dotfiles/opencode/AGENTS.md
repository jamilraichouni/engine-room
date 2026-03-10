# Agent Development Guide

## Code style

### General guidelines

When writing code files, never write comments with one exception: Inline
comments to explain variables are allowed when the variable name cannot be
self-explanatory and have a meaningful name length.

Never write whole line comments or block comments!

Let files always end with a single newline character.

Wrap lines at 79 characters for the following types of files:

- Markdown files (`.md`)
- Python files (`.py`)
- ReStructuredText files (`.rst`)
- XML files (`.xml`)
- YAML files (`.yml`, `.yaml`)

### Python

Always strictly avoid blank lines except to fulfill PEP8 and PEP257
requirements.

## Documentation

When finding `README.md` and `CONTRIBUTING.md` in the same directory and
modifying file, ask me with a proposal to update the documentation if
necessary.

When asked to read the documentation for a Git repo, consider the files
`README.md` and `CONTRIBUTING.md` and also check for links to other
documentation sites. The subagent @explore shall visit these pages using the
web search tool and read the documentation there.
