# Runtime Review Check Policy

Policy revision: `2026-08-17.2`

Increment the policy revision whenever a check name, target, applicability,
evidence rule, pass criterion, or comment requirement changes.

## Shared Rules

Apply exactly the six check sections C1 through C6 below. The current content
of this file is authoritative for the skill-level check policy. System,
developer, and repository instructions still have higher priority.

Each written review result must contain the section's exact `Stored check
name`, a Boolean `pass`, and a non-empty evidence-based `comment`.

Use only these targets: `requirement` and `linked system test case`. Use only
these applicability values: `always` and `gated`. A gated check may reference
only an earlier check ID.

An always-applicable check must be written whether it passes or fails. Missing,
unreadable, contradictory, or ambiguous evidence cannot produce a pass.

A gated check must be written only when its gate passes. When its gate fails,
report the check as not applicable and remove a stale result for that check
from the selected object.

Preserve `single attached cucumber test` and every unrelated review result.

For human-readable name comparisons, ignore only a recognized identifier
prefix such as `SYS_TG05_T001 - `. Retain the identifier for feature and
test-plan traceability. Do not remove arbitrary text merely because it precedes
a hyphen.

Treat equivalent wording as equal only when actors, preconditions, inputs,
actions, tested behavior, and expected results remain semantically equivalent.

## C1

Stored check name:
`C1 - Polarion test case description logically matches Cucumber test`

Target: `linked system test case`

Applicability: `always`

Evidence:

- The visible text of the Polarion test-case `description`.
- The corresponding scenario definition in the Polarion `cucumber test`.

Evaluation:

Compare the description with the scenario definition, not merely the
`Feature:` title. Compare the actor, preconditions, action, tested behavior,
and expected result.

Pass criteria:

Pass only when the description and scenario express the same test intent.
Missing behavior, a contradictory outcome, an unreadable attachment, or an
ambiguous choice among scenarios must fail.

Comment requirements:

Identify the corresponding scenario and the evidence supporting consistency.
On failure, describe every material omission, contradiction, or ambiguity.

## C2

Stored check name:
`C2 - requirement is verified by the linked test cases`

Target: `requirement`

Applicability: `always`

Evidence:

- The validated stored requirement text and directly relevant context.
- All linked Polarion Cucumber scenarios of type `systemtestcase`.
- Link metadata, including `suspect`, and linked non-test work-item types.

Local feature files and test plans cannot substitute for missing Polarion
Cucumber evidence in C2. A Polarion link alone is not verification.

Evaluation:

Decompose the requirement into every mandatory actor, trigger, condition,
input variant, behavior, output, timing constraint, and expected result. Map
each obligation to observable evidence in one or more linked scenarios.

Treat a suspect link as a traceability risk. Treat a linked item whose type is
not `systemtestcase` as a traceability gap rather than adding test-case checks
to it.

Pass criteria:

Pass only when the linked scenarios collectively provide sufficient
preconditions, inputs, actions, and observable expected results for every
mandatory obligation. If there are no valid linked system test cases, fail.

Comment requirements:

Describe supporting coverage and every missing behavior, uncovered variant,
insufficient precondition, weak assertion, contradiction, unrelated test,
suspect link, or traceability gap.

## C3

Stored check name:
`C3 - Corresponding feature file found in features/ivv/`

Target: `linked system test case`

Applicability: `always`

Evidence:

- The Polarion Cucumber scenario, including its identifier and name.
- Candidate scenarios beneath `features/ivv/**/*.feature`.
- Effective feature or rule background, ordered steps, and arguments.

Evaluation:

Use a complete scenario identifier, exact scenario name, and distinctive text
to retrieve and disambiguate candidates. The decisive evidence is
correspondence of ordered scenario steps, arguments, and effective background.
An identifier, filename, or broad topic alone is not a behavioral match.

Pass criteria:

Pass only when one unique corresponding local scenario is established.

Comment requirements:

On pass, provide the repository-relative path beginning with `features/ivv/`
and identify the scenario. On failure, state the candidate count and explain
the missing, conflicting, or ambiguous evidence.

## C4

Stored check name: `C4 - Polarion Cucumber test matches local test`

Target: `linked system test case`

Applicability: `gated`

Gate: C3 passes and identifies one unique corresponding local scenario.

Gate-failure action: report C4 as not applicable and remove a stale selected
C4 result.

Evidence:

- The complete Polarion Cucumber scenario definition.
- The unique local scenario and its effective feature or rule context.

Evaluation:

Compare all of the following:

- Feature, rule, scenario, and scenario-outline names.
- Effective feature, rule, and scenario tags.
- Effective background behavior and ordered scenario steps.
- Step keywords, text, parameters, doc strings, and data tables.
- Examples, substitutions, and covered variants.
- Expected results and behavior affecting execution or traceability.

Ignore formatting-only changes and wording that is demonstrably equivalent.

Pass criteria:

Pass only when no material difference remains.

Comment requirements:

State whether the tests are consistent. On failure, record every difference
affecting test intent, coverage, execution, or traceability as a separate
finding in the comment.

## C5

Stored check name:
`C5 - Corresponding test plan file found in @data/ivv/test-plans/`

Target: `linked system test case`

Applicability: `always`

Evidence:

- Textual test-plan sources beneath `data/ivv/test-plans/`.
- Polarion test-case and requirement references.
- Exact feature or scenario names and distinctive scenario step text.

Prefer evidence in this order:

1. An explicit Polarion test-case reference.
2. An explicit requirement reference tied by plan structure to the selected
   test case.
3. An exact feature or scenario name.
4. Distinctive scenario step text.

Evaluation:

A bare requirement occurrence is only a candidate and cannot pass without
test-case-specific evidence. A filename, generated image, or broad topic alone
is not a match. Use the `.ctex` source instead of a generated PNG when both
exist.

Pass criteria:

Pass when one or more files have specific evidence tying their test design to
the selected test case. Multiple corresponding files are allowed.

Comment requirements:

On pass, list every accepted repository-relative path beginning with
`data/ivv/test-plans/`. On failure, distinguish direct matches from
requirement-only or topic-only candidates and explain why none qualifies.

## C6

Stored check name:
`test design is consistent with the requirement and test case`

Target: `linked system test case`

Applicability: `gated`

Gate: C5 passes with one or more specifically corresponding test-plan files.

Gate-failure action: report C6 as not applicable and remove a stale selected
C6 result.

Evidence:

- Every test-plan source accepted by C5.
- The selected requirement and Polarion Cucumber scenario.
- Effective Cucumber test-group `TG` and test-case `T...` identifiers.
- The comment immediately associated with the scenario tags.

Evaluation:

For every C5 plan match:

1. Verify the selected requirement ID in the test-plan source.
2. Inspect effective Cucumber tags for the relevant `TG` and `T...` values.
3. Read the test-case name after the identifier-separating hyphen in the
   comment immediately associated with the scenario tags.
4. Locate the corresponding design by the identifiers and name.
5. Compare plan preconditions, actions, data, variants, and expected results
   with the requirement and Polarion scenario.

Pass criteria:

Pass only when the requirement reference, identifiers, name, and semantic test
design are consistent.

Comment requirements:

Describe the supporting correspondence and every missing, contradictory,
ambiguous, or unrelated item of evidence.
