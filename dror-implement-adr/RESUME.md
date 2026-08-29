# Resuming a drain

The read-side of resumption, read whole when `SKILL.md` §3's check found an
earlier session's leavings — a state file on disk, a branch ahead of its remote,
or an open ticket with every criterion ticked. The write-side — what each round
writes to the state file and when — stays in `SKILL.md`, beside the steps that
fire it.

## Reconstruct; never trust `attempted`

The `attempted` set is written **before** a ticket's work starts (`SKILL.md`
step 3), which is what makes it survive a session that dies — and is also what
makes a ticket that was interrupted look exactly like one that completed. A
session killed mid-round cannot record that it was killed. So a resumed run does
not trust `attempted`; it reconstructs, from three pieces of evidence that
outlive any session (ADR 0031):

1. **The round's own outcome.** Each round entry carries an `outcome` — see the
   state-file section in `SKILL.md` — set to `picked` when the ticket is taken
   and rewritten to `finished`, `skipped` or `stopped` when the round ends. **A
   round still reading `picked` is an interrupted round**, whatever `attempted`
   says. Take its ticket out of `attempted` and put it at the **front** of the
   list, for the same reason §3a's stopped ticket goes first: the session ended
   in the middle of it, and everything after it in the list was planned on the
   assumption it was done.

2. **The tracker, which is the authority when the file is not there.** The state
   file is disposable and may be absent, stale, or from a drain that never wrote
   outcomes. §2's table has the fact that does not depend on it: **a ticket that
   is open with every acceptance criterion ticked is implemented and unclosed**.
   That ticket goes to the front of the list on the strength of the boxes alone,
   with no state file needed.

   **Except where a round entry says `finished`.** Step 7 closes a ticket it
   finished, so "open with every box ticked" is ordinarily a round that did not
   reach its close — but not always: a round whose gate came back red ticks
   nothing further, leaves the ticket open and still ends. So the test is: a
   round entry reading `finished` settles it and the ticket stays done; a round
   entry reading `picked` means interrupted; and **no entry at all** — no file,
   or a file from a drain that wrote no outcomes — means the boxes are the only
   evidence there is, and a ticket in that state goes to the front.
   Re-attempting a finished ticket costs one round and changes nothing; walking
   past an unfinished one costs the rest of the ADR. Name which of the three
   cases each ticket fell into.

3. **The tree, for whose work is sitting in it.** A dirty worktree at the start
   of a resumed run belongs to the ticket whose round reads `picked`. Name that
   ticket before anything is committed — the dirty-tree section below says what
   happens next, and it turns on whether that ticket's boxes are ticked.

## Check you are in the right place

The state file records the `worktree` and the `branch` it was written under. The
shelf's re-entry rules adopted a directory and a branch of its own accord; where
either disagrees with the file, stop and say both — a drain resumed onto the
wrong branch commits this ADR's work somewhere nobody will look for it, and the
file is the only thing that can catch it.

## The list is rebuilt; the file's memory is kept

A resumed run still runs §2's scan, and builds its list fresh. Sessions are
separated by however long the user took to answer, and the tracker moved in
between — tickets closed by hand, criteria ticked, a new ticket filed against
this ADR. The one-scan rule holds *within* a run, where the loop is the only
thing changing the tree; it says nothing about a run that starts over. What the
file carries across is what the tracker cannot say: which numbers this drain
already tried, and which question it stopped on.

**With the stopped ticket taken back out of that set.** It is the one number a
resumed run must pick *first*, not skip: the run before it stopped precisely so
the user could answer, and a resume that inherits it as "attempted" walks past
the answer it was waiting for and works the rest of the ADR around the hole. So
drop it from **attempted**, and pick it before anything else — unless the user's
answer was to leave that ticket alone, which is itself an answer and is recorded
as one.

**An owed stop is resumed only after the user has pushed.** Its answer is the
hand-back command and then the push, and until both are made the ticket's commit
sits unpushed in the worktree: a fresh run picks the ticket first, its step 0
refuses the unpushed commit, step 5 holds it again, and step 6 stops on the same
word. That is the stop holding, not the drain failing — say so in one line, and
name the push as what clears it.

## A dirty tree at start

A resumed run's dirty tree is not automatically partial, and this is where the
distinction is made. A tree that is dirty when the loop starts is the previous
session's interrupted ticket — the state file says whose, which is the one thing
separating it from pre-existing dirt (§3a's refusal case), and the reason that
file is written before the work starts rather than after. What it is *worth*,
though, depends on the ticket, and there are two cases that must not be run
together:

- **Boxes still unticked** — the session died mid-implementation. This is the
  partial work §3a's stall rule describes: commit it under the number, marked
  partial, and it is skipped like any stall.
- **Every box ticked, ticket still open** — the session died *after* the work and
  the proof and *before* the review-repair loop and the close. Nothing here is
  partial. Committing it as partial and moving on abandons a finished ticket one
  step from done, and leaves the rest of the ADR built on top of a ticket the
  drain believes it never did. **Resume that ticket instead**: it goes to the
  front of the list, and its round runs from where it was cut off.

`dror-implement-ticket` is a whole run and will re-tread what it must; the boxes
it already proved are ticked and its step 4 reads them off the ticket rather than
off memory, so a resumed ticket costs the review-repair loop and not the
implementation. Say which of the two cases fired, and on which number.

## Report

Say in one line what resumption found — the amended list's front, the case each
moved ticket fell into, and the place-check's answer — then return to §3's round
loop.
