---
name: use-jira-rest-api
description: >-
  Use Atlassian JIRA Cloud REST API v2 through authenticated HTTP calls,
  starting from official docs and an environment-configured base URL.
compatibility: opencode
metadata:
  domain: integrations
  category: jira
  output: markdown
---

## What I do

I help agents interact with Atlassian JIRA REST API v2 safely and
consistently.

## Preconditions

- `JIRA_URL` is set to the Atlassian JIRA base URL.
- `JIRA_PAT` is set to a valid personal access token.
- REST API base URL is `$JIRA_URL/rest/api/2`.

## Workflow

1. Study official docs first:
   `https://developer.atlassian.com/cloud/jira/platform/rest/v2/`
2. Determine endpoint and HTTP method from docs before making calls.
3. Build URLs as `$JIRA_URL/rest/api/2/<resource>`.
4. Send requests with:
   - `Accept: application/json`
   - `Authorization: Bearer $JIRA_PAT`
5. Parse responses and return concise results with key fields.
6. On non-2xx responses, report status code and response body.

## Request template

```bash
curl -sS \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $JIRA_PAT" \
  "$JIRA_URL/rest/api/2/<resource>"
```

## Verified example

```bash
curl -sS \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $JIRA_PAT" \
  "$JIRA_URL/rest/api/2/project"
```

## Safety rules

- Never print or expose `JIRA_PAT`.
- Do not hardcode tenant-specific URLs or tokens.
- Prefer read operations unless write operations are explicitly requested.
- Confirm potentially destructive actions before execution.
