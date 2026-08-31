# A round is a recorded unit

`dror-code-review-repair` gives every round a report of its own,
`review-report-<tag>-r<n>.md`, and passes the round's number into the review it
invokes. `refutations.tsv` and `runs.tsv` gain `round` and `subject`;
`runs.tsv` gains `elapsed_s` and `refutations.tsv` gains the `run_tag` it never
had — `round` separates a run's rounds, and the tag is what joins them into one
run. Nothing about the loop's judgement changes.

## The question that could not be asked

`dror-code-review-repair` carries a **round-1 floor**: where round 1 repaired
anything, round 2 runs whatever the weighing would otherwise have said. Its
grounds are two measured runs — at `8681800` round 1 returned 4 findings and
round 2 returned 15 "in two files round 1 never opened and the repair never
touched"; at `94cb2b6` round 1's single finding was a cover gap and round 2 then
found 9 across four files nobody had looked at.

Read as written, those two runs say something the floor's own name does not.
Findings in files **round 1 never opened** are not a review of what the repair
changed, which is what step 4 says a further round is for. They are a first pass
that did not cover its diff. If that is the general case, the floor is
compensating for `dror-code-review`'s lens fan-out — at most five lenses, each given
the whole diff, none accountable for any particular file — and the second full
pass is doing work the first one was supposed to do. If it is not the general
case, the floor is exactly what it claims and the rounds are earned.

The two readings imply opposite changes, and the difference is worth a drain: at
fifteen tickets the floor is fifteen mandatory extra review-repair passes.

## Why the logs could not settle it

Three things stood in the way, and each was enough on its own.

`refutations.tsv` had no round column, so a three-round loop's findings arrived
as one undifferentiated block. The finding id carries the report's minute and
would separate them, but the store's own rule forbids splitting an id into
parts — for good reason, since three id shapes are in the logs by age and a
positional reader would silently read a tag as a time.

Every round of a loop wrote to the one tagged path, so the file held only the
last round. `dror-code-review-repair` said this was deliberate and gave a reason that
was true when written: the trail is not read, step 4 weighs what the repair
returned, and `repairs.tsv` keeps each outcome keyed by its id. What none of
those hold is *which files a round looked at*.

And `head` is the base sha rather than the ticket's, so nothing tied a row to
the ticket under review at all.

The measurement was therefore impossible at any price from what was on disk —
not expensive, impossible — while the data it needs costs a column and a
filename suffix at the moment it is produced.

## The decision

Record the round as a unit. `round` and `subject` go in both logs, and
`refutations.tsv` gains `run_tag` beside them — the finding rows are where the
rounds must be joined, ids may not be split, and report names are matched
whole, so nothing else in that log could group a loop's rounds. Each round
keeps its report; the loop passes its round number into the review, which cannot
know it and writes `-` when nobody says.

`elapsed_s` rides along because it answers the neighbouring question with the
same two clock readings. Every judgement so far about whether the loop is worth
its rounds has been made from the round *count*, and the one drain that recorded
both showed the count does not predict duration — its longest ticket ran two
rounds and its third-longest ran three.

## Who reads it

`dror-review-retrospective`. It already carried a recall question, and that
question was built on ordering a head's rounds by the tag and minute inside a
finding id — which the store's own rule forbids, since three id shapes are in
the logs by age and a positional read of an older one takes a tag for a time.
The `round` column replaces that mechanism, and the question is sharpened to
sort a round's findings into three: a file the previous review named, a file the
previous repair edited, and neither. The third is the floor's case. A cost
question is added beside it from `elapsed_s`, because a cap argued on recall
alone and a cap argued on cost alone are both half an argument.

## What this does not decide

Whether the floor is coverage or convergence. This ADR buys the ability to ask;
the eleven tickets already on record lean the other way, since two of them name
round 2's finding as **caused by** round 1's fix, which is the floor working as
described. The answer comes from drains run after this, and changing the fan-out
before that answer would be the same guess in the other direction.

## Cost

Two or three columns per log and one filename suffix. Rows written before this hold
fewer fields than there are columns, which the store's append-only rule already
provides for and which is the truth about them. The reports are in a disposable
store, so the extra files cost kilobytes and are deleted with everything else.
