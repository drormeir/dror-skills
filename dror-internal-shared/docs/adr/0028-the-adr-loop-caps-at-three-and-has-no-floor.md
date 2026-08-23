# The ADR loop caps at three rounds and has no floor

`dror-adr-review-repair` loops `dror-adr-review` → `dror-adr-repair` over one
decision document, judged at the end of each round, exactly as
`dror-review-repair` loops the pair below it. Two numbers differ, and both
differences are the point of this document.

**No round-1 floor.** `dror-review-repair` takes a second round whenever the
first repaired anything, because a single review pass was *measured* missing most
of a code diff — three commits where round 2 returned findings in files round 1
never opened (ADR 0023). That gap is about a diff spread across files a pass has
to choose between. An ADR is one document a lens reads whole, and no comparable
measurement exists for it. Writing a floor here would be borrowing another
skill's evidence for a claim nobody has checked, so every round is taken on its
merits, from the first.

**A cap of three, not seven.** The loop's work per round is smaller and its
convergence faster: one file, one writer, and `dror-adr-repair` grounds every
sentence in the tree before writing it, so a correction that could not be
grounded will not become groundable on a later pass. Seven rounds would be seven
readings of the same paragraphs.

## Considered options

**Reusing seven for symmetry** was rejected: the cap exists because the thing
judging whether another round is worth it is the same model that just did the
work and leans toward one more. A cap that no plausible run reaches does not
bound that lean.

**Rounding on `breach`, `conflict` and `revisit` findings** was rejected, and the
skill says so plainly. None of the three is repaired by `dror-adr-repair` — a
breach is code's fault, a conflict needs a choice, a revisit has no wrong
sentence — so a round that returned only those repaired nothing and the next
round would return them again. They leave the loop by their own doors, named in
the summary.

**Having the loop invoke `dror-repair` on the breaches** was rejected as the
wrong run: it would put code edits, a test suite and a working tree inside a loop
whose subject is one document, and ADR 0020's split — an ADR repair changes text
only — is what keeps a document repair from quietly changing behaviour.

## Consequences

The loop mints a run tag and writes every round to
`adr-review-report-<n>-<tag>.md`, which is the caller naming the path
(`REPORT-STORE.md`) and what keeps two loops over one ADR from overwriting each
other's findings. It needs `dror-adr-review` to accept a caller's tag, which
ADR 0027 added.

`dror-adr-repair` gained the closing line the loop's step 4 weighs — whether
another review is owed — mirroring `dror-repair`'s. A skill that neither reviews
nor loops still has to say what it left behind, because the caller cannot see it.

Two runs over one document are still not isolated. The tag keeps their reports
apart and nothing else; the concurrency check reports a neighbour and never gates
on one, which is ADR 0024's rule applied to prose.
