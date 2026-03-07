---
name: download-document-from-polarion-db-prod
description: Download a Polarion LiveDoc from DB production Polarion, return
  YAML, and optionally store it as a YAML file.
compatibility: opencode
metadata:
  domain: polarion
  environment: db-prod
  output: yaml
  auth-env: POLARION_PAT
---

## What I do

I download work items from a Polarion LiveDoc using `polariondoc2yaml`, return
the YAML content, and can optionally save it to a file.

## Required endpoint

Always set `polarionEndpointUrl` to the DB production endpoint:

`https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1`

## Prerequisites

- Tool `polariondoc2yaml` is available.
- Environment variable `POLARION_PAT` is set.
- Valid Polarion identifiers are provided for `project`, `space`, and
  `document`.

## Inputs

Required for execution:

- `polarionEndpointUrl` (always set by this skill)
- `project`
- `space`
- `document`

Optional filters:

- `wiType`
- `wiStatus`
- `query`

Optional execution tuning:

- `pageSize`
- `resolveLinks`

Optional file save:

- `saveToPath`
- `ifExists` (`fail` or `overwrite`)

## Execution steps

1. Confirm `project`, `space`, and `document` with the user.
2. Ask whether output should only be returned, or also saved to a YAML file.
3. If save is requested, ask for the destination file path.
4. If the target file exists, ask the user whether to overwrite or cancel.
5. Call `polariondoc2yaml` with:
   - `polarionEndpointUrl` set to the DB production endpoint.
   - collected query and filter arguments.
   - optional save arguments when requested.
6. Return the YAML output and a concise summary of applied filters.

## Failure handling

Handle errors in this order:

1. Missing token:
   - Error: `Set POLARION_PAT environment variable.`
   - Action: ask user to set/export `POLARION_PAT`, then retry.
2. Missing dependency:
   - Error mentions `polarion-rest-api-client`.
   - Action: install dependency, then retry.
3. Invalid project:
   - Error: `Project '<id>' does not exist.`
   - Action: confirm project id and retry.
4. Invalid document:
   - Error: `Document '<space>/<document>' not found.`
   - Action: confirm `space` and `document`, then retry.
5. Existing target file without decision:
   - Error asks for overwrite or cancel.
   - Action: ask user and rerun with `ifExists`.

## Output contract

YAML list items include:

- `id`
- `outlineNumber`
- `title`
- `type`
- `status`
- `space`
- `document`
- `description`
- `description_plain`
- `rationale`
- `linkedWorkItems`
