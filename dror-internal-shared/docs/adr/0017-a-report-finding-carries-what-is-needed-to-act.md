# A report finding carries what is needed to act, not the route that found it

A review report is read start to finish by a repair run and by a human the
next day, so a finding is about fifteen lines: its `file:line`, its failure
scenario, its kind, and the sentence or two that make the scenario believable.
What it does not carry is the refuter's route — the files traced, the call sites
checked, the reasoning retold twice.

A repair redoes that work anyway against the tree as it stands, and reading a
stale account of it first is worse than reading none.

## Consequences

The `## Refuted` section is terser still — one short paragraph per kill, no
failure scenarios — because nothing downstream acts on it; it exists as evidence
about the review's own precision (ADR 0009).

Line numbers are taken from the tree as it stands at the end of the run, since a
claim comment inserted above a survivor has moved it, and the report records both
the base and `HEAD` so a later run can say the numbers are stale.
