# A drain reads the ADR before its first ticket, and not between them

`dror-implement-adr` runs `dror-adr-review` once, after its work list is built
and before the first ticket is picked, and stops for the user on a `conflict`
that names a ticket on that list. It repairs nothing it finds, and it does not
run the check again.

## The incident

Draining ADR 0016 in geo_sense, ticket #127 — "Give each picking regime its own
settings file, seeded once" — shipped with criterion 5 unticked: "startup imports
no picking module." That clause was false before #127's implementation started.
An earlier ticket on the same ADR, #126, had already made
`SeismicMainWindow._register_modules` import both picking modules at startup to
build the Modules menu.

#127's own review and prove refused to guess and returned the question — the
right behaviour at that point. But the hour of implementation, review and repair
before it had all run against a criterion that could never pass, and **the fact
was readable in #126's and #127's bodies before either was implemented.** That
last sentence is what sizes this decision: the incident needed no ticket to have
landed, so one reading of the set, at the start, would have caught it.

## What was already in place, and what was missing

`dror-adr-review`'s `tickets` lens reads an ADR's tickets against the ADR and,
since this decision, against each other. `dror-adr-review-repair` runs it as a
standalone pass, which the user is free to skip.

The gap was sequencing. `dror-implement-ticket` cannot close it — it is given one
number and judges one contract — and the drain is the only unattended run that
holds the whole set. Telling the user to run the other skill first is not a
check.

## Considered options

**Nothing.** Rejected: the whole cost of the incident is paid in a session nobody
is watching.

**Between every pair of tickets** — the check after each round that wrote code —
was implemented first and rejected on cost. It is one `dror-adr-review` per
worked ticket, each a lens fan-out with a refuter under every finding, and a
drain of seventeen tickets pays seventeen of them to re-ask a question that is
almost always the same one. What it buys over one reading is only the conflicts
that **appear during the drain**, which are rarer than the ones written in from
the start, and it buys them at a price that scales with the ADR.

**A narrower pass than a whole review** — the drain reading the remaining tickets
itself, or invoking the review restricted to one lens. Rejected twice over: a
drain that read ticket bodies against each other would be a second copy of the
lens's procedure in play, which is the shape ADR 0043 rejected for the same
reason; and which lenses to run is `dror-adr-review`'s own judgement, stated in
its file, so a caller naming one overrides the thing it is delegating to.

**Repairing what the check finds, in the drain.** Rejected: an ADR's prose is
sharpened before its tickets are worked, and a document edit made inside a branch
of implementation work puts the decision and the code it governs in one diff. The
drain reports and does not write (ADR 0020 keeps the two hands apart).

## The decision

One check, before the first ticket. A **`conflict` naming a ticket on the work
list** is a §3a stop, with both criteria quoted. Every other survivor is recorded
in the state file, named in the summary, and left for the hand that owns it — the
ADR loop for prose, `dror-code-repair` for a `breach`. A review that writes no
report, which is its answer for a stub or superseded ADR, costs one line.

## The known limitation

**A conflict that appears after the drain starts is not caught.** Three ways it
can: a ticket run amends a body, a criterion is written against work this drain
landed, or the user edits the tracker mid-run. The check has run by then and does
not run again, so such a conflict is found the expensive way — by the
implementation of the ticket carrying it, exactly as in the incident above.

**Closing it needs the heavy version**, and the price is the one refused above:
one review per worked ticket. Nothing cheaper covers it, because the evidence is
the ticket set as it stands at each moment, and reading it is what a review costs.
A drain that has reason to expect mid-run churn — a long ADR whose tickets are
being edited while it runs — is a drain to stop and re-enter, since the check
runs again on every fresh invocation.

This is written down rather than fixed. Should it start biting, the shape of the
fix is known and is a `when` clause in one section of one file.

## Consequences

**A drain costs one ADR review.** Minutes, against an ADR's hours, paid at the
one moment when there is nothing to misattribute it to — the same argument §0's
baseline suite already makes for itself.

**The report is a resumed drain's too.** The drain mints one run tag and names
the check's report `adr-review-report-<N>-<tag>-r1.md` in the worktree's store,
so a re-entered drain's check sits beside the earlier one rather than over it.

**The nesting stays under the cap.** `dror-implement-adr` (0) → `dror-adr-review`
(1) → its lenses and refuters (2). A level shallower than the ticket chain, so
nothing here needs ADR 0043's fold.

**`conflict` widened by one case**, in the file that mints it: two tickets cut
from one ADR that cannot both be satisfied, judged on their bodies alone. Reading
what a ticket's implementation *did* stays the code axis's, which is what keeps
the `tickets` lens from becoming a second review of the tree — and it is also why
this check's answer does not go stale the moment a ticket lands.
