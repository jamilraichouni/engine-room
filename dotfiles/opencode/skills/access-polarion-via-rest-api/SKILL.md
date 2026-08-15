---
name: access-polarion-via-rest-api
description: >-
  Access the configured Siemens Polarion REST API with authenticated, read-only
  HTTP requests using curl and return concise JSON results.
compatibility: opencode
metadata:
  domain: polarion
  category: rest-api
  output: json
  polarion:
    baseUrl: https://awspoldsdpu.polarion.comp.db.de/polarion
    restApiEndpoint: https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1
    openApiSpec: >-
      https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/definition
    accessTokenEnvVar: POLARION_PAT_PU
  tags:
    - bash
    - cli
    - document
    - filter
    - polarion
    - python
    - requirement
    - workitem
---

# Skill: Access Polarion via REST API

## What I do

- I retrieve Polarion resources through the REST API with `curl`.
- I use the fixed REST API endpoint in the metadata and the token from
  `POLARION_PAT_PU`.
- I return the response data or a concise extraction of requested fields.

## When to use me

Use this skill for direct REST API reads, such as listing projects, retrieving
work items, inspecting a document, or querying API resources. Use
`download-document-from-polarion` instead when the requested result is a
document exported as YAML.

## Preconditions

- `POLARION_PAT_PU` is set to a valid Polarion personal access token.
- `curl` is available to the Bash tool.
- The user has supplied enough identifiers to construct the requested resource,
  such as a project ID, space ID, document ID, or work item ID.

## Workflow

1. Consult the OpenAPI specification in `metadata.polarion.openApiSpec` when
   the resource, method, parameters, or response fields are unclear.
2. Use only the REST API endpoint in `metadata.polarion.restApiEndpoint`.
3. Determine the HTTP method and resource path before making the request.
4. URL-encode query parameters. In particular, quote URLs containing
   `page[size]`, `page[number]`, or `query` in the shell.
5. Send `Accept: application/json` and
   `Authorization: Bearer ${POLARION_PAT_PU}` headers.
6. Prefer `GET` requests. Do not create, update, or delete resources unless the
   user explicitly requests the operation and confirms its consequences.
7. Check the HTTP status before interpreting the response as successful JSON.
8. Parse JSON only after a successful response. Preserve the API response shape
   unless the user asks for a specific projection.
9. For paginated responses, follow the response `links.next` URL until it is
   absent. Do not infer that one page is complete from a truncated result.
10. Report the resource queried, the number of returned records when available,
    and any pagination performed. Never report the token value.

## Request template

```bash
curl --fail-with-body --silent --show-error \
  --header "Accept: application/json" \
  --header "Authorization: Bearer ${POLARION_PAT_PU}" \
  "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/<resource>"
```

Use `--fail-with-body` so that non-2xx responses fail while retaining the
server's diagnostic body. Do not use `--verbose` because request diagnostics
can expose authorization headers.

## Common read examples

List the first page of work items in a project:

```bash
curl --fail-with-body --silent --show-error \
  --header "Accept: application/json" \
  --header "Authorization: Bearer ${POLARION_PAT_PU}" \
  "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/projects/AR_DKS/workitems?page%5Bsize%5D=100&page%5Bnumber%5D=1"
```

Retrieve one work item, using the project and work item IDs required by the
endpoint:

```bash
curl --fail-with-body --silent --show-error \
  --header "Accept: application/json" \
  --header "Authorization: Bearer ${POLARION_PAT_PU}" \
  "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1/projects/AR_DKS/workitems/AR-123"
```

Use `jq` only when it is available and a reduced result is requested, for
example `jq '.data[] | {id, type}'`. Do not assume every resource uses the
same attributes; verify the schema first.

## Filtering and pagination

- Use the endpoint's documented query parameters, not undocumented UI URLs.
- Encode Lucene or other query expressions as query parameter values.
- Treat a response's `data` member as the collection when present.
- Follow `links.next` for complete collection retrieval. A missing `next` link
  indicates the final page.
- Keep resource IDs and response content separate in the final summary so that
  large response bodies are not repeated unnecessarily.

## Secret handling

- Never print, echo, log, save, quote, or expose the value of
  `POLARION_PAT_PU`, including partial values.
- Refer to authentication only by the environment variable name or by saying
  that a token was provided.
- Do not place tokens in URLs, files, shell history, or examples.
- If an error or command output contains a token, redact it before reporting
  anything to the user.

## Failure handling

- If `POLARION_PAT_PU` is unset, stop and ask the user to configure it.
- On `401 Unauthorized`, report that the token is invalid, expired, or not
  accepted; do not retry repeatedly.
- On `403 Forbidden`, report that the token lacks permission for the resource.
- On `404 Not Found`, report the resource path and ask the user to verify its
  identifiers.
- On other non-2xx responses, report the status code and a redacted response
  body, then stop unless the user asks to retry.
- If `curl` is unavailable or the request cannot reach the server, report that
  execution or connectivity failure without exposing command secrets.

## Output contract

Return:

- the parsed JSON response, or the requested concise projection
- the HTTP method and resource path
- the HTTP status code
- pagination details when a collection was paginated
- authentication status described only as the token environment variable name

Do not claim success when the server returned a non-2xx status or when the
response could not be parsed as JSON.
