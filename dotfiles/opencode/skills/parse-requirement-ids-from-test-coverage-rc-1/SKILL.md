---
name: parse-requirement-ids-from-test-coverage-rc-1
description: >-
  Extract requirement IDs from the two RC-1 test-coverage tables in the
  Polarion page "Requirement Testcoverage RC-1". Use only when the page is
  requested with project AR_DKS and space KPI, and preserve table order.
compatibility: opencode
metadata:
  domain: polarion
  category: requirement
  sourceSkill: access-polarion-via-rest-api
  projectId: AR_DKS
  spaceId: KPI
  pageName: Requirement Testcoverage RC-1
  output: ordered-requirement-id-list
---

# Parse RC-1 Requirement IDs

## Purpose

Retrieve the live Polarion rich page through the
`access-polarion-via-rest-api` skill and return the requirement IDs shown in
the first column of the two test-coverage tables, in page order.

## Preconditions

- `POLARION_PAT_PU` is set and must never be printed or persisted.
- `curl` and a JSON parser such as `jq` are available.
- The API definition at `metadata.polarion.openApiSpec` is available when
  endpoint details or response fields need confirmation.

## Retrieval

Use the REST API endpoint documented by `access-polarion-via-rest-api`:

```bash
curl --fail-with-body --silent --show-error \
  --header "Accept: application/json" \
  --header "Authorization: Bearer ${POLARION_PAT_PU}" \
  "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/projects/AR_DKS/spaces/KPI/pages/Requirement%20Testcoverage%20RC-1?fields%5Bpages%5D=%40all"
```

Read the page body from
`.data.attributes.homePageContent.value`. Verify that
`.data.attributes.homePageContent.type` is `text/html`. The REST page response
contains the rich-page source and widget configuration. Extract the two
`multilevel_trace_widget` parameter blocks from this source. Do not treat IDs
found in a query string or page configuration as table rows.

## Extraction

The page body contains two `multilevel_trace_widget` widgets. Their headings
and order are:

1. `Interface Documents for RC1`.
2. `6.3 System Function "Provide JP & SP" (Scope RC1)`.

For each widget, read `workItems.subtype`, `workItems.luceneQuery`,
`firstColumn.fields`, and `firstColumn.tableColumnFields`. Use the exact
`luceneQuery` as the `query` parameter of the documented
`GET /projects/{projectId}/workitems` endpoint. Do not use the browser UI URL,
the page's `fit` parameter, or a manually simplified query.

Request all fields needed by the first-column configuration, at minimum
`id`, `type`, `outlineNumber`, `title`, and `project`. Follow every
`links.next` URL until pagination ends. Never assume the first page is
complete.

The first-column table order is the work-item document order. Request
`sort=outlineNumber` when the endpoint supports it. If the API rejects that
sort or returns no reliable ordering, sort locally by the numeric components
of `attributes.outlineNumber`, using the work-item ID as a deterministic
tie-breaker. Do not use API response order as an implicit sort.

Treat a returned item as a requirement only when its `type` is one of the
requirement types declared by the widget (`systemreq`, `systemreqWB`, or
`glossary`, as applicable) and it is represented by the widget's first-column
work-item set. Exclude linked test cases and any other item types. Extract the
work-item `id`, not an ID embedded in a title, description, or query.

Return the first widget's IDs followed by the second widget's IDs. Do not
deduplicate between widgets: the same requirement rendered in two distinct
tables is two list entries.

Do not extract IDs from:

- the page UI, navigation, parameters, or embedded Lucene queries;
- the test-case columns or linked-work-item columns;
- headings, comments, attachments, or unrelated widgets;
- duplicate rendering of the same first-column row within a widget.

Use the API resource's `id` and `attributes` fields. A query result is not
enough to identify a first-column requirement if its type or configured fields
cannot be established. Report that limitation instead of guessing.

## Validation

Validate that exactly two widgets are found, in the expected heading order,
and that each has a first-column definition and a work-item query. Validate
that every returned ID has a matching requirement type and project, and that
the output order follows the widget's outline-number order. If the REST page,
widget headings, query, first-column definition, required fields, pagination,
or ordering evidence is missing, stop and report the specific failure. Never
fall back to a local or downloaded HTML file.

## Output

Return the ordered IDs as a plain list, preserving duplicates if the same
requirement belongs to both widget result sets. Also report the HTTP methods
and resource paths, HTTP statuses, pagination performed, authentication status
using only the variable name `POLARION_PAT_PU`, and any validation limitation.
Never include the token or the complete page body in the output.
