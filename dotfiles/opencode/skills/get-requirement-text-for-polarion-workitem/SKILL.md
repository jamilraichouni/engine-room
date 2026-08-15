---
name: get-requirement-text-for-polarion-workitem
description: >-
  Retrieve the requirement text of one Polarion work item with authenticated,
  read-only curl requests. Use when a user provides a Polarion project ID and
  work-item ID and asks for its requirement text, description, rationale, or
  plain-text content.
compatibility: opencode
metadata:
  domain: polarion
  category: requirement
  output: requirement-text
  polarion:
    baseUrl: https://awspoldsdpu.polarion.comp.db.de/polarion
    restApiEndpoint: >-
      https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1
    accessTokenEnvVar: POLARION_PAT_PU
  tags:
    - curl
    - polarion
    - requirement
    - rest-api
    - workitem
---

# Get Polarion Requirement Text

## Purpose

Retrieve one Polarion work item and return its requirement text without using
`polariondoc2yaml.py`, the Polarion web UI, or a downloaded document. Python
may be used for local HTML parsing and text conversion; every network request
must still use `curl`.
Use the REST API with `curl` for every network request. The companion tool
`tools/polariondoc2yaml.py` establishes the required interpretation:

- `description` is the raw rich-text HTML value.
- `description_plain` is the HTML-free, entity-decoded, whitespace-collapsed
  form of `description`.
- `rationale` is another text-content field and may also contain rich HTML.
- Inline work-item and document links in rich text are resolved to titles when
  possible and otherwise retain their raw ID or document name.

## Preconditions

- `POLARION_PAT_PU` is set to a valid Polarion personal access token.
- `curl` is available to the Bash tool.
- A Polarion project ID and work-item ID are known.
- `jq` may be used to inspect or project JSON, but it is not a retrieval
  mechanism. All Polarion data must be obtained with `curl`.
- Never print, save, echo, log, or expose the token, including partial values.

## Inputs

Collect or confirm these values before making a request:

- `projectId`: the Polarion project ID, such as `AR_DKS`.
- `workItemId`: the work-item ID, such as `AR-123`.
- `includeMetadata`: whether to return title, type, status, outline number,
  rationale, and linked work-item metadata in addition to the text.
- `resolveLinks`: whether inline rich-text links should be resolved to titles.
  Use `true` by default when the description contains Polarion RTE links.

Do not ask for a document space or document ID. This skill addresses a single
work item directly.

## Authentication And Base URL

Use only this REST API base URL:

`https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1`

Before requesting data, verify that `POLARION_PAT_PU` is set without revealing
its value. If it is unset, stop and ask the user to configure it. Never put a
token in a URL, command argument, file, or response.

Use these headers on every request:

```bash
--header "Accept: application/json" \
--header "Authorization: Bearer ${POLARION_PAT_PU}"
```

Use `--fail-with-body --silent --show-error`. Do not use `--verbose`, because
verbose output can expose authorization headers.

## Execution Steps

1. Validate that `projectId` and `workItemId` are non-empty. Treat them as
   path segments and URL-encode each one before constructing a URL. Do not
   interpolate untrusted IDs into an unquoted URL.

2. If endpoint fields or response structure are unclear, retrieve the live
   OpenAPI definition with `curl` first:

   ```bash
   curl --fail-with-body --silent --show-error \
     --header "Accept: application/json" \
     --header "Authorization: Bearer ${POLARION_PAT_PU}" \
     "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/definition"
   ```

3. Retrieve the work item using a read-only GET. Request all fields needed for
   the result, including the rich description and rationale. Prefer the
   documented `@all` field selection when supported:

   ```bash
   curl --fail-with-body --silent --show-error \
     --header "Accept: application/json" \
     --header "Authorization: Bearer ${POLARION_PAT_PU}" \
     "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/projects/<projectId>/workitems/<workItemId>?fields%5Bworkitems%5D=%40all"
   ```

   If `@all` is not accepted, repeat the GET with an explicitly documented
   field list containing at least `id,title,description,type,status,
   outlineNumber,rationale,linkedWorkItems`.

4. Check the HTTP result before parsing JSON. Confirm that the response has one
   `.data` resource and that its resource ID matches `workItemId`. Do not treat
   an error body or an empty response as requirement text.

5. Read the work-item attributes. The relevant values are normally under
   `.data.attributes`:

   - `description.value` is the raw HTML requirement description.
   - `description.type` identifies the content representation.
   - `rationale.value` is the rationale text when present.
   - `title`, `type`, `status`, and `outlineNumber` provide metadata.

   Accept a plain string in place of a `{type,value}` text-content object. Use
   an empty string for a missing or null description, and distinguish missing
   text from an API failure.

6. Produce `description_plain` from the raw `description.value` as follows:

   - Decode HTML entities.
   - Remove HTML tags while retaining visible text.
   - Treat block elements, table cells, list items, and `<br>` as whitespace.
   - Replace each `polarion-rte-link` work-item span with its resolved title in
     double quotes when a title is available.
   - Otherwise replace that span with its `data-item-id` without quotes.
   - Replace each document link with its resolved document title in double
     quotes when available; otherwise use `data-item-name` without quotes.
   - Collapse consecutive whitespace and trim the result.

   Do not return HTML as plain text, and do not silently discard visible text
   surrounding an inline link. Before returning, reject the result if
   `description_plain` contains an HTML tag such as `<span`, `<div`, `<br`, or
   `polarion-rte-link`.

7. If `resolveLinks` is false, skip link lookup and retain the raw
   `data-item-id` or `data-item-name` in the plain-text conversion. If it is
   true, inspect the description for spans with class `polarion-rte-link` and
   collect unique references before making lookup requests.

8. For each referenced work item, read its `data-item-id` and optional
   `data-scope`. Group references by scope. An empty scope means the current
   `projectId`; a non-empty scope is the referenced project ID. Fetch titles
   with one read-only collection request per project, using a URL-encoded
   Lucene ID query and requesting `id,title`:

   ```bash
   curl --fail-with-body --silent --show-error \
     --header "Accept: application/json" \
     --header "Authorization: Bearer ${POLARION_PAT_PU}" \
     "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/projects/<scope-or-projectId>/workitems?query=<url-encoded-id-query>&fields%5Bworkitems%5D=id%2Ctitle&page%5Bsize%5D=100&page%5Bnumber%5D=1"
   ```

   Follow every `links.next` URL exactly as returned until it is absent. Do
   not assume that 100 results fit on one page. Build a lookup keyed by
   `(scope, itemId)`. If a title cannot be retrieved, use the raw ID fallback
   and report that link resolution was incomplete.

9. For each referenced document, read `data-space-name` and
   `data-item-name`. Resolve its title with the documented project documents
   endpoint after consulting the OpenAPI definition for the exact path and
   field syntax. Use a read-only GET requesting `id,title`. If the document
   cannot be resolved, use the raw document name fallback and report the
   incomplete resolution.

10. If the response contains linked work-item relationships and
    `includeMetadata` is true, preserve their API values. At minimum return
    the link role, secondary work-item ID, suspect flag, and optional project
    and revision fields. Do not infer or invent links from text.

11. Return the requested text first. The default result is:

    - `id`
    - `title`
    - `description_plain`
    - `rationale_plain` when rationale is present

    When `includeMetadata` is true, also return `type`, `status`,
    `outlineNumber`, raw `description`, raw `rationale`, and
    `linkedWorkItems`. Keep the API response shape separate from the derived
    plain-text fields so the raw source remains auditable.

12. Report the HTTP method, resource path, HTTP status, project ID, work-item
    ID, and whether link lookups or pagination occurred. Report authentication
    only as `POLARION_PAT_PU is set`; never report the token.

13. When storing the result in another artifact, store only
    `description_plain` in its requirement-text field. Never store raw
    `description.value` there.

## Pagination

Collection requests used for linked-title resolution may paginate. For each
collection response:

1. Parse the current page only after a successful HTTP status.
2. Process `.data` entries from that page.
3. Read `.links.next`.
4. Request that exact URL with the same authentication and Accept headers.
5. Stop only when `.links.next` is absent or null.

Record the number of pages fetched. Never infer completeness from a page size,
the number of returned records, or the absence of a local match.

## Failure Handling

- Missing token: stop and ask the user to set `POLARION_PAT_PU`.
- `401 Unauthorized`: report invalid, expired, or rejected authentication and
  do not retry repeatedly.
- `403 Forbidden`: report that the token lacks permission.
- `404 Not Found`: report the project/work-item resource path and ask the user
  to verify both IDs.
- Other non-2xx responses: report the status and a redacted diagnostic, then
  stop unless the user asks to retry.
- Invalid JSON: report that the successful response could not be parsed as
  JSON; do not claim that text was retrieved.
- Missing `data.attributes.description`: report that the work item has no
  description instead of guessing from title, links, or unrelated fields.
- Failed linked-title lookup: return the work item text with raw-ID or
  raw-document-name fallbacks and explicitly mark resolution incomplete.
- Network or `curl` failure: report the connectivity or execution failure
  without reproducing secret-bearing command output.

## Secret Safety

- Never print, echo, save, quote, or repeat `POLARION_PAT_PU` or its value.
- Never use `curl --verbose` or include authorization headers in a returned
  transcript.
- Redact tokens from error output before reporting it.
- Do not persist API responses unless the user explicitly requests it.
- Do not use POST, PATCH, PUT, or DELETE. This skill is read-only.

## Output Contract

Return:

- the derived plain-text requirement description;
- rationale plain text when available;
- requested metadata and raw rich text when `includeMetadata` is true;
- link-resolution status and raw-reference fallbacks when applicable;
- HTTP method, resource path, status, and pagination details; and
- authentication status stated only as the environment-variable name.

Never return the complete OpenAPI definition, complete unrelated lookup
responses, or any token value unless the user explicitly asks for the raw
work-item response.
