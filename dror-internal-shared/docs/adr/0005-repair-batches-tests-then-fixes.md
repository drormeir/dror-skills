# A repair writes every test first, then every fix, then verifies once

`dror-repair` runs all the tests to red, then makes all the fixes, then runs the
suite once. This is deliberately against the usual one-slice-at-a-time advice:
the bugs arriving here are already found and described, so nothing is being
designed as it goes, and a per-bug loop would cost a full test run per bug.

## Consequences

Step 1 is the step that parallelizes — writing a failing test touches test files
and scratchpad copies and nothing else — grouped by the test file each item lands
in, so two agents never write one file.

Step 2 is serial and stays in the main context: fixes are not separable by file
(two findings meeting in a shared helper is the ordinary case), and the rule that
a shared helper's call sites are listed and grouped before it is edited is a
judgement about the whole list that an agent holding one finding cannot make.
