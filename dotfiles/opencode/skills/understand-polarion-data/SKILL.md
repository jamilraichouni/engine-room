---
name: understand-polarion-data
description: >-
  Interpret Polarion data (here workitems).
compatibility: opencode
metadata:
  domain: polarion
  category: data-interpretation
  output: understanding
  tags:
    - data-interpretation
    - document
    - heading
    - outline number
    - outlineNumber
    - polarion
    - req
    - reqs
    - requirement
    - workitems
---

# Skill: Understand Polarion data

## What I do

- I help with understanding Polarion data, including work items downloaded from
  a Polarion document.

## When to use me

Use this when you need to classify or explain Polarion data or data entities.

## Polarion object types

- Polarion stores projects
- Polarion projects contain work items, documents, plans, and test artifacts
- Polarion documents live in spaces and can have comments and attachments
- Polarion documents are made of ordered document parts
- Polarion document parts can reference work items
- Polarion work items can have comments, attachments, approvals, and links
- Polarion also maintains users, user groups, roles, enumerations, jobs, and
  revisions

## Polarion document body contents

- A document body is modeled as an ordered list of document parts
- Document parts carry outline structure through `level`, `previousPart`, and
  `nextPart`
- Document parts can contain rich body content in `content`
- Document parts can reference embedded work items through `workItem`
- Work items can be moved into or out of a document and become part of its body
- Comments and attachments belong to the document, but they are not part of the
  document body itself

## Identifying requirements in Polarion

- A requirement is a work item that has a `type` attribute with a value that
  contains the substring `req` (case-insensitive).

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

1. For work items check whether `type` is exactly `heading`.
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
