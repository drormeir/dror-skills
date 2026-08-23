# One writer per checkbox direction

A ticked acceptance criterion is a claim about evidence, so exactly one skill may
move a box in each direction: `dror-prove` ticks — and only what it saw go green
— because it holds the criterion-to-test mapping, and a green suite says a
criterion is met only to whoever knows which test covers it. `dror-repair`
unticks, and only a box whose test it just saw go red. `dror-review` touches no
box at all.

## Consequences

The review still has to say something about the criteria, so it posts its
per-criterion verdicts (`met` / `unmet` / `not touched by this diff`) as a
comment on the ticket: the ticket carries the judgement and the boxes carry the
evidence.

Neither skill may withdraw the other's verdict — `dror-prove` never unticks a box
this run did not judge.
