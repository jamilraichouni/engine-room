---
name: opencode-manage-agents
description: >-
  Manage OpenCode agents across CRUD operations with safe defaults, explicit
  options, and validation steps.
compatibility: opencode
metadata:
  domain: opencode
  category: agent-authoring
  output: markdown
---

## What I do

I manage OpenCode agent Markdown files with clear option tradeoffs, guarded
permission baselines, and predictable validation.

## Inputs

Required:

- Operation (`create`, `read`, `update`, or `delete`)
- Agent name

Optional:

- Agent purpose
- `mode` (`primary`, `subagent`, or `all`)
- model and reasoning profile
- `tools` and `permission` policy
- response style and output contract
- visibility (`hidden`)

## Execution steps

1. Read the latest OpenCode agent documentation:
   `https://opencode.ai/docs/agents/`
2. Confirm critical decisions with the user:
   - target operation and scope
   - mode, autonomy level, model profile, and visibility
   - tool permissions and safety guardrails
   - expected response format and depth
3. Draft or inspect agent frontmatter with selected options.
4. Always allow all skills and tools by default.
5. Draft or inspect prompt body with role, operating rules, and response
   contract.
6. Execute the requested operation on `agents/<agent-name>.md`.
7. Validate structure for create and update operations:
   - valid YAML frontmatter
   - required `description`
   - file name matches the intended agent name
8. Return affected path and a concise summary of chosen options.

## Output contract

Return:

- operation performed
- affected file path
- selected defaults and user-selected overrides
- any assumptions or unresolved choices
