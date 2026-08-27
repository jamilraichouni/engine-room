# Agent Development Guide

## Do not modify any file using Git

When executing the shell command `git` YOU MUST NOT call a sub-command like
`git commit` or `git push` that modifies the Git history - let me know what you
want to do instead.

When something is unclear, DO NOT ASSUME something - use the tool `question` to
ask instead.

## Python libraries to use

When reading or writing a YAML file, you MUST use the Python library `pyyaml`
to access the file. When reading or writing a YAML file, you MUST check if the
`pyyaml` library is available. When the `pyyaml` library is not available, stop
and ask the user to install it.

When you want to inspect or read `.pdf` files, you MAY use the shell command
`pdfinfo` or the Python package `pdftotext`.

## Writing tools

When writing tools, you MUST implement them in Python 3 and report in the chat
why you created the tool and where (absolute file path) it is stored.

## Engineering Collaboration Tools and access tokens

### GitLab

When accessing the URL <https://git.tech.rz.db.de/> you MUST use the personal
access token stored in the environment variable `GITLAB_READ_PAT` to
authenticate.

### Polarion

When accessing the URL: <https://awspoldsdpu.polarion.comp.db.de/polarion> you
MUST use the personal access token stored in the environment variable
`POLARION_PAT_PU` to authenticate.

### Artifactory

#### Docker registries

When accessing the Docker registries
`docker://ato-c-docker-stage-local.bahnhub.tech.rz.db.de` or
`docker://ato-c-docker-release-local.bahnhub.tech.rz.db.de` you MUST use the
personal access token stored in the environment variable `ARTIFACTORY_PAT` to
authenticate.

## Code style

### General guidelines

When writing code files, YOU MUST NOT write comments with one exception: Inline
When there is a variable name that is not self-explanatory or would need to
have a name length that exceeds 30 characters, you MAY write an inline comment
to explain the variable.

You MUST NOT write whole line comments or block comments - ensure that code is
self-explanatory and readable instead.

When writing or modifying a file, you MUST always end the file with one single
newline character and use a `\n` or `\r\n` depending on the type of the other
line endings in the file. When the other line endings in the file are mixed,
you MUST tell me that and ask me what line endings to use.

When writing into the following types of files, you MUST wrap lines at 79
characters:

- HTML files (`.html`)
- JavaScript files (`.js`)
- Markdown files (`.md`)
- Python files (`.py`)
- ReStructuredText files (`.rst`)
- Shell scripts (`.sh`, `.zsh`)
- XML files (`.xml`)
- YAML files (`.yml`, `.yaml`)

### Python

When writing `.py` files blank lines MUST be avoided when the empty lines are
not needed to fulfil PEP 8 and PEP 257 requirements.
