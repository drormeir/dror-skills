# The finding id carries the minute, because a repair never commits

> **The minute is gone — superseded by
> [ADR 0050](0050-the-finding-id-carries-the-round.md), which puts the round
> where the minute was. The argument below for why `<head>-<n>` was not enough
> still holds; the part rejecting a round number does not, since ADR 0041 gave
> every review a round to write.**
>
> **Superseded in part by [ADR 0025](0025-the-finding-id-carries-the-run.md).**
> Everything below stands except the last paragraph: the id is now
> `<head>-<tag>-<hhmm>-<n>`. The minute is still there and still separates the
> rounds of one run, for the reason given here. What this document accepted and
> should not have is the closing case — two reviews of one thing inside one
> minute — which it judged by imagining two *sequential* rounds. It happened
> within a fortnight, from two **concurrent** runs sharing a working tree, a
> case not considered here at all.

The id joining a report, the refutation log and the repair log was
`<head>-<n>`: the short commit the report was written at, and the finding's
number in it. It is the only key there is — the report names no lens, and a
`file:line` moves.

`HEAD` is not unique enough to be half of it. **A repair never commits**
(ADR 0007), so a review, the repair that follows it and the review after that
all happen at one commit — and `dror-implement-ticket` runs that cycle up to
three times in one run, by design. On `<head>-<n>`, round 1's third finding and
round 2's third finding are one id. They are different defects, in two reports
of which only the last survives, and the repair outcomes recorded under that id
in `repairs.tsv` are two runs' answers to two questions. Nothing downstream can
see the collision: an append-only log has no way to notice that a key it already
holds has arrived again meaning something else.

So the id is `<head>-<hhmm>-<n>`, the minute coming from the report's own front
matter and the same `date` call the log's date column already makes.

## Considered options

**A round number** (`<head>-<r>-<n>`) was rejected: only `dror-implement-ticket`
knows what round it is on, and a review run on its own — which is the ordinary
case — would have to invent one or leave the field out, giving two id shapes for
one purpose.

**A random token** was rejected because the id is read by humans out of a report
and grepped out of a log; the minute is as short, sorts, and says something.

**Letting the report number findings on from the previous report's highest**
was rejected: it makes a review read the file it is about to overwrite, and the
numbering then depends on a file that is disposable by ADR 0002.

**Dropping the id** was considered seriously, since nothing had ever written
one — neither report in a real store carried an id, and `refutations.tsv`'s
header still had nine columns. It was rejected because the question the logs
exist to answer ("what became of *this* finding once somebody tried to fix it")
has no other key, and the failure was that the id was optional in tone, not that
it was wrong.

## Consequences

Every finding carries one, survivors and kills alike, and a report without them
cannot be joined to anything: `dror-code-repair` writes no `repairs.tsv` row it
cannot key, and the log rows answer only the questions that need no id. The
skills say so plainly rather than describing the id as a nicety.

Rows already in the logs are left exactly as they stand — those with no id, and
those with an id in the older `<head>-<n>` shape. Both shapes read as ids, and
which one a row carries says when it was written. An id invented after the fact
names a report nobody kept (ADR 0009's append-only rule).

Two reviews of one thing inside one minute would still collide. That is
accepted: each one spawns a lens fan-out and an unbounded refuter pass, and the
run that could do it twice in sixty seconds is not the run these logs are for.
