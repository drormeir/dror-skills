# Two rounds are one review

`dror-review-repair` takes a **second round whenever the first one repaired
anything**, whatever that repair touched, and weighs the round on its merits only
from round 3 on.

Until now the loop judged every round the same way, and a repair confined to
tests was the textbook **optional** — say what a round would look at, and stop.
That rule assumed the review before it had seen the diff. It had not.

`~/.claude/dror-skills/refutations.tsv` measures a single review pass against the
round that follows it, by asking which files a later round's findings name:

- `8681800` — round 1 returned 4 findings in two of the diff's modules; round 2
  returned **15** in two others, files round 1 never opened and its repair never
  touched.
- `94cb2b6` — round 1's one finding was a gap in cover, repaired with a test and
  no production edit at all. Under the old rule that is **optional** and a stop.
  Round 2 then found 9 findings across four files nobody had looked at.
- `67d2a48` — round 1 covered one pair of modules; round 2 returned 7 in another
  pair it had not opened.

So the loop's second round was never buying what the file said it bought — a
look at the code the repair wrote. It was finishing the review. Its value is
**resampling a diff one pass does not cover**, and the old `optional` was ending
runs one round before most of their findings.

From round 3 the picture changes: at every head that reached one, a third round
named **no** file its predecessors had not already named. Later rounds dig where
the earlier ones dug, which is the convergence the judgement was written for and
is left exactly as it was.

## Consequences

The floor is on the loop, not on the caller: `dror-implement-ticket`'s cap of
three becomes two-to-three, and a caller that names a cap of one still gets one —
the floor never overrides a cap, it is reported as unmet.

`dror-repair`'s closing word splits. `no` now means *nothing was edited*, and a
tests-only repair returns **`tests alone`** — true about its own edits, and no
longer collapsible into "stop". The two files said the same wrong thing in their
own words, so both were changed; leaving one would have had the repair recommend
a stop the loop overrode every time.

**This does not touch the five-lens cap or the lens read boundary**, which are
the suspects for why one pass misses so much. Changing either would change the
thing producing the only signal there is — and since the log cannot tell a
newly-caught bug from a newly-raised false positive, a wider sweep would show up
in `dror-review-retrospective` as lenses getting *less* precise. The recall question
stays open on purpose, and what would settle it is an injected-defect run, not
another reading of this log.
