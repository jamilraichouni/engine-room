# Agent Development Guide

## Asking questions

ALWAYS, really ALWAYS use the tool `question` to ask questions, when you have
more than one single question to ask.

## Writing tools

When writing tools, always write them in Python 3 or Shellscript (Bash, POSIX
sh).

## Engineering Collaboration Tools and access tokens

### GitLab

URL: https://git.tech.rz.db.de/

Name of environment variable for personal access token: `GITLAB_READ_PAT`

### Polarion

URL: https://awspoldsdpu.polarion.comp.db.de/polarion

Name of environment variable for personal access token: `POLARION_PAT_PU`

### Artifactory

#### Docker registries

- `docker://ato-c-docker-stage-local.bahnhub.tech.rz.db.de`
- `docker://ato-c-docker-release-local.bahnhub.tech.rz.db.de`

Name of environment variable for personal access token: `ARTIFACTORY_PAT`

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
