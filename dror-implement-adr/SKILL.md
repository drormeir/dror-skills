---
name: dror-implement-adr
description: Work one ADR's ticket list to exhaustion on a branch of its own - a side worktree off the remote head, one ticket at a time through dror-implement-ticket, committed ticket by ticket, stopping for the user the moment a ticket raises a question only they can answer. Use when the user names an ADR number and asks to implement it, drain it, or work its remaining tickets.
disable-model-invocation: true
---

# dror-implement-adr

One ADR goes in. The skill prepares a working directory of its own, then works
the ADR's ticket graph one ticket at a time until nothing is left that can be
worked on — or until a ticket raises a question that is the user's to answer, and
then it stops and asks (§3a).

It owns no implementation. It is `dror-show-tickets` for the map and
`dror-implement-ticket` for the work, plus the isolation, the loop and the
bookkeeping between them — the same relationship `dror-implement-ticket` has to
`dror-prove` / `dror-review` / `dror-repair`.

The ADR number is this skill's one argument. Without it, ask for it.

**Every delegated skill is a step of this one, not a hand-off.** Each ends on a
reply contract of its own — `dror-show-tickets` "nothing else", `dror-review`
"STOPS", `dror-implement-ticket` its summary. Those govern **that step's output,
not this run's**: read every such "stop" as "this step is finished", and return
in the same turn to the numbered step that invoked it. A drain that ends on a
sub-skill's closing sentence has worked no ticket at all, and that is the
ordinary way this skill fails, not a rare one.

No tension with §0a: a skill of this chain is a step, while the lens and refuter
agents `dror-review` spawns beneath itself are real spawns that start where the
session started. Both are true, at different depths.

**One ticket at a time, never two.** Each is written on top of the last one's
commit, and §0's layout exists so that one ticket's diff is one ticket's review.

**Why the worktree.** Several ADRs are worked in parallel, in separate sessions,
against one repository. Each session therefore gets a checkout of its own, so
one run's tree is never another run's review scope, and the user's own checkout
stays free for the work they are doing by hand.

## 0. Prepare the branch and the worktree

`../dror-internal-shared/WORKTREE.md` — the shelf beside this skill — holds the
naming, placement, guards, environment and re-entry rules for an ADR worktree, in
one copy. Read it whole before creating or adopting anything, and take this run's
path and branch from it. It is not restated here.

What this skill owes it is the number: the worktree is `<repo>-adr-<N>` on branch
`adr-<N>`, both from the ADR this run was given.

**Its preflight is a step of this one, not a hand-off.** Run it before the first
ticket and report its four lines; a failure stops the run here, which is the
whole point of asking at a moment when there is nothing to blame the answer on.
Everything past §0a assumes an environment that was proved rather than built.

## 0a. Carry the path into every delegated prompt

Resolve the worktree to an **absolute** path once, and put it in every prompt
this skill hands to another skill. Not as background — as the directory that
prompt's commands run in, named in its first sentence:

> All commands run in `<absolute worktree path>`. It is a `git worktree`, not
> the primary working directory; use `git -C <path>` for every git command and
> read and write files under that path only.

**This is the whole isolation, and prose is the only thing holding it.** A
changed working directory is **not inherited by a spawned agent**: it starts in
the session's primary working directory — the user's checkout — whatever `cd`
ran here. `dror-review` spawns a lens agent per lens and a refuter under each,
so a step merely *expected* to be in the worktree runs its `git status` and
`git merge-base` against the user's tree, reports their uncommitted work as this
ticket's, and lets `dror-repair` edit it under this ticket's number. Silently,
and by default rather than by accident — which is what §0 built the second
checkout to prevent.

Nothing downstream takes a directory argument, which is why this is stated in
words rather than passed: say it in the prompt, and say it again in the prompt
each round, since a prompt is all a fresh agent has.

**Check this skill's own commands too**, cheaply: `git -C <path> rev-parse
--show-toplevel` must answer the worktree before the loop starts and after any
step that could have moved. It is a backstop and not the fix — it can only see
the commands this skill runs itself, never the ones inside a subagent, and a run
that leans on it instead of on the prompt has guarded the one place that was
never at risk.

## 1. The project facts warm themselves

**Do not invoke `dror-internal-project-facts` on its own.**
`dror-implement-ticket` invokes it as its own first step, every ticket, and
every ticket after the first reads the cached `facts.md` — so a separate call
here buys nothing the first ticket does not buy anyway. (`dror-show-tickets`
does not use it: it is convention-bound and names its own commands.)

What matters is not *that* it runs but **where**: the cache lives in the store of
whatever checkout the gather ran in, so a gather in the user's tree leaves the
worktree paying for its own every round. §0a's sentence on every delegated
prompt is what puts it in the right place.

## 2. Map the ADR

Invoke `dror-show-tickets` for ADR `<N>`, with §0a's sentence — it reads the
tracker rather than the tree, but it reaches the repo for the ADR file and for
what landed, and one skill in this run answering from a different checkout is how a
row comes back `Ready` that is not. Its table is the loop's input: which tickets
are `Ready`, which are blocked and behind what, which can close.

**This is the only scan of the run**, so read the table properly here rather than
leaning on a later one to correct it — §3 builds its whole work list from it and
never asks again.

Its table is a step's output and not this run's reply: show it, and continue at
§3 in the same turn. Its "nothing else — no plan, no next steps" is that skill
refusing to invent work of its own, and the loop below is not invented work.

That skill's vocabulary is convention-bound — it knows this project's tracker —
and this skill inherits that binding by using its words. Nothing else here names
a tracker.

## 3. The loop

**The ADR is scanned once.** §2's table is the whole input, and the loop below
re-reads only the boxes of the ticket it just worked. Rescanning every round
would answer a question the table has already answered: `Blocked by #NN` and
`Awaiting #NN` are a dependency graph, the work list built from them is a
**topological order** of it, and a loop that works one ticket to completion
before starting the next satisfies every dependency by construction. No round can
uncover a blocker the first scan did not show, because no round can create one.

### Build the work list, once

**Sort it properly.** The list is a topological order of the ADR's dependency
graph, and the one property everything below rests on is this: **no ticket on the
list is blocked by a ticket that comes after it.** Table order is not that
property — issue numbers usually agree with dependency order and are not required
to — so derive the order rather than assuming it.

**The graph.** Take every row of §2's table that is not `Closed` and not
`Can close`; those two are done. A `Can close` row is a ticket some earlier run
finished and did not close — no gate of this run's has been over it, so it is
neither implemented again nor closed here: report it, and let the user close it
or re-run its ticket. Each remaining row is a node. Its edges come from its status: a
`Blocked by #NN` or `Awaiting #NN` row **depends on `#NN`** — one edge per number
named, since a row may name several. `Ready` names none, which is what `Ready`
means. No other column is read for edges, and no ticket body is opened to look
for more: `dror-show-tickets` owns the reading of this tracker, and a dependency
this skill invents is one the table can never confirm.

**A dependency on a ticket outside the node set is already satisfied or is not
this run's**, and which one the table says: `#NN` shown as `Closed` is satisfied
and the edge is dropped; `#NN` absent from the table altogether belongs to
another ADR, and the row waiting on it is set aside as **not workable here**,
named in the summary and on no list.

**The sort.** Repeatedly take the lowest-numbered node whose dependencies are all
already on the list, append it, and continue until no node is left. Lowest-numbered
is the tie-break and nothing more — it keeps the order stable, reproducible
across runs, and as close to the table's own as the graph permits.

**The spec issue is no node either.** It is the ADR's parent, it carries no
criteria of its own, and `dror-show-tickets` answers its status from the child
set — `Awaiting` every open child, and `Can close` once none are left. So there
is nothing on it for `dror-implement-ticket` to implement, and its dependencies
are the whole list by construction. Leave it out of the sort, and report it at
the end: **can close** where the drain closed every child, and otherwise which
children it is still waiting on.

**Set-aside nodes leave first, with everything downstream of them.** A node
waiting on a ticket that is not workable here — outside the ADR, or `Needs your
call` — can never be taken, and neither can anything waiting on *it*. Remove that
whole tail before sorting, so what is left is a graph the sort can finish;
otherwise the cycle test below fires on tickets that are merely parked.

**A round that can take nothing while nodes remain is a cycle**: those tickets
block each other, no order exists, and no amount of working them will produce
one. That is not this loop's to untangle — name the tickets in the cycle and go
to §3a. Everything the sort placed before the cycle was found is still a valid
list; say so, and let the user choose between working it and fixing the graph
first.

**A `Needs your call` row is no node, and is not passed over silently.** That
status is the tracker saying the decision is the user's — the one §3a exists for,
except that it was already there before this run started rather than raised by
it. Name it now, on screen and in the state file, drop it from the node set, and
work what the sort produces anyway. Anything that depends on it goes with it, set
aside as not workable here for the same reason: the sort would never place a node
whose dependency is on no list. **But an ADR
whose list is empty while such a row stands is a stop, not a finish** — go to §3a
and ask, rather than reporting a drained ADR with an undecided ticket in it. A row
whose status this skill genuinely cannot read is a stop the same way, at the
moment the list is built rather than at the end.

### What an earlier session left, if anything

**A virgin ADR pays nothing for this section.** No state file, no branch ahead of
its remote, no open ticket with every box ticked — the three questions below all
answer "nothing", in one `gh` call the scan already made and one `git` call, and
the list §3 built stands as it is. Run them anyway: their cost is a sentence, and
what they prevent is a resumed drain working *around* a finished ticket for the
rest of the ADR.

The `attempted` set is written **before** a ticket's work starts (step 3 below),
which is what makes it survive a session that dies — and is also what makes a
ticket that was interrupted look exactly like one that completed. A session
killed mid-round cannot record that it was killed. So a resumed run does not
trust `attempted`; it reconstructs, from three pieces of evidence that outlive
any session (ADR 0031):

1. **The round's own outcome.** Each round entry carries an `outcome` — see the
   state file below — set to `picked` when the ticket is taken and rewritten to
   `finished`, `skipped` or `stopped` when the round ends. **A round still
   reading `picked` is an interrupted round**, whatever `attempted` says. Take
   its ticket out of `attempted` and put it at the **front** of the list, for the
   same reason §3a's stopped ticket goes first: the session ended in the middle
   of it, and everything after it in the list was planned on the assumption it
   was done.

2. **The tracker, which is the authority when the file is not there.** The state
   file is disposable and may be absent, stale, or from a drain that never wrote
   outcomes. §2's table has the fact that does not depend on it: **a ticket that
   is open with every acceptance criterion ticked is implemented and unclosed**.
   That ticket goes to the front of the list on the strength of the boxes alone,
   with no state file needed.

   **Except where a round entry says `finished`.** Step 7 closes a ticket it
   finished, so "open with every box ticked" is ordinarily a round that did not
   reach its close — but not always: a round whose gate came back red ticks
   nothing further, leaves the ticket open and still ends. So the test is: a round entry reading
   `finished` settles it and the ticket stays done; a round entry reading
   `picked` means interrupted; and **no entry at all** — no file, or a file from
   a drain that wrote no outcomes — means the boxes are the only evidence there
   is, and a ticket in that state goes to the front. Re-attempting a finished
   ticket costs one round and changes nothing; walking past an unfinished one
   costs the rest of the ADR. Name which of the three cases each ticket fell into.

3. **The tree, for whose work is sitting in it.** A dirty worktree at the start
   of a resumed run belongs to the ticket whose round reads `picked`. Name that
   ticket before anything is committed — the rule at §3's end says what happens
   next, and it turns on whether that ticket's boxes are ticked.

**Then check you are in the right place.** The state file records the `worktree`
and the `branch` it was written under. The shelf's re-entry rules adopted a
directory and a
branch of its own accord; where either disagrees with the file, stop and say both
— a drain resumed onto the wrong branch commits this ADR's work somewhere nobody
will look for it, and the file is the only thing that can catch it.

Say in one line what this section found, including when it found nothing: a
resumed drain that prints no such line is indistinguishable from one that never
looked.

### The clock

You have no clock of your own, so the drain reads one: `date +%s`, epoch
seconds, arithmetic without a date library. Three moments and no others —
**once** here before the first round, then once at each round's step 1 and once
at its step 7. Every duration below is a subtraction between two of them, so a
round costs two `date` calls and the run costs one more.

The first round's step 1 reading is the run's start, near enough: drop the
`elapsed` field from that one line rather than printing `elapsed 0m`.

Write all three into the state file — the run's start, and per round its start,
its end and the ticket's number — because a mid-drain compaction loses them
exactly as it loses the work list, and an elapsed time recomputed from a
half-remembered start is worse than none.

**A resumed run starts its own clock, and inherits the durations.** Wall-clock
between sessions is however long the user took to answer, so elapsed is always
*this* run's; but a ticket that took eleven minutes yesterday is still a sample
of how long a ticket takes here, so the ETA's mean reads the earlier rounds out
of the state file along with this run's. Say `elapsed 20m this run` where the
file shows earlier ones, or the number reads as the whole ADR's cost.

### Then, each round

1. Take the next ticket off the list. Empty: the loop is done — go to §4.

   **Then read the clock and say where the drain is, on one line, before
   anything else in the round:**

   ```
   [ADR <N>] ticket <i>/<total> · #<ticket> · starting · elapsed <so far>
   ```

   `<i>` counts every ticket this loop has taken off the list including this one,
   and `<total>` is the work list's length as §3 built it — not the ADR's ticket
   count, which includes the ones the graph excluded. Neither number is computed
   from anything new: the list, what remains of it and the attempted set are
   already in hand, and already written to the state file at step 3.

   This line is not decoration and it is not optional. A round is one
   `dror-implement-ticket` run, which is minutes of a chain of sub-skills each
   reporting on itself, and §Present's table does not arrive until the whole ADR
   is done — so a user watching a drain has, without this line, no way to tell a
   run on its second ticket from one on its last. **Emit it as your own text, not
   inside a tool call**, or it is written where only you can read it.
2. **Skip it where the ticket itself says to.** The list is a plan made once and
   the tree has moved under it: a ticket already closed by hand mid-run, or one
   whose blocker ended up stalled, is skipped with a line saying which. This is
   the one thing the dropped rescan used to catch, and reading the ticket at the
   moment it is picked catches it for one ticket's cost instead of the table's.

   A skipped ticket still gets step 7's closing line, with `skipped — <why>` in
   place of the verdict. It spent a round's place in the list, so it advances the
   count like any other; a skip that prints only step 1's line reads as a ticket
   still running.

   Keep the skipped numbers, and keep a set of **attempted** ones. A set, not a
   queue: a ticket whose run left criteria unproven is not re-picked by this loop,
   and nothing ever returns to a member, so there is no order to keep — what the
   set is for is the resumed run, which reads it back from the state file.
3. Write the state file (below) with the ticket marked attempted **and its round
   entry's `outcome` set to `picked`**, before the work starts, not after. Step 7
   rewrites that one word when the round ends; until it does, the entry says a
   ticket was taken and never finished, which is exactly what it means.
4. Invoke `dror-implement-ticket` with that number, its prompt opening with
   §0a's sentence. "In the worktree" is not a place this skill can put it — that
   run's own step 0 asks `git status` and `git merge-base` in whatever directory
   its agent starts in, and the answer decides what the whole chain reviews.

   That run ends on a summary of its own. **It is one ticket's summary, not the
   drain's**: read it, record it, and continue at step 5 in the same turn.

   Four things stop that run — a repo tracking no tickets, a dirty or unpushed
   tree, an open blocker, an implementation it could not honestly finish — and
   two of them, the tree and the blocker, are the **user's to override**. It is a
   step of this run, so it puts those to the user itself, and that is the right
   place for them: an override answered there continues that ticket where it
   stood, while the same answer given to the drain would have thrown the ticket's
   half-done work away. **So let it ask, and answer nothing on the user's
   behalf** — the loop wanting the drain to keep moving is precisely the interest
   that must not decide an override.

   Where it ends stopped — the user declined the override, or it was one of the
   two nobody can override — the drain stops with it: see §3a.
5. **Check the ticket's commit and its push.** Both are
   `dror-implement-ticket`'s own steps 6 and 7 — one commit naming the ticket,
   staged by path, its message answering to the boxes as they stood, pushed to
   `origin/adr-<N>`. So this step **verifies** rather than acts: `git log
   --oneline <the previous ticket's tip>..HEAD` for that commit,
   `git status --porcelain` for a clean tree, and `git rev-list --count
   @{upstream}..HEAD` for `0`. All three hold, and there is nothing to do here;
   record the sha with the round.

   **A dirty tree, no commit, or an unpushed one is this skill's to finish** — a
   run that stopped early, one whose commit missed a file, or one that refused
   the push because the branch had no upstream. Commit what is left under the
   ticket's number and push it, by that skill's rules and for its reasons, which
   are worth keeping in front of you:

   - **Read step 6's word before pushing.** A commit the ticket run left
     unpushed on a verdict of **owed** is unpushed on purpose: the hand-back
     command it returned is `/dror-review` over the unpushed work, and a push
     here would leave that command an empty diff to read. Leave it, and let
     step 6 stop the drain with the command and the push both in the user's
     hands.
   - **A green full suite before the commit.** The chain's rule is that the
     suite is owed to the last code change, and a run that stopped early may
     have made none since its last edit: run the project's full suite, lint and
     the type-check, and name the run. Red, commit all the same, marked partial
     — step 7 then leaves the ticket open on the gate. Otherwise the commit is
     pushed carrying code nothing has run, the next ticket is written on top of
     it, and the first full suite to see it fails under a later ticket's number.

   - **Read the boxes first.** A `- [ ]` still open is either unfinished work or
     a verdict nobody recorded, and a commit that reads as finished over one
     destroys the distinction. This reading decides what the message may claim;
     step 7 reads them again, for a different question — whether the ticket
     closes.
   - **The store stays out of the commit.** `<worktree>/.claude/dror-skills/`
     holds this run's state file and review reports, and nothing gitignores it
     for you — stage by path, never `git add -A`, or the drain's bookkeeping
     lands in the branch's history.
   - **Name the ticket, never with a closing keyword.** `Closes #N`, `Fixes #N`,
     `Resolves #N` are not references — where the tracker reads commit messages
     they *are* the close, performed by the push, whatever the boxes say. The
     ticket does get closed — by the ticket run's step 8, or by step 7 here —
     and that is exactly why the keyword must not do it: those two read the
     boxes, the gate and the push first, while a keyword closes the moment this
     branch reaches the default one, silently, long after anyone is reading, and
     with none of the three checked. Write `#N` or `for #N`.

   **What the push settles, and why nothing after it reviews.** `dror-review`
   takes its scope from `git merge-base @{upstream} HEAD`, so once the ticket is
   pushed its diff is `@{upstream}..HEAD` and empty: no round run from here can
   see it. That is why every round this ticket gets is spent inside the ticket
   run, its step 5 included, and why an unpushed commit found here is finished
   with a push rather than with one more review — the window closed with the
   ticket run's own last step, not with this one. The one exception is the
   **owed** commit above, which the ticket run kept inside the window on
   purpose.
6. **Record the ticket's verdict.** `dror-implement-ticket` ends on one word —
   **owed**, **optional** or **no** — for whether another `dror-review` /
   `dror-repair` round is wanted. Write the word and its grounds into the state
   file with the round, and take it as given: it is that run's judgement of its
   own diff, made while that diff was still reviewable.

   **This step runs no round of its own.** On **optional** or **no** it cannot:
   the ticket run pushed at its step 7, so `@{upstream}` is `HEAD` and
   `dror-review`'s scope — the unpushed work — is empty; a round invoked here
   would review nothing and report that as convergence. On **owed** the commit
   is unpushed and the diff is there to read, and the drain declines by rule:
   the ticket run has already spent its cap and step 5's two rounds on it, and a
   ticket not converging after that gets the user, not a sixth round under the
   drain's name. So the words mean:

   - **optional** or **no** — the ticket is settled. Optional is the user's
     call to make later, on the branch, which is what the branch outliving the
     run is for.
   - **owed** — the ticket run reached its cap with a case for continuing still
     live, and **the drain stops**: a ticket not converging after that many
     rounds does not get another one built on top of it. Name the ticket, say
     what its last round found, carry its hand-back command verbatim, and go to
     §3a. The work is committed and, by the ticket run's own step 7,
     **unpushed** — which is what keeps that command live: `dror-review` reads
     the unpushed work, and a push would empty it. Step 5 above leaves it that
     way, and §3a hands the user the command and the push together.

   **An owed whose ground is *a criterion only the user can settle* is the same
   stop for a different reason** — no round can move it, and the answer is the
   user's. It goes to §3a with that ground named, not with a command to run.
7. **Read the ticket's state, and close it only where the ticket run could not.**
   The close is `dror-implement-ticket`'s own step 8, made against three
   conditions — every box ticked, the full-suite gate green over the tree as it
   finally stands, and the push done. So `gh issue view <N> --json state` is this
   step's first question, and a `CLOSED` answer ends it: record it with the round
   and carry on.

   **`OPEN` is either a condition that did not hold, or a step that never ran.**
   Ask which, since they are settled differently:

   - The ticket run named the condition — a box still open, a red or missing
     gate, a `criterion wrong` waiting on the user. **Leave it open**, say which,
     and carry on. Nothing here overrules that judgement; it was made with the
     tree in front of it.
   - The ticket run never reached its step 8 — it stopped early, or step 5 above
     finished a commit and a push on its behalf. Then this step makes the close,
     on those same three conditions, read fresh: the `- [ ]` count in the body as
     it stands now rather than what any run reported ticking, the gate run made
     after the last code change and quoted, and the push confirmed at step 5. Any
     of the three failing leaves the ticket open with a line saying which.

   Closing at all is deliberate, and the objection it overrules is real: every box
   on this ticket was ticked by this same chain, so the close inherits whatever
   the proofs were worth. It is taken because reopening is one command and the
   alternative is a queue of finished tickets nobody can tell from unfinished
   ones. Where a criterion's evidence is thin the verdict itself says so —
   `unproven` and `partial` do not tick, so they hold the ticket open on their
   own, which is the check that matters rather than the gesture.

   **Rewrite this round's `outcome`** from `picked` to `finished`, `skipped` or
   `stopped`, in the same write as the counts below. This is the round's only
   claim to have ended, and a resumed run reads nothing else for it — a round
   that reports on screen and never rewrites the word is a round the next session
   will correctly treat as interrupted.

   Note the shape this leaves: a `finished` round leaves its ticket **closed**,
   so the two records agree and the resume section's tracker test has nothing to
   misread. The shape that does need the state file is the other one — a ticket
   whose boxes are all ticked and which is still **open**, because its gate was
   red or the round ended between the tick and the close. Left to the tracker
   alone that reads as implemented-and-unclosed and goes to the front of the
   list; a round entry reading `finished` is what says otherwise, and the tracker
   wins only where the file has nothing to say.

   **Then read the clock again and close the round with step 1's counter, two
   lines:**

   ```
   [ADR <N>] <done>/<total> done · <left> left · <stalled> stalled · #<ticket> <verdict>
   [ADR <N>] #<ticket> took <d> · elapsed <total so far> · ETA ~<estimate> for <left> left
   ```

   `<done>` counts the rounds that finished — worked or skipped — `<left>` is
   what remains on the list, and `<stalled>` counts the tickets that ended
   unfinished so far, which is the number that says whether the drain is going
   well or merely going. `<verdict>` is the word step 6 recorded, as that loop
   gave it, or `skipped — <why>`; §Present's rule against re-wording it holds
   here for the same reason.
   The counts are the state file's, written the same round, so the line and the
   file cannot disagree.

   `<d>` is this round's step 7 reading minus its step 1 reading, and
   `<elapsed>` is step 7's minus the run's start. Round both to something a human
   reads at a glance — `12m`, `1h 40m` — since a drain measured to the second
   claims a precision it does not have.

   **The ETA is a mean of the worked rounds, times what is left**, and the two
   words in that sentence are what keeps it honest:

   - **Worked.** A skipped round takes seconds and is not a sample of anything;
     averaging it in halves the estimate and the drain then runs twice as long as
     it promised. Skips are excluded from the mean, and so are stalls — a ticket
     that stopped early spent less than one that finished. Where a round was
     skipped or stalled, that line's ETA carries `(from <k> worked)` so the
     reader can see how thin the mean is.
   - **Mean, not a trend.** Tickets differ by more than any curve fitted to three
     of them can predict, so take the plain mean and do not weight the recent
     ones. The `~` is doing real work in that line.

   **One worked round is not an estimate.** Print `ETA — one sample` rather than
   a number, and start estimating at the second. And where every round so far was
   skipped or stalled, there is no mean at all: print `ETA — none yet`, never a
   number derived from the elapsed time divided by rounds, which is the same
   mistake with the arithmetic hidden.

   The estimate assumes every remaining ticket is worked. Some will be skipped,
   so the ETA is an upper bound rather than a guess — worth saying once, in the
   summary, not on every line.

   A stop at §3a prints this line too, before §3a's three lines: the last thing
   on screen should say how much of the ADR the stop leaves untouched.

Termination: every round takes one ticket off the list and none puts one back,
and the extra review rounds inside a ticket are capped at two. The list is built
once and only shrinks, which is a stronger guarantee than the rescanning loop
had — there, termination rested on **attempted** growing.

**The state file.** A compaction mid-drain would lose the loop's state — the
list, what is left of it, and which numbers were attempted — and "tried and
stalled" is indistinguishable from "never tried" when read back from the tracker.
So write it to `<worktree>/.claude/dror-skills/drain-<ADR>.json` each round: the
ADR, **the worktree path and the branch**, the work list as built, what remains
of it, the attempted and skipped
numbers, one line per round saying what happened, **the run's start and each
round's start and end in epoch seconds**, and — where §3a ended the run —
**which ticket stopped it and what was asked**. Read it at the start of a run for
the attempted and skipped numbers, the stopped ticket, and the earlier rounds'
durations that the ETA's mean is built from.

**Every round entry carries an `outcome`, and it is written twice.** `picked`
when the ticket is taken, in the same write that adds it to `attempted`; then
rewritten in place to `finished`, `skipped` or `stopped` when the round ends.
Both writes matter and neither is the other's substitute: the first is what makes
a dead session's ticket recoverable, and the second is the only thing that
distinguishes a ticket this drain completed from one it was interrupted in the
middle of. A round entry left at `picked` **is** that signal, and the resume
section above is what reads it.

**Rewriting a round entry is allowed here and nowhere else.** These are the logs'
opposite: `refutations.tsv` and its neighbours are append-only histories, and
this file is a *current position* that is rewritten every round by design. It
holds no history worth protecting — losing it costs one re-attempted ticket, as
below.

**A resumed run still runs §2's scan, and builds its list fresh.** Sessions are
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

Like every store in this chain it is disposable: unreadable is a miss, never an
error, and the cost of losing it is re-attempting a stalled ticket once.

## 3a. Stop for the user's judgement

A round that **stopped** rather than finished ends the drain, and the user is
asked. `dror-implement-ticket` refusing on an open blocker, refusing on a tree it
found dirty, ending on a criterion it could not honestly implement, a ticket
still **owed** at its cap or owed on a criterion only the user can settle, a
`Needs your call` row that is all the ADR has left,
a `dror-show-tickets` row whose status this skill cannot read at all — each of
those is a call about *what should be built*, and this loop's judgement is only
about *what to build next*. **Unreadable is the test in that last one**, not
unpickable: a status the table minted and this skill simply does not act on is
step 2's business and never a stop.

**Do not carry on to the next `Ready` ticket.** Continuing costs the user the one
thing the stop is worth: an answer given now applies to a tree with one ticket of
work in it, while the same answer given after four more tickets applies to a tree
whose later work was written against the guess. So: finish the ticket's
bookkeeping — commit **whatever this run wrote to the tree** and nothing else
(the store stays out, as at step 5), push it — except a commit whose verdict is
**owed**, which step 5 left unpushed so its hand-back command still has a diff to
read, and which the user pushes after running it — write the state file, then say in three lines what stopped, on which ticket, and what
the choice is. Then stop, and wait. Resuming is a fresh run of this skill; the
state file makes it cheap.

"Whatever this run wrote" is the whole of it, and on one of the stop causes that
is **nothing**: a ticket refused because the tree was already dirty wrote no
line, and committing what it found would put another ticket's work under this
one's number — which is the refusal happening anyway, one step later and under a
commit message that lies about it. Report the dirt, name it as pre-existing, and
commit none of it.

The one thing that is **not** a stop is a ticket the graph itself excludes: a
ticket awaiting a stalled one is skipped at step 2 with a line saying so, which
is the graph answering without anybody's judgement. It is named in the summary as
**blocked behind a stall**, and it is the reason the work list is a plan rather
than a promise.

**A stall still commits.** Whatever it wrote before it stopped is in the tree,
and `dror-implement-ticket`'s own step 0 refuses a dirty tree — so a stall left
uncommitted jams the very next ticket. Commit it under the ticket's number,
marked as the partial work it is, push it with the rest, and skip step 6: there
is no verdict on a ticket that was never implemented.

**A resumed run's dirty tree is not automatically partial, and this is where the
distinction is made.** A tree that is dirty when the loop starts is the previous
session's interrupted ticket — the state file says whose, which is the one thing
separating it from the pre-existing dirt above, and the reason that file is
written before the work starts rather than after. What it is *worth*, though,
depends on the ticket, and there are two cases that must not be run together:

- **Boxes still unticked** — the session died mid-implementation. This is the
  partial work the paragraph above describes: commit it under the number, marked
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

## 4. Merge nothing, remove nothing

The run ends with the branch pushed and the worktree in place. Merging into the
default branch is the user's call, and so is when — several rounds of review and repair
on the branch are the ordinary case, and each ticket's commits are what makes
that possible.

Say what the merge would be, and do not run it:

```
git -C <the user's checkout> merge --ff-only adr-<N>
git -C <the user's checkout> worktree remove --force .claude/adr-wip/<repo>-adr-<N>
```

`--ff-only` rather than a plain merge, so a checkout that has moved on refuses
instead of quietly making a merge commit. The removal is `git worktree remove`
and never `rm -rf`, and what `--force` is for, is on the shelf under **Leaving
it** — including what dies with the directory and what does not.

## Present

The worktree path and the branch, then the work list as it was built and one line
per ticket on it: its
number, whether it finished, stalled or was **skipped** at step 2 and why, how many criteria are proven of how
many, its round verdict — the word the ticket run returned, as it
gave it, with the report tag where its step 5 ran a settling loop — and **how long it took**,
which is the one column that says where the ADR's cost actually went. A drain is many tickets
and the per-round lines belong to the ticket's own summary, so they stay there;
what travels up is the word, and re-wording it is how a reader loses track of
which layer said what. Then the tickets still blocked, marking any that
are **blocked behind a stall** — a different answer from blocked, and usually
the most useful line in the report — and any that are **waiting on the user's
call**, which is not blocked either and is the one row a reader can clear
themselves. Then **the run's total** — elapsed since it started, marked as this
run's where the state file shows earlier sessions — and, where tickets are still
left, the last ETA with the one sentence §3's step 7 keeps off the per-round
lines: it assumes every remaining ticket is worked, so it is an upper bound.
Then **the spec issue's own line** — can close, or the children it
still awaits — since it is the row that says whether the ADR itself is finished
and the only one no ticket line covers. Then the one sentence that matters: what
is left to do on this ADR, and stop.

A run that ended at §3a says so **first**, above the table of tickets: which
ticket stopped it, what the question is, and that the rest of the ADR is
untouched and waiting. A summary that opens with the tickets that went well and
buries the question at the bottom is how a run that needed an answer gets read as
a run that finished.

Done when the work list is empty, or §3a stopped the run and its question is on
screen; and every
delegated prompt named the worktree as the directory its
commands run in, every commit this skill pushed was made over a tree a full
suite had seen — except a stall's partial commit, which §3a names as partial —
every attempted ticket has a commit and a pushed state, the
state file matches what happened, nothing is merged, and that summary is on
screen.
