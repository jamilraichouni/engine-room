# Runtime Review Check Policy

Policy revision: `2026-08-19.10`

Increment the policy revision whenever a check name, target, applicability,
evidence rule, pass criterion, or rationale requirement changes.

## Shared Rules

Apply exactly the check sections declared below. They must be numbered
contiguously from C1 in ascending numeric order. Add a new check by appending
one new section with the next ID; do not renumber existing checks. The current
content of this file is authoritative for the skill-level check policy. System,
developer, and repository instructions still have higher priority.

Each written review result must contain the section's exact
`Stored check name`, a Boolean `pass`, and a non-empty evidence-based
`rationale`.

## Reporting Contract

The review report must expose every evaluated target/check pair. Each row must
include the complete stored check name, result, and full evidence-based
rationale. A summary-only report is non-conformant, even when the YAML update
and validation succeeded.

Use only these targets: `requirement` and `linked system test case`. Use only
these applicability values: `always` and `gated`. A gated check may reference
only an earlier check ID.

An always-applicable check must be written whether it passes or fails. Missing,
unreadable, contradictory, or ambiguous evidence cannot produce a pass.

A gated check must be written only when its gate passes. When its gate fails,
report the check as not applicable and remove a stale result for that check
from the selected object.

Preserve `single attached cucumber test` and every unrelated review result.

For human-readable name comparisons, ignore only a recognized identifier prefix
such as `SYS_TG05_T001 - `. Retain the identifier for feature and test-plan
traceability. Do not remove arbitrary text merely because it precedes a hyphen.

Treat equivalent wording as equal only when actors, preconditions, inputs,
actions, tested behavior, and expected results remain semantically equivalent.

## C1

Stored check name: `C1 - requirement is verified by the linked test cases`

Target: `requirement`

Applicability: `always`

Evidence:

- The validated stored requirement text and directly relevant context.
- All linked Polarion Cucumber scenarios of type `systemtestcase`.
- Link metadata, including `suspect`, and linked non-test work-item types.

Local feature files and test plans cannot substitute for missing Polarion
Cucumber evidence in C1. A Polarion link alone is not verification.

Evaluation:

Decompose the requirement into every mandatory actor, trigger, condition, input
variant, behavior, output, timing constraint, and expected result. Map each
obligation to observable evidence in one or more linked scenarios.

Treat a suspect link as a traceability risk. Treat a linked item whose type is
not `systemtestcase` as a traceability gap rather than adding test-case checks
to it.

Pass criteria:

Pass only when the linked scenarios collectively provide sufficient
preconditions, inputs, actions, and observable expected results for every
mandatory obligation. If there are no valid linked system test cases, fail.

Rationale requirements:

Describe supporting coverage and every missing behavior, uncovered variant,
insufficient precondition, weak assertion, contradiction, unrelated test,
suspect link, or traceability gap.

## C2

Stored check name:
`C2 - Polarion test case description logically matches Cucumber test`

Target: `linked system test case`

Applicability: `always`

Evidence:

- The visible text of the Polarion test-case `description`.
- The corresponding scenario definition in the Polarion `cucumber test`.

Evaluation:

Compare the description with the scenario definition, not merely the `Feature:`
title. Compare the actor, preconditions, action, tested behavior, and expected
result.

Pass criteria:

Pass only when the description and scenario express the same test intent.
Missing behavior, a contradictory outcome, an unreadable attachment, or an
ambiguous choice among scenarios must fail.

Rationale requirements:

Identify the corresponding scenario and the evidence supporting consistency. On
failure, describe every material omission, contradiction, or ambiguity.

## C3

Stored check name: `C3 - Corresponding feature file found in features/ivv/`

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

Rationale requirements:

On pass, provide the repository-relative path beginning with `features/ivv/`
and identify the scenario. On failure, state the candidate count and explain
the missing, conflicting, or ambiguous evidence.

## C4

Stored check name: `C4 - Polarion Cucumber test matches local test`

Target: `linked system test case`

Applicability: `gated`

Gate: C3 passes and identifies one unique corresponding local scenario.

Gate-failure action: report this check as not applicable and remove its stale
selected result.

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

Rationale requirements:

State whether the tests are consistent. On failure, record every difference
affecting test intent, coverage, execution, or traceability as a separate
finding in the rationale.

## C5

Stored check name:
`C5 - Corresponding test case identified in test plan file @data/ivv/test-plans/`

Target: `linked system test case`

Applicability: `always`

Evidence:

- Textual test-plan source files (`.ctex` extension) beneath
  `data/ivv/test-plans/`.
- Reference of test case (test plan name, test group, test case number) in
  format `@<test plan name>_TG<xx>_T<xxx>` given in tag of Cucumber code in
  Polarion test case
- Test plan file identified via test plan name in tag.
- Test case identified in test plan file via test group and test case number.

Prefer evidence in this order:

1. An explicit reference of a test plan name, test group (TG), and test case
   (T...) is given via one tag for the scenario of the Cucumber test attached
   to the Polarion test case.
2. The test group is identified in the test plan file via an XML tag attribute
   `xsi:type="cte:TestItemGroup"` and `name="TG<xx>"...` where `<xx>` is the
   test group number.
3. The test case in that test group is identified in the test plan file via an
   XML tag which is a child element of the test group tag and has an attribute
   `xsi:type="cte:TestCase"` and `name="T<xxx>"...` where `<xxx>` is the test
   case number.

Evaluation:

A test case in a test plan is referenced via a specific tag of the scenario in
the Cucumber test. The tag follows a naming convention that includes the test
plan name, test group number, and test case number.

The tag matches the pattern `@<test plan name>_TG<xx>_T<xxx>` where `TG<xx>` is
the test group number, and `T<xxx>` is the test case number. The tag must be
present in the scenario definition and not merely in a feature or rule
background.

There is a mapping between test plan name and test plan file base name:

```text
+---------------------------------------------------------+----------------------------------------------------------+
|Test plan name                                           |Test plan file base name                                  |
+=========================================================+==========================================================+
|ATO_session_establishment_and_termination                |ATO_communication_session_establishment_and_termination   |
|ATOOB_ATOC_Interface                                     |ATOOB_ATOC_Interface                                      |
|cancellation                                             |Cancellation                                              |
|JP_message_content                                       |JP_message_content                                        |
|JP_update_based_on_train_category_train_type_train_length|JP_updated_based_on_train_category_train_type_train_length|
|maintain_str                                             |Maintain_STR                                              |
|RBC_ATOC_communication                                   |RBC_ATOC_communication                                    |
|reduce_arrival_departure_time                            |Reduce_arrival_and_departure_delay                        |
|TCR_session_request_format                               |TCRSessReq_message_format                                 |
|TCR_communication_session_establishment_and_termination  |TCR_communication_session_establishment                   |
|jp_exchange_dtt_ftt                                      |JP_creation_based_on_DTT_FTT                              |
|Driving_scenario                                         |Driving_scenario                                          |
|dispo_atoc_communication                                 |Disposition_ATOC_communication                            |
|interruption                                             |Interruption_Scenario                                     |
|enter_exit_aoc                                           |Leaving_AoC                                               |
|ATOOB_ATOC_TCR_IF                                        |ATO-OB_ATO-C_TCR_Interface                                |
|interruption_turnback                                    |Interruption_Turnback_Combination                         |
|Daylight_saving                                          |Daylight_saving                                           |
+---------------------------------------------------------+----------------------------------------------------------+
```

A filename, generated image, or broad topic alone is not a match. Use the
`.ctex` source instead of a generated PNG when both exist.

Pass criteria:

Pass when exactly one test case for the specified test group number has been
identified for the test plan file as specified via the tag and its mapping to a
test plan file base name. A test plan file has the specific evidence tying the
test case to the selected test case from the Cucumber code attached to the
Polarion test case. Multiple corresponding files are not allowed.

Rationale requirements:

On pass, list every accepted repository-relative path beginning with
`data/ivv/test-plans/`. On failure, distinguish direct matches from
requirement-only or topic-only candidates and explain why none qualifies.

## C6

Stored check name:
`C6 - test in test plan logically matches the requirement and test case`

Target: `linked system test case`

Applicability: `gated`

Gate: C5 passes with one specifically corresponding test-plan file.

Gate-failure action: report this check as not applicable and remove its stale
selected result.

Evidence:

- The test-plan source accepted by C5.
- The selected requirement and Polarion Cucumber scenario.
- Effective Cucumber test-group `TG` and test-case `T...` identifiers.
- The comment immediately associated with the scenario tags.

Evaluation:

For the C5 test case in test plan match:

1. Verify the selected requirement ID in the test-plan source.
2. Inspect effective Cucumber tags for the relevant `TG` and `T...` values.
3. Read the test-case name after the identifier-separating hyphen in the
   comment immediately associated with the scenario tags.
4. Locate the corresponding test in test plane by the identifiers and name.
5. Compare the single test-plan in isolation from other tests in the test plan
   file.
6. Compare the test title, requirement references, identifiers, and high-level
   intended outcome with the requirement and Polarion scenario. Use detailed
   preconditions, actions, data, variants, and expected results when they are
   present, but do not require them when the test-plan source is a high-level
   design matrix or otherwise does not contain that detail.

Pass criteria:

Pass when the test-plan source has a specific traceability reference to the
selected requirement, its test-case identity and name correspond to the
Polarion scenario, and the available design information does not contradict the
requirement or scenario. Missing detailed procedural information alone is not a
failure.

Rationale requirements:

Describe the supporting traceability and logical correspondence. Report every
contradiction, ambiguous identity, or unrelated item of evidence. Mention
missing detailed design information when relevant, but do not treat its absence
alone as a failure.

## C7

Stored check name: `C7 - test in test plan references the selected requirement`

Target: `linked system test case`

Applicability: `gated`

Gate: C5 passes with one specifically corresponding test-plan file.

Gate-failure action: report this check as not applicable and remove its stale
selected result.

Evidence:

- The test case identified in the test plan accepted by C5.
- The selected requirement id.
- Effective Cucumber scenario tag test name, test group number `TG<xx>` and
  test case number `T<xxx>` identifiers.

Evaluation:

For the C5 test case in test plan match:

1. Verify the selected requirement ID in the test case name for the test plan.
2. Read the test case name in the test plan file for the XML tag with the
   attribute `xsi:type="cte:TestCase"`.
3. Check that the test case name contains a reference to the ID of the selected
   requirement.

Pass criteria:

Pass when the test case name in the test plan references the selected
requirement by its ID.

Rationale requirements:

Describe the supporting traceability (Cucumber scenario tag and name of test
case in test plan file (with absolute test plan file path). Report when the ID
of the selected requirement is no referenced in the name of the test case
identified in C5.
