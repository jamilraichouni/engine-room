---
name: download-document-from-polarion
description: >-
  Download workitems from a Polarion document by running `python
  $OPENCODE_CONFIG_DIR/tools/polariondoc2yaml.py` via the `bash` tool.
compatibility: opencode
metadata:
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
      tool with `python $OPENCODE_CONFIG_DIR/tools/polariondoc2yaml.py`
    - Before call the Python script read its help output that can be obtained
      with `python $OPENCODE_CONFIG_DIR/tools/polariondoc2yaml.py --help` to
      understand the required and optional flags and their expected values.
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
  tags:
    - bash
    - cli
    - document
    - filter
    - polarion
    - python
    - requirement
    - workitem
    - yaml
---

# Skill: Download Polarion document as YAML

## What I do and execution mechanism

- I MUST download a specified Polarion document from a specified Polarion
  server as YAML data using the Python CLI script `polariondoc2yaml.py` through
  the bash tool.
- I call `python $OPENCODE_CONFIG_DIR/tools/polariondoc2yaml.py --help` to
  understand the required and optional flags and their expected values
- I use the default value `https://awspoldsdpu.polarion.comp.db.de/polarion` as
  Polarion base URL (`--polarion-base-url`) and give the option to override it
  `POLARION_PAT`
- I use the default value stored in the env var `POLARION_PAT` as Polarion
  personal access token (`--personal-access-token`) and give the option to
  override it
- I use the default value `AR_DKS` as project id (`--project-id`) and give the
  option to override it
- I use the default value `type:heading or status:approved` as filter for work
  items (`--filter`) and give the option to override it
- I MUST ALWAYS use the tool `question` to ask for inputs after I have read the
  `--help`
- If the `question` tool is unavailable in the runtime tool list, I MUST NOT
  ask plain-text follow-up questions and MUST return a `needs_user_input` block
  for the parent assistant instead
- I MUST not replace calling the script with manual REST calls or a different
  retrieval mechanism like `curl` etc..

## When to use me

Use this when you need to retrieve work items from a Polarion document as YAML.

## Prerequisites

- Python is available to the bash tool.
- The Python packages `click` and `polarion-rest-api-client` are installed and
  available to the Python environment used by the bash tool.
- Script `$OPENCODE_CONFIG_DIR/tools/polariondoc2yaml.py` is available.
- `POLARION_PAT` is set, or `--personal-access-token` is provided.
- Valid Polarion IDs are provided for all inputs

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
- If the `question` tool is unavailable, I MUST stop before Bash execution and
  return a `needs_user_input` block with the missing or confirmable inputs.

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
5. If `question` is unavailable, return a `needs_user_input` block and stop. Do
   not emit multiple plain-text questions.
6. Confirm that the fixed Polarion base URL is
   `https://awspoldsdpu.polarion.comp.db.de/polarion`.
7. Confirm authentication by environment variable name `POLARION_PAT`, or note
   that a token was provided directly. Never show the token value.
8. Ask whether output should only be returned, or also saved to a YAML file.
9. If save is requested, ask whether the user wants to provide a directory or a
   full file path.
10. If a directory is provided, use the default filename
    `<space-id>-<document-id>.YAML` in that directory.
11. If a full file path is provided, require it to end with `.yaml` or `.yml`.
12. If the target file exists, ask the user whether to overwrite or cancel.
13. Reject requests that provide both `saveDirectory` and `savePath`.
14. Resolve `project-id` to `AR_DKS`, or to the user-provided override.
15. Resolve `filter` to the user-provided value, or default it to
    `type:heading or status:approved`.
16. Build the Bash command as:

- `python $OPENCODE_CONFIG_DIR/tools/polariondoc2yaml.py`
- `--project-id <resolved project id>`
- `--space-id <space id>`
- `--document-id <document id>`
- `--filter <filter>` using the resolved filter value
- `--page-size <pageSize>` only when `pageSize` is provided
- `--personal-access-token <token>` only when a direct token override is
  required

17. Run the command through the Bash tool and capture stdout as the YAML
    result.
18. If save is requested, resolve the target path first, then save the captured
    YAML to that file with the required metadata comment header.
19. After saving, validate the saved file by checking that its first lines
    begin with `# Base URL:`, `# Timestamp:`, `# Project ID:`, `# Space ID:`,
    and `# Document ID:`.
20. If the validation fails, stop and report that the saved file is missing the
    required metadata header.
21. Return the YAML output and a concise summary of the fixed base URL,
    resolved project-id, applied filter, and token source without exposing any
    token value.
22. When a file is saved, report the resolved saved file path without storing
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
8. Saved file metadata header missing or invalid:
   - Validation shows the saved file does not start with the required metadata
     comment lines.
   - Action: stop and report that the file-save path did not preserve the
     required metadata header.
9. Error output may include secrets:
   - Error text might contain token data.
   - Action: do not quote the raw error. Paraphrase the problem safely and
     retry only with secret-safe handling.

## Output contract

Return includes:

- `yaml`, taken from the Python script stdout
- `savedToPath` when the agent saves that YAML to a file

When `question` is unavailable and input is missing, return:

```text
needs_user_input:
  fields:
    - name: project-id
      default: AR_DKS
    - name: space-id
    - name: document-id
    - name: filter
      default: type:heading or status:approved
    - name: pageSize
    - name: saveMode
    - name: authentication
  message: Use the `question` tool in the parent assistant and retry me with
    the answers.
```

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
