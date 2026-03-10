---
name: opencode-manage-skills
description: >-
  Manage OpenCode skills across CRUD operations with safe defaults,
  explicit options, and validation steps.
compatibility: opencode
metadata:
  domain: opencode
  category: skill-authoring
  output: markdown
---

## What I do

I manage OpenCode skill definitions with clear option tradeoffs,
guarded permission baselines, and predictable validation.

## Inputs

Required:

- Operation (`create`, `read`, `update`, or `delete`)
- Skill name

Optional:

- Skill purpose
- triggers and usage conditions
- compatibility target
- metadata fields
- output contract and response style

## Execution steps

1. Read the latest OpenCode skills documentation:
   `https://opencode.ai/docs/skills/`
2. Confirm critical decisions with the user:
   - target operation and scope
   - skill name, purpose, and expected triggers
   - compatibility and metadata requirements
   - expected response format and depth
3. Draft or inspect `SKILL.md` frontmatter and body with safe defaults and
   selected options.
4. Execute the requested operation on
   `skills/<skill-name>/SKILL.md`.
5. Validate structure for create and update operations:
   - valid YAML frontmatter
   - required `name` and `description`
   - `name` matches `<skill-name>` directory
6. Return affected path and a concise summary of chosen options.

## Output contract

Return:

- operation performed
- affected file path
- selected defaults and user-selected overrides
- any assumptions or unresolved choices
