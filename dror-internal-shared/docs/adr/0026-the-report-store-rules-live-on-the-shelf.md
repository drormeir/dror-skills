# The report store's rules live on the shelf, not in each skill

`REPORT-STORE.md` holds what every `dror-*` run has to agree on about a report:
which name the file takes, the identity line that makes the name checkable
(ADR 0021), the finding id and its match-whole rule (ADR 0025), and the
discipline every log obeys (ADR 0009). Its readers are defined by **role, not by
a list**: a run that writes a report, one that reads one, one that names the path
both ends use, and one that joins the logs by finding id. At the moment this was
decided that was five skills — `dror-code-review`, `dror-adr-review`, `dror-code-repair`,
`dror-adr-repair` and `dror-code-review-repair` — and **the roster has grown since**
and will again; the shelf's own `SKILL.md` says which files each document is read
whole by, and that is the current answer. The role test is what binds.

Those rules used to be restated in each of the five, and they had already
drifted. `dror-adr-repair` still carried the bare-name fallback ADR 0021 removed,
`dror-adr-review` wrote no identity line at all, and the header-only-if-absent
rule appeared in four wordings. A rule about how two runs share one file is
exactly the rule that must read identically in every run that touches it.

This is ADR 0015's arrangement applied a second time: the shelf owns no
procedure, so a document there belongs to none of its callers.

## Considered options

**Leaving the rules with `dror-code-review` and having the others point at it** was
rejected for ADR 0015's reason — a skill reaching into another skill's file
breaks the moment either is moved or packaged, and the reading skills are not
callers of the review.

**One ADR per rule and no shared document** was rejected: the ADRs record why a
rule was chosen and are read by a person deciding, while a run needs the rule
itself, in order, at the moment it writes the file.

## Consequences

What a report *contains* stays with the skill that writes it — the ordering of
findings and the sections. The shelf holds only what more than one run must agree
on, which is the line between the two.

**That line moved once, and the same way.** The shelf originally carried
`refutations.tsv`'s columns alone, on the grounds that it had two writers, and
left `runs.tsv` and `repairs.tsv` to their skills as single-writer files. Both
have two writers as well — the code review and the ADR review write the first,
the code repair and the ADR repair the second — and by the time anyone checked,
the two `repairs.tsv` copies had drifted: one capped `files_edited` at six files
and `+N more`, the other did not, and neither said the difference was meant. So
all three column lists live on the shelf now, and each writer states only its own
**values** — its `kind`, its `outcome` vocabulary, what it may write in
`concurrent` or `production`. Those genuinely differ per writer, and that is the
sharper form of the line: a schema is shared, a vocabulary is owned.

`dror-adr-review` now writes `ADR: <n>` in its front matter, and
`dror-adr-repair` checks it and no longer falls back to a bare
`adr-review-report.md`. A report written before this ADR has no such line, and
the reference's third case covers it: fall back to the file name, never to the
bare one.
