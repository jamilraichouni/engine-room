---
name: understand-polarion-data
description: >-
  Interpret Polarion work item data with strict rules for headings and
  requirements.
compatibility: opencode
metadata:
  domain: polarion
  category: data-interpretation
  output: markdown
---

# Skill: Understand Polarion data

## What I do

I apply fixed interpretation rules for Polarion work items, including work
items downloaded from a Polarion document.

## When to use me

Use this when you need to classify or explain Polarion work items without
mixing headings and requirements.

## Invariants

- Polarion work items can have type `heading` or some other configured type.
- This also applies to work items downloaded from a Polarion document.
- Non-`heading` types are not globally fixed. Multiple configured types may
  exist.
- A work item of type `heading` represents exactly a heading and nothing else.
- Work items of type `heading` can be used to compute a table of contents
  (`toc`).
- When computing a table of contents (`toc`), keep the relevant attributes of
  `heading` work items in logical ascending order.
- A requirement cannot be a work item of type `heading`.
- A work item of type `heading` cannot be a requirement.

## Interpretation rules

1. Check whether `type` is exactly `heading`.
2. If it is `heading`, interpret the work item only as a heading.
3. If it is `heading`, it may also be used to compute a table of contents
   (`toc`).
4. When building a `toc`, preserve logical ascending order for the relevant
   attributes of `heading` work items.
5. If it is not `heading`, do not assume one fixed global type set.
6. Never classify a `heading` work item as a requirement.
7. Never classify a requirement as `heading`.

## Output contract

Return concise statements that preserve these invariants and do not invent
additional global type rules.
