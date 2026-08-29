# A drain round records that it finished, not only that it started

Each round of `dror-implement-adr` writes an `outcome` into the drain's state
file: `picked` when the ticket is taken, rewritten to `finished`, `skipped` or
`stopped` when the round ends. A round entry still reading `picked` is an
interrupted round, and a resumed run puts its ticket back at the front of the
list.

The drain already kept an `attempted` set, written **before** a ticket's work
starts so that it survives a session that dies. That choice is right and it is
also what created the defect: a session killed mid-round cannot record that it
was killed, so its ticket sits in `attempted` looking exactly like one that
completed, and the next session skips it. The set prevented re-attempting, and by
doing so guaranteed the one ticket that needed re-attempting would be walked
past.

It happened. A drain on ADR 14 was stopped by hand after ticket #99 was
implemented and all ten of its criteria proved, but before its review-repair loop
and its close. The state file read `attempted: [96, 97, 98, 99]` with
`stopped_on: null` — indistinguishable from four finished tickets — and the next
run would have started on #101 and built the rest of the ADR on top of a ticket
the drain believed it had done.

`stopped_on` did not cover it. That field is for §3a, where a ticket raises a
question only the user can answer and the drain stops deliberately. A session the
user simply ends writes nothing.

So a resumed run does not trust `attempted`. It reconstructs from three pieces of
evidence that outlive any session: the round's own `outcome`; the tracker, where a
ticket open with every box ticked is implemented and unclosed; and the tree, for
whose work is sitting in it.

> **Superseded in part.** The paragraph below was written when the drain never
> closed a ticket. `dror-implement-ticket` now commits, pushes and closes its own
> ticket at its steps 6–8, and the drain closes one only where that run could
> not. So "open with every box ticked" is no longer what a completed round
> ordinarily leaves behind — a `finished` round leaves its ticket closed, and the
> two records agree. The qualification still holds for the round that ticked
> everything and did not close: a red gate, a push it could not make, or a
> session that ended between the tick and the close. The test is unchanged: a
> round entry reading `finished` settles it, `picked` means interrupted, and no
> entry at all means the boxes are the only evidence.

The tracker test needs one qualification, because this drain never closes a
ticket — closing is the user's gesture. "Open with every box ticked" is therefore
*also* what a completed round leaves behind. A round entry reading `finished`
settles it; `picked` means interrupted; **no entry at all** — no file, or one
from a drain that wrote no outcomes — means the boxes are the only evidence and
the ticket goes to the front. Re-attempting a finished ticket costs one round;
walking past an unfinished one costs the rest of the ADR.

## Considered options

**Writing `attempted` after the work instead of before** removes the ambiguity
by removing the record: a session that dies then leaves no trace at all, and the
resumed run re-attempts every ticket it already did. This is why the set was
written first in the first place.

**A separate `interrupted` field written by the dying session** cannot exist. The
session is dead; that is the whole problem.

**Inferring it from the tree alone** — a dirty worktree means the last ticket was
interrupted — was rejected because it is not reliable in either direction. The
ADR 14 case ended with a *clean* tree, since the user committed the work by hand
before the next session started, and the ticket was still unfinished.

**Rewriting a round entry** conflicts with the append-only discipline every log
in this design obeys (ADR 0009). It is allowed here and stated as an exception:
these logs are histories, and the drain file is a *current position* that is
rewritten every round already. It holds nothing worth protecting — losing it
costs one re-attempted ticket.

## Consequences

The interrupted ticket goes to the **front** of the list, not back onto it in
place, for the same reason §3a's stopped ticket does: everything after it was
planned on the assumption it was done.

A resumed run's dirty tree is no longer automatically partial work. Boxes still
unticked means the session died mid-implementation, and that is committed as
partial and skipped as before. Every box ticked with the ticket still open means
it died after the proof and before the loop, and committing *that* as partial
would abandon a finished ticket one step from done — so it is resumed instead.

The drain file now also records the `worktree` and `branch` it was written under,
so a resumed run can catch itself having adopted the wrong one (ADR 0029), which
would otherwise commit an ADR's work where nobody looks for it.
