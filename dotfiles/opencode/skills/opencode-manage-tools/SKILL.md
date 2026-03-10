---
name: opencode-manage-tools
description: >-
  Manage OpenCode tools across CRUD operations with safe defaults,
  Python-first guidance, and validation steps.
compatibility: opencode
metadata:
  domain: opencode
  category: tool-authoring
  output: markdown
  language-focus: python
---

## What I do

I manage OpenCode tool definitions and implementations with a
Python-first workflow, clear option tradeoffs, and predictable validation.

## Inputs

Required:

- Operation (`create`, `read`, `update`, or `delete`)
- Tool name

Optional:

- Tool purpose
- tool input and output schema
- runtime and dependency needs
- permission and safety constraints
- output contract and response style

## Execution steps

1. Read the latest OpenCode tools documentation:
   `https://opencode.ai/docs/custom-tools/`
2. Read Python tool authoring guidance:
   `https://opencode.ai/docs/custom-tools/#write-a-tool-in-python`
3. Confirm critical decisions with the user:
   - target operation and scope
   - tool name, purpose, and expected usage
   - schema shape, validation rules, and failure behavior
   - runtime assumptions and dependency constraints
4. Draft or inspect tool configuration and Python implementation with safe
   defaults and selected options.
5. Execute the requested operation on the relevant tool files.
6. Validate structure for create and update operations:
   - tool metadata and schema are valid
   - Python entrypoints and dependencies are consistent
   - naming matches user intent and repository conventions
7. Return affected paths and a concise summary of chosen options.

## Output contract

Return:

- operation performed
- affected file paths
- selected defaults and user-selected overrides
- any assumptions or unresolved choices
