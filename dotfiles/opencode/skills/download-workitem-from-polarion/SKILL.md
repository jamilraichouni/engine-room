---
name: download-workitem-from-polarion
description: >-
  Download one Polarion work item and its linked system test-case identities to
  a coverage-schema YAML file. Use when a project ID and work-item ID must be
  exported.
compatibility: >-
  OpenCode with curl, Python 3, a YAML parser, network access to Polarion, and
  POLARION_PAT_PU set.
metadata:
  domain: polarion
  output: <project_id>_<workitem_id>.yaml
---

# Download Polarion Work Item

## Common

Strictly follow the instructions in this document.

## Purpose

Create `<project_id>_<workitem_id>.yaml` for one Polarion work item. Default to
the current working directory when no output directory is clearly specified.
This skill is self-contained: apart from its companion OpenCode skills and
Polarion, it must not read data from locations outside the OpenCode
configuration directory.

Run `scripts/download_workitem.py` to perform the export. The script uses
authenticated, read-only `curl` requests and derives HTML-free requirement text
with inline work-item links resolved to their titles where possible.

## Inputs

Require non-empty `project_id` and `workitem_id`. Accept an optional existing
`output_directory`; otherwise use the current working directory. Do not
overwrite an existing output file without the user's explicit approval.

## Retrieval

Run:

```bash
python "/home/nerd/.config/opencode/skills/download-workitem-from-polarion/scripts/download_workitem.py" \
  "<project_id>" "<workitem_id>" "<output_directory>"
```

Pass `--overwrite` only after the user explicitly approves replacement of the
target file. The script rejects path separators in IDs, validates the derived
output path, retrieves every collection page, filters linked work items to
exact `systemtestcase` types, and retrieves a Cucumber attachment only when
exactly one readable non-empty candidate is found.

## Output Schema

Write exactly one YAML sequence item. Use these keys and order:

```yaml
- work item id: <workitem_id>
  requirement text: <description_plain>
  work item type: <workitem_type>
  project id: <project_id>
  linked test cases:
    - work item id: <linked_workitem_id>
      work item type: systemtestcase
      project id: <linked_project_id>
      cucumber test: |+
        <cucumber_test_content>
      description: <description_plain>
      suspect: <true_or_false>
```

Use YAML literal block scalars for all multiline values. Normalize CRLF and CR
line breaks to LF before serialization; never emit escaped `\r` or `\n` line
breaks. The exporter must force literal style even when multiline text contains
tabs or other characters that PyYAML would otherwise use to fall back to
double-quoted style, and must reject serialized output containing `\\n` or
`\\r`. For an empty linked-test-case set, write `linked test cases: []`. Do not
add `cucumber test`, `review result`, `description`, titles, raw API responses,
or other fields to the work item of interest. On linked system test cases,
write `cucumber test` when Polarion supplies it and always write the HTML-free
`description`, using a YAML literal block scalar whenever either value is
multiline. Always write `suspect` as a boolean, using the backlink's
`attributes.suspect` value when it is exactly boolean `true`, and `false`
otherwise.

The schema shown above is the complete output contract. Do not inspect or use
an external repository, template, or coverage YAML file to determine it.

The output file name is exactly `<project_id>_<workitem_id>.yaml`; retain the
IDs' original spelling in content and filename. Write it in `output_directory`.
The script uses a YAML writer, parses the written file with duplicate-key
rejection, and confirms it matches the exported data.

## Validation and Reporting

Before reporting success, confirm:

- the file contains exactly one top-level sequence item;
- the workitem ID, project ID, and type match Polarion;
- `requirement text` exactly equals the companion skill's `description_plain`
  and contains no HTML tags or `polarion-rte-link`;
- every linked entry has the documented identity keys and type
  `systemtestcase`, plus an HTML-free `description`, `cucumber test` (if any is
  present), and `suspect` as either boolean `true` or boolean `false`;
- every emitted Cucumber value exactly equals its documented Polarion source
  field after CRLF/CR-to-LF normalization, with line breaks preserved as YAML
  literal block-scalar line breaks; and
- all retrieved relationship pages were processed.

Always report the following parameters:

- absolute file output path
- linked system-test-case count (count using a YAML parser and
  `len(linked test cases)`), and
- count of suspect links (count them using a YAML parser)

Always report the full curl command used to retrieve Polarion data.

On retrieval, parsing, or validation failure, do not claim a successful export.
