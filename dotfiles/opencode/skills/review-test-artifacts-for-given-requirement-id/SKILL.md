---
name: review-test-artifacts-for-given-requirement-id
description: >-
  Review C1-C6 test-artifact evidence for exactly one explicitly supplied
  AR_DKS Polarion requirement ID in the ATO-C RC-1 coverage YAML. Update only
  that requirement and its linked test cases. Use only for a request to review
  one explicitly selected AR-<digits> requirement ID.
compatibility: opencode
metadata:
  domain: polarion
  repository: atoc-test-runner
  scope: single-requirement
  output: yaml-review-results
---

# Review Test Artifacts for One Requirement

## Runtime Policy

The mutable C1-C6 policy is `references/checks.md`, relative to the absolute
base directory reported when this skill is loaded.

For every invocation, including a rerun in the same conversation / session:

1. Read `references/checks.md` from disk with the `read` tool before analyzing
   evidence. Never rely on policy content remembered from this skill, an
   earlier tool result, conversation history, or a previous run.
2. Require exactly one non-empty `Policy revision` and record it. Compute and
   record a SHA-256 digest of the file's exact bytes.
3. Validate that it defines exactly one section for each ID C1, C2, C3 etc., in
   that order, with no unknown check sections.
4. Require exactly one `Stored check name`, `Target`, `Applicability`,
   `Evidence`, `Evaluation`, `Pass criteria`, and `Comment requirements` field
   per check. Allow only the targets and applicability values declared by the
   policy's shared rules.
5. Require stored names to be globally unique.
6. Require a `Gate` and `Gate-failure action` for every gated check and neither
   field for an always-applicable check. Every gate must reference an existing
   earlier check ID so gate dependencies are resolvable and acyclic.
7. Treat the latest read as the authoritative skill-level check policy. System,
   developer, and repository instructions have higher priority. Stop and report
   any conflict that cannot be resolved without changing semantics.
8. Report the policy path and revision before starting the review.
9. Read the complete policy again immediately before changing YAML. Recompute
   its SHA-256 digest. If the revision or digest changed, do not write results
   based on mixed policy versions. Restart the analysis using the new policy.
10. Read it a third time after preparing the update and before atomically
    replacing the YAML file. Stop and restart if its revision or SHA-256 digest
    changed.

Edits to `references/checks.md` therefore take effect without restarting
OpenCode. Increment its revision whenever check semantics change. Editing this
`SKILL.md`, agent definitions, commands, or OpenCode configuration still
requires an OpenCode restart.

## Input and Scope

Require exactly one explicitly supplied ID matching `^AR-[0-9]+$`. If the skill
is explicitly invoked without exactly one ID, use the `question` tool to obtain
one target requirement ID before proceeding.

Run from the `atoc-test-runner` repository and search these files:

- `data/requirement-testcoverage/interface-documents-for-rc1.yaml`
- `data/requirement-testcoverage/`
  `6.3-system-function-provide-jp-and-sp-scope-rc1.yaml`

Select a top-level mapping only when all of these values match:

- `work item id` is the supplied ID.
- `project id` is `AR_DKS`.
- `work item type` is exactly `systemreq`.

Stop if there is no match. Require at most one matching mapping in each file.
If a file contains the identity more than once, stop because a filename cannot
disambiguate it safely. If the identity occurs once in each file, use the
`question` tool to ask which target file to update. Duplicates across the two
Polarion widget result sets are valid and must not be deduplicated.

Address each linked test case by the parent requirement identity plus the
linked `project id` and `work item id`. Apply linked-test checks only to work
items whose `work item type` is exactly `systemtestcase`. Apply requirement
checks only to the selected requirement. Derive exact targets, applicability,
gates, names, evidence rules, and pass criteria from the current runtime
policy.

This is not a batch-review skill. Never infer a target requirement or review
another requirement for convenience.

Do not run `data/requirement-testcoverage/scripts/review_rc1.py`. It reviews
every requirement and writes check names that do not match the runtime policy.
Do not rerun completed extraction, Polarion retrieval, attachment download, or
document download tasks. In particular, do not load
`download-document-from-polarion` unless the user explicitly requests a new
download.

## Evidence Sources

Use the selected requirement mapping and these bundled references:

- `references/ARDKS_SYS_008.yaml`
- `references/ARDKS_SYS_010.yaml`
- `references/glossary.yaml`
- `references/SUBSET-125_v100.pdf`
- `references/SUBSET-126_v100.pdf`

Use these repository sources for local implementation evidence:

- `features/ivv/`
- `data/ivv/test-plans/`

Load `understand-polarion-data` before interpreting downloaded Polarion YAML.
Treat `ATO-OB` and `OBU` as synonyms. Treat `SuT` and `SuC` as synonyms. Use
the synonyms for semantic analysis only; never rewrite source evidence.

## Progressive Evidence Loading

Keep the evidence set narrow enough to remain auditable and avoid oversized
context:

1. Parse the selected requirement and all of its linked test cases.
2. Search the two system-document YAML files for the exact requirement ID.
3. Read only the matching item, its heading hierarchy, and directly relevant
   neighboring requirements or explanatory text.
4. Read only `description_plain` for requirement and document prose. Never use
   raw `description` as requirement text.
5. Search the glossary only for terms that affect interpretation of the
   selected requirement or tests.
6. Consult a SUBSET PDF only when the requirement, its direct context, or an
   interface definition cites that SUBSET. Use an already available page-scoped
   text extractor and inspect only the relevant page range. Do not install a
   parser or attach, render, or load an entire PDF into model context. If
   page-scoped extraction is unavailable, report that limitation. A check that
   depends on the unavailable clause cannot pass.
7. Search local feature and test-plan sources as required by the runtime
   policy.

Use the stored `requirement text` as the primary normative statement. Reject
the update if any requirement text in either candidate YAML file contains HTML
markup, including `<span`, `<div`, `<br`, or `polarion-rte-link`. If
requirement text must ever be derived or refreshed, use only a
`description_plain` result.

A linked test-case `description` may contain Polarion rich text. Decode its
entities for analysis, but do not change the stored description.

If neither system document contains the requirement ID, report that no exact
document context was found and use only the validated stored requirement text
and directly relevant glossary or cited SUBSET evidence. If both documents
contain it, inspect both contexts. If a bundled `description_plain` conflicts
materially with the stored requirement text, do not silently choose or merge
the wording. Treat the stored text as normative, report the snapshot conflict,
and fail any check whose conclusion depends on an unambiguous interpretation.

Do not replace missing evidence with assumptions. Apply the current policy's
pass and gate rules exactly.

## Policy-Driven Review

Process C1 through C6 in policy order. For each check:

1. Resolve its exact stored name, target, applicability, evidence, evaluation,
   pass criteria, and comment requirements from the current
   `references/checks.md` read.
2. Gather only the evidence required for that check and shared system context.
3. Evaluate every selected target object independently unless the policy
   explicitly requires collective evidence.
4. Produce one Boolean conclusion and a concrete evidence-based comment for
   every applicable target.
5. Apply each gate only after its prerequisite result is established.
6. Keep not-applicable gated checks out of YAML and report them separately.

Do not retain a previous result merely because its check name is unchanged.
Rerunning a check means reevaluating it using the current policy and current
evidence.

## Safe YAML Update

Before editing, inspect `data/requirement-testcoverage/scripts/` for a reusable
ID-aware helper. Do not use a helper that processes all requirements, hardcodes
check policy, strips HTML into requirement text, or rewrites evidence newlines.
Do not create a persistent helper merely for convenience. If safe execution
requires a new helper, store it in that scripts directory as a separately
reported change and apply the repository's code, documentation, validation, and
rollback rules to it.

Perform one transactional update:

1. Read and retain the exact original bytes and a digest of each candidate YAML
   file.
2. Parse both complete files with a YAML parser configured to reject duplicate
   mapping keys.
3. Locate the target by its complete project, type, and work-item identity.
4. Snapshot every requirement ID, linked test-case ID, and their order.
5. Snapshot the parsed data so semantic changes can be compared after editing.
6. Confirm all selected `review result` values are lists. Migrate an empty
   mapping to an empty list only on a selected target object as part of this
   update. Reject a non-empty mapping or any other type, and require every
   selected value to be a list after migration.
7. Confirm linked test-case identities are unique within the selected
   requirement.
8. Validate current stored-name counts before mutation.
9. Require `single attached cucumber test` exactly once on every selected
   linked system test case. Stop on absence or duplication; do not repair that
   completed prerequisite task.

Update mappings in memory by complete ID. Do not use broad text replacement,
positional line numbers, or a patch anchor made only from repeated keys such as
`review result`, `description`, or `linked test cases`.

Each result entry must contain the policy's exact stored check name, a Boolean
`pass`, and a non-empty evidence-based `comment`. Preserve real line breaks in
Cucumber tests and multiline comments. Never encode them as visible `\n` or
`\r\n` sequences.

Preserve unrelated checks and fields. Replace only one current stored entry.
Add a missing applicable entry. Remove only a stale gated entry when the
current policy requires its removal.

Use a surgical or round-trip-safe YAML update that preserves comments, quoting,
scalar styles, and bytes outside the selected review-result nodes. A full-file
serialization is acceptable only when the byte diff proves that it introduced
no unrelated presentation changes. Write a temporary file in the target file's
directory, preserve the source file mode, and validate the temporary file
before replacement.

Immediately before replacement, verify that the source digest still equals the
original digest and perform the third runtime-policy read. If either source or
policy changed, discard the temporary file and restart from current data
instead of overwriting concurrent work. Replace the source atomically only
after all pre-replacement checks pass.

## Post-Update Validation

After replacement:

1. Parse the complete file again with duplicate-key rejection.
2. Confirm every requirement and linked test-case ID and order is unchanged.
3. For every check and target, validate the exact count required by its current
   applicability and gate.
4. Confirm no applicable stored check name is duplicated.
5. Confirm `single attached cucumber test` still occurs exactly once per
   selected linked system test case and is otherwise unchanged.
6. Confirm every new `pass` value is Boolean and every new `comment` is
   non-empty.
7. Confirm all requirement texts remain HTML-free and all evidence strings,
   literal multiline scalar styles, and line breaks are unchanged. Inspect
   serialized output as well as parsed string values so visible `\n` escapes
   cannot pass validation.
8. Compare parsed pre-edit and post-edit data. Only the selected requirement's
   `review result` and its selected linked test cases' `review result` values
   may differ.
9. Inspect every byte-level diff hunk and require it to fall within those
   selected review-result nodes. Run `git diff --check` without reverting
   pre-existing user changes.
10. Read the runtime policy again and confirm that its revision and digest
    still match the policy used for the written results. If they do not, safely
    restore the attempted YAML update and rerun with the current policy.

If validation fails, restore the exact pre-edit bytes only when the current
file digest still matches the attempted output. If the file changed again, stop
and report the concurrent edit rather than overwriting it. Never use
`git restore`, `git checkout`, or another operation that could discard
pre-existing work.

## Output

Report:

- the runtime policy path, revision, and whether its digest remained stable;
- the requirement ID and target YAML path;
- the C1-C6 pass, fail, or not-applicable result per target object;
- the local feature and test-plan paths used as evidence;
- contextual reference sections or PDF pages consulted;
- YAML and diff validation results; and
- blocked or ambiguous evidence that prevented a conclusion.

Do not return complete documents, complete PDFs, full Cucumber suites, raw
unrelated YAML data, or secrets.
