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
