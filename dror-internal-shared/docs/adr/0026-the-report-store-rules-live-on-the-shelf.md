# The report store's rules live on the shelf, not in each skill

`REPORT-STORE.md` holds what every `dror-*` run has to agree on about a report:
which name the file takes, the identity line that makes the name checkable
(ADR 0021), the finding id and its match-whole rule (ADR 0025), and the
discipline every log obeys (ADR 0009). It is read whole by `dror-review` and
`dror-adr-review`, which write reports, by `dror-repair` and `dror-adr-repair`,
which read them, and by `dror-review-repair`, which names the path both ends use.

Those rules used to be restated in each of the five, and they had already
drifted. `dror-adr-repair` still carried the bare-name fallback ADR 0021 removed,
`dror-adr-review` wrote no identity line at all, and the header-only-if-absent
rule appeared in four wordings. A rule about how two runs share one file is
exactly the rule that must read identically in every run that touches it.

This is ADR 0015's arrangement applied a second time: the shelf owns no
procedure, so a document there belongs to none of its callers.

## Considered options

**Leaving the rules with `dror-review` and having the others point at it** was
rejected for ADR 0015's reason — a skill reaching into another skill's file
breaks the moment either is moved or packaged, and the reading skills are not
callers of the review.

**One ADR per rule and no shared document** was rejected: the ADRs record why a
rule was chosen and are read by a person deciding, while a run needs the rule
itself, in order, at the moment it writes the file.

## Consequences

What a report *contains* stays with the skill that writes it — the ordering of
findings, the sections, and each log's own columns. The shelf holds only what
more than one run must agree on, which is the line between the two.

`dror-adr-review` now writes `ADR: <n>` in its front matter, and
`dror-adr-repair` checks it and no longer falls back to a bare
`adr-review-report.md`. A report written before this ADR has no such line, and
the reference's third case covers it: fall back to the file name, never to the
bare one.
