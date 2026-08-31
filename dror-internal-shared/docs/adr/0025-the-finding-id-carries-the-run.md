# The finding id carries the run, because two runs share a tree

The id joining a report, the refutation log and the repair log is
`<head>-<tag>-<hhmm>-<n>`: the short commit, the run's tag, the report's minute,
and the finding's number in it. It was `<head>-<hhmm>-<n>` (ADR 0022), and before
that `<head>-<n>`.

Each part answers something none of the others can. `HEAD` says which commit —
and is not enough alone, because a repair never commits (ADR 0007), so a review,
its repair and the next review all sit at one. The **minute** separates those
rounds, which is ADR 0022's reasoning and still holds: a repair runs the full
suite, so rounds are minutes apart by construction. The **tag** separates two
runs that share the working tree, and nothing about *their* timing is under
anyone's control.

ADR 0022 saw that last case and accepted it: "two reviews of one thing inside one
minute would still collide… the run that could do it twice in sixty seconds is
not the run these logs are for." That judgement was about two *sequential*
rounds, which indeed cannot happen in sixty seconds. It never considered a second
**agent** in the same checkout, which can start whenever it likes.

It happened within a fortnight. `refutations.tsv` holds five ids minted twice at
`22a7d02`, one set about drag-and-drop and the other about the Top View panel;
three of them carry two different outcomes in `repairs.tsv` under one key. There
is no way to tell which repair answered which finding, and the rows cannot be
repaired — an id invented after the fact names a report nobody kept.

## Considered options

**A round number** stays rejected for ADR 0022's reason, plus a new one: it
separates rounds of one run and does nothing at all about two runs.

**A random token instead of the minute** was ADR 0022's rejected option, on the
grounds that the minute "is as short, sorts, and says something". Both are now
in, and the rejection's premise is gone regardless: ADR 0024 has every review
mint a tag whether or not the id uses one, so the tag costs nothing extra here.

**Dropping the minute now that a tag exists** was rejected. The tag is per *run*,
not per round — `dror-code-review-repair` deliberately reuses one tag across every
round so its rounds share one report file — so `<head>-<tag>-<n>` would collide
across rounds exactly as `<head>-<n>` did.

**A longer tag** was not needed. Four hex characters collide at odds that are
negligible against the number of runs a person makes, and the tag is one of four
parts rather than the whole key.

## Consequences

The id now has three shapes in the wild by age. Rows already in the logs are left
exactly as they stand, on ADR 0022's own terms — which shape a row carries says
when it was written.

That makes one rule binding on every consumer: **match an id whole, never split
it into parts.** A join that split on `-` and read position 2 as the minute would
read a tag as a time on the new shape, and produce a wrong answer rather than an
error. `dror-code-repair` copies the string verbatim; `dror-review-retrospective` joins on
the whole field and, where an id still appears twice, **reports the collision and
drops the pair** rather than counting one of them — attributing a repair's answer
to the wrong finding is worse than a smaller denominator.

Nothing detects a collision at write time. An append-only log cannot notice that
a key it holds has arrived meaning something else, which is why the cost of
getting this wrong is paid entirely by a later reader, and why the shape is
worth changing twice.
