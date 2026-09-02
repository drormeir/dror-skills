# The finding id carries the round, not the minute

The id joining a report, `refutations.tsv` and `repairs.tsv` was
`<head>-<tag>-<hhmm>-<n>`: the short commit, the run's tag, the report's minute
and the finding's number in it (ADR 0025, ADR 0022).

## The defect

A repair never commits (ADR 0007), so every round of one loop runs at one
commit. The tag is the run's, so every round of one run carries the same tag.
That leaves the minute as the only part of the id separating round 1's third
finding from round 2's. They are different defects, and an append-only log
cannot notice that a key it already holds has arrived meaning something else.

ADR 0022 judged that acceptable, on the grounds that a round takes longer than a
minute. That was measured against a round that finds something. A round that
finds little, or whose lenses return fast, lands in the same minute as the one
before it.

The minute was chosen because nothing better was available. ADR 0022 rejected a
round number outright: only `dror-implement-ticket` knew what round it was on,
and a review run alone would have had to invent one, giving two id shapes for
one purpose. ADR 0041 retired that objection — the round is passed into the
review by its caller and written as `-` when nobody names one, in a log column
of its own.

## The decision

The id is **`<head>-<tag>-r<k>-<n>`** — the short commit, the run's tag, the
round with an `r` in front of it, and the finding's number. `r-` where no caller
named a round. The minute is gone: the tag separates two runs, the round
separates one run's rounds, and the minute answered neither question better than
the thing that owns it.

## Considered options

**Keeping the minute and adding the round** was rejected: it makes the id longer
to fix nothing, since no case survives that the round does not already settle.

**A hash of the finding's claim** was rejected for the reason ADR 0022 rejected a
random token. The id is read out of a report by a person and grepped out of a
log; an opaque field is neither. It would also have paid for a case the report
latch closes — two passes of one round numbering their findings differently,
which is now a defect that stops the run rather than a key to reconcile.

**Leaving it alone** was rejected once the collision was named. It is silent: the
wrong answer arrives as a plausible row, not as an error.

## Consequences

Four id shapes are now in the logs by age — `<head>-<n>`, `<head>-<hhmm>-<n>`,
`<head>-<tag>-<hhmm>-<n>` and this one. Rows already written stay exactly as they
stand, and which shape a row carries says when it was written (ADR 0009). The
existing rule against splitting an id into parts becomes load-bearing rather than
cautionary: a reader that split on `-` and took a position would now read a round
where a minute used to be, and the two are both short and both numeric.

ADR 0022 and ADR 0025 are superseded on the id's shape. What ADR 0025 decided
about the tag stands and is carried here.
