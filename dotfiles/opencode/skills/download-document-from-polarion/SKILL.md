---
name: download-document-from-polarion
description: >-
  Download workitems from a Polarion document by running `python
  /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py` via the
  Bash tool. Workitems in Polarion can be of type heading, a type representing
  a requirements, or other types.
compatibility: opencode
metadata:
  domain: polarion
  output: yaml
  polarion:
    polarionBaseUrl: https://awspoldsdpu.polarion.comp.db.de/polarion
    token-env-var: POLARION_PAT
  instructions:
    - ensure Python package `click` is installed using `pip show click` or `pip
      install click`.
    - ensure Python package `polarion-rest-api-client` is installed using `pip
      show polarion-rest-api-client` or `pip install polarion-rest-api-client`.
    - for any execution request, MUST invoke the Python CLI through the Bash
      tool with `python
      /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py`
    - Before call the Python script read its help output that can be obtained
      with `python
      /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py
      --help` to understand the required and optional flags and their expected
      values.
    - construct the command safely by passing required flags `--project-id`,
      `--space-id`, and `--document-id`, using `AR_DKS` as the default project
      id unless the user overrides it
    - use `type:heading or status:approved` as the default `filter` value when
      the user does not provide one.
    - append optional flags only when values are provided, except `--filter`,
      which should use either the user-provided value or the default filter
    - when `personalAccessToken` is provided directly, pass it with
      `--personal-access-token` without revealing it in any response summary
    - if Bash or Python execution is unavailable or blocked, stop and report
      that exact issue instead of improvising
    - always use the fixed Polarion base URL from
      `metadata.polarion.polarionBaseUrl`
    - confirm whether `POLARION_PAT` is set, or use `personalAccessToken`
    - never reveal, print, echo, log, or otherwise expose a Polarion personal
      access token in any response, example, command explanation, tool call
      explanation, debug output, confirmation, or saved content
    - only refer to token sources by env var name or by saying a token was
      provided
    - never quote, repeat, or display a token value, even partially
    - if confirming auth configuration, say whether the env var is set, not
      what it contains
    - if the user supplies `personalAccessToken`, use it silently and redact it
      from any echoed summary
    - if reporting tool or runtime errors, paraphrase safely and avoid
      reproducing messages that might contain secret values
    - describe what you will do
---

# Skill: Download Polarion document as YAML

## What I do

- I always use Polarion base URL
  `https://awspoldsdpu.polarion.comp.db.de/polarion` and authenticate with
  `POLARION_PAT`
- I download work items from a Polarion document using
  `python /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py`
  through the Bash tool, return the YAML content, and can optionally save it to
  a file.
- Before I construct or run any Bash command for
  `python /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py`,
  I MUST ALWAYS use the `question` tool as a mandatory prerequisite to ask for
  or confirm whether to use the default project id `AR_DKS` or an override,
  plus the resolved `project-id`, `space-id`, and `document-id`, even when the
  user already supplied them.
- I use `type:heading or status:approved` as the default `filter` value unless
  the user provides a different filter.

## When to use me

Use this when you need to retrieve work items from a Polarion document as YAML

## Execution mechanism

- For any execution request, I MUST use the Bash tool to run
  `python /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py`.
- I MUST construct the command only from inputs that were asked for or
  confirmed through the `question` tool, passing required flags first and
  appending optional flags only when they are provided.
- I MUST not replace this script with manual REST calls or a different
  retrieval mechanism.
- I MUST use the `question` tool to ask questions to collect or confirm script
  input parameter values which are project id (default: `AR_DKS`) or an
  override, the `space-id`, and `document-id`, even when the user already
  supplied them.
- If the skill is loaded for an execution request, I MUST either run this
  Python CLI after collecting the required inputs, or stop and report that Bash
  or Python execution is unavailable or blocked.
- For every execution request, these `question` interactions are mandatory
  prerequisites for constructing the script command and for any Bash execution
  of it.
- For every execution request, I MUST ALWAYS use the `question` tool to ask
  whether to use the default project id `AR_DKS` or an override, then ask for
  or confirm the resolved `project-id`, `space-id`, and `document-id`, even
  when the user already supplied them.
- When I write a YAML file, I MUST add the following metadata as comments into
  the header:

  ```yaml
  # Base URL: ...
  # Timestamp: YYYY-MM-DD HH:MM:SS
  # Project ID: ...
  # Space ID: ...
  # Document ID: ...
  ```

## Prerequisites

- Python is available to the Bash tool.
- Script `/home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py`
  is available.
- `POLARION_PAT` is set, or `personalAccessToken` is provided.
- Valid Polarion IDs are provided for `space-id` and `document-id`, and for
  `project-id` when overriding the default `AR_DKS`.

## Polarion configuration

- Always use Polarion base URL
  `https://awspoldsdpu.polarion.comp.db.de/polarion`.
- Always use `POLARION_PAT` as the token environment variable name.
- Do not add a base URL flag or override. The Python script already uses the
  fixed base URL.

## Secret handling

- Never disclose, print, echo, log, or otherwise expose a Polarion personal
  access token.
- Never include a token value in any response, example, command explanation,
  Bash invocation explanation, debug output, confirmation, or saved content.
- Only refer to token sources by environment variable name `POLARION_PAT`, or
  by saying that a token was provided.
- Never quote, repeat, or display a token value, even partially.
- When confirming configuration, state whether the relevant environment
  variable is set. Never state what it contains.
- If the user supplies `personalAccessToken`, use it silently and redact it
  from any echoed summary.
- If a tool, service, or runtime error might contain a secret value, paraphrase
  the error safely instead of reproducing the original text.

## Inputs

Required for execution:

- I MUST ALWAYS use the `question` tool to ask for or confirm these required
  IDs before constructing the script command or running Bash, even when the
  user already supplied values.

- `project-id`, defaulting to `AR_DKS` unless the user overrides it
- `space-id`
- `document-id`

Optional authentication:

- `personalAccessToken` when `POLARION_PAT` is not available

Optional filters:

- `filter`, defaulting to `type:heading or status:approved`

Optional execution tuning:

- `pageSize`

Optional file save:

- `saveDirectory`
- `savePath`
- `ifExists` (`fail` or `overwrite`)

## Execution steps

1. Use the `question` tool to ask whether the user wants to use the default
   project id `AR_DKS` or override it. This is mandatory for every execution
   request, even when the user already supplied a project id.
2. Use the `question` tool to ask for or confirm the resolved `project-id`,
   `space-id`, and `document-id`. This is mandatory for every execution
   request, even when the user already supplied them.
3. Treat these `question` interactions as mandatory prerequisites for
   constructing the script command.
4. Do not construct the script command or run Bash until the required ID
   questions have been completed through the `question` tool.
5. Confirm that the fixed Polarion base URL is
   `https://awspoldsdpu.polarion.comp.db.de/polarion`.
6. Confirm authentication by environment variable name `POLARION_PAT`, or note
   that a token was provided directly. Never show the token value.
7. Ask whether output should only be returned, or also saved to a YAML file.
8. If save is requested, ask whether the user wants to provide a directory or a
   full file path.
9. If a directory is provided, use the default filename
   `<space-id>-<document-id>.YAML` in that directory.
10. If a full file path is provided, require it to end with `.yaml` or `.yml`.
11. If the target file exists, ask the user whether to overwrite or cancel.
12. Reject requests that provide both `saveDirectory` and `savePath`.
13. Resolve `project-id` to `AR_DKS`, or to the user-provided override.
14. Resolve `filter` to the user-provided value, or default it to
    `type:heading or status:approved`.
15. Build the Bash command as:

- `python /home/nerd/engine-room/dotfiles/opencode/tools/polariondoc2yaml.py`
- `--project-id <resolved project id>`
- `--space-id <space id>`
- `--document-id <document id>`
- `--filter <filter>` using the resolved filter value
- `--page-size <pageSize>` only when `pageSize` is provided
- `--personal-access-token <token>` only when a direct token override is
  required

16. Run the command through the Bash tool and capture stdout as the YAML
    result.
17. If save is requested, resolve the target path first, then save the captured
    YAML to that file without altering the YAML content.
18. Return the YAML output and a concise summary of the fixed base URL,
    resolved project-id, applied filter, and token source without exposing any
    token value.
19. When a file is saved, report the resolved saved file path without storing
    or repeating any token value.

When constructing the command, quote each argument safely and never omit
required flags. Do not include optional flags with empty values.

## Failure handling

Handle errors in this order:

1. Missing token:
   - Error mentions missing Polarion token.
   - Action: ask user to set `POLARION_PAT`, or pass `personalAccessToken`,
     then retry.
2. Missing dependency:
   - Error mentions `polarion-rest-api-client`.
   - Action: install dependency, then retry.
3. Python execution unavailable or blocked:
   - Bash cannot run `python`, or the script cannot be executed.
   - Action: stop and report the exact Python or permission issue.
4. Invalid project:
   - Error: `Project '<id>' does not exist.`
   - Action: use the `question` tool to confirm project id and retry.
5. Invalid document:
   - Error: `Document '<space-id>/<document-id>' not found.`
   - Action: use the `question` tool to confirm `space-id` and `document-id`,
     then retry.
6. Invalid save target:
   - Error mentions `saveDirectory`, `savePath`, missing parent directory, or
     unsupported extension.
   - Action: ask the user for an existing directory or a valid YAML file path,
     then retry.
7. Existing target file without decision:
   - Error asks for overwrite or cancel.
   - Action: ask user and rerun with `ifExists`.
8. Error output may include secrets:
   - Error text might contain token data.
   - Action: do not quote the raw error. Paraphrase the problem safely and
     retry only with secret-safe handling.

## Output contract

Return includes:

- `yaml`, taken from the Python script stdout
- `savedToPath` when the agent saves that YAML to a file

YAML list items include:

- `id`
- `outlineNumber`
- `title`
- `type`
- `status`
- `space`
- `document`
- `space` contains the requested `space-id`
- `document` contains the requested `document-id`
- `description`
- `description_plain`
- `rationale`
- `linkedWorkItems`
