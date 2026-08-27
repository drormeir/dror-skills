---
name: dror-implement-adr
description: Work one ADR's ticket list to exhaustion on a branch of its own - a side worktree off the remote head, one ticket at a time through dror-implement-ticket, one commit each, stopping for the user the moment a ticket raises a question only they can answer. Use when the user names an ADR number and asks to implement it, drain it, or work its remaining tickets.
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

The isolation is `git worktree`: a second working directory backed by the same
`.git`. Nothing is cloned and the object store is shared.

From the user's checkout:

```
git fetch origin
git worktree add ../<repo>-adr-<N> -b adr-<N> <the remote's default branch>
git -C ../<repo>-adr-<N> push -u origin adr-<N>
```

Three things that look optional and are not:

- **Off the remote's default branch, not `HEAD`.** The user's checkout may hold
  uncommitted work and unpushed commits. Starting from the remote head is what
  makes the branch's contents exactly this ADR's work. `origin/main` above is the
  common case and not a rule: resolve it the way the rest of the chain does —
  `origin/HEAD`, then `origin/main`, then `origin/master` — since many clones
  never ran `git remote set-head` and a repo whose default is `master` would
  otherwise fail at the first command.
- **Beside the repository, never inside it.** A worktree under the checkout is
  collected by the parent's own test run — this repository's pytest
  configuration replaces pytest's default hidden-directory skip, so even a
  dot-directory is walked, and mypy does not read `.gitignore` at all.
- **Pushed, with upstream set.** `dror-review` derives its base from
  `git merge-base @{upstream} HEAD` **where there is an upstream**, and falls
  back to the remote's default branch where there is none — which for this
  branch would be every ticket's work at once, so the `-u` is what picks the
  first of those two. With the branch tracking `origin/adr-<N>`
  and every finished ticket pushed, each ticket's review sees that ticket's work
  and nothing earlier. Tracking `origin/main` instead would have ticket five
  reviewed together with tickets one to four, and `dror-repair` would then repair
  their findings under ticket five's number.

**Then carry the ignored things across.** A worktree contains tracked files
only, and everything a run needs to verify with is ignored: the virtualenv, the
agent settings and hooks, the local data directory. Symlink them one by one from
the user's checkout — the venv, the settings file, any hook scripts it names,
the data directory. **Do not symlink the whole agent directory**: its
`dror-skills/` store holds `facts.md` and the review reports, and sharing those is
sharing exactly what the isolation was for.

A ticket that changes the dependency file needs a virtualenv of its own rather
than the symlink, because installing into the shared one reaches every other
session.

**Re-entry.** A worktree that is already there is resumed, not recreated: check
for the directory and the branch first, and adopt them. Report the path either
way — every later step, and every command in it, runs in that directory.

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

**Do not invoke `dror-internal-project-facts` on its own.** `dror-show-tickets`
invokes it at §2 and `dror-implement-ticket` invokes it every round; all three
read one cached `facts.md`, so a separate call here buys nothing the next step
does not buy anyway — it is one whole skill run spent to reach a cache that §2
fills a moment later.

What matters is not *that* it runs but **where**: the cache lives in the store of
whatever checkout the gather ran in, so a gather in the user's tree leaves the
worktree paying for its own every round. §0a's sentence on §2's prompt is what
puts it in the right place, and that sentence is on every prompt regardless.

## 2. Map the ADR

Invoke `dror-show-tickets` for ADR `<N>`, with §0a's sentence — it reads the
tracker rather than the tree, but it reaches the repo for the facts and for what
landed, and one skill in this run answering from a different checkout is how a
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
`Can close`; those two are done, and `Can close` is the user's gesture (step 7),
not work. Each remaining row is a node. Its edges come from its status: a
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

### Then, each round

1. Take the next ticket off the list. Empty: the loop is done — go to §4.
2. **Skip it where the ticket itself says to.** The list is a plan made once and
   the tree has moved under it: a ticket already closed by hand mid-run, or one
   whose blocker ended up stalled, is skipped with a line saying which. This is
   the one thing the dropped rescan used to catch, and reading the ticket at the
   moment it is picked catches it for one ticket's cost instead of the table's.

   Keep the skipped numbers, and keep a set of **attempted** ones. A set, not a
   queue: a ticket whose run left criteria unproven is not re-picked by this loop,
   and nothing ever returns to a member, so there is no order to keep — what the
   set is for is the resumed run, which reads it back from the state file.
3. Write the state file (below) with the ticket marked attempted, before the work
   starts, not after.
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
5. **Commit, and do not push yet.** One commit, naming the ticket. This is this
   skill's own act: `dror-implement-ticket` ends uncommitted by contract and
   `dror-repair` never commits (ADR 0007), so the commit belongs to the caller
   that wants ticket-sized history.

   **Name the ticket, never with a closing keyword.** `Closes #N`, `Fixes #N`,
   `Resolves #N` are not references — where the tracker reads commit messages
   they *are* the close, performed by the push, whatever the boxes say. Step 7
   below leaves closing to the user deliberately, and a keyword written here
   overrides that the moment this branch reaches the default one, silently and
   long after anyone is reading. Write `#N` or `for #N`.

   **Read the ticket's boxes before committing**, which is
   `dror-implement-ticket`'s own rule for the commit it does not make: a `- [ ]`
   still open is either unfinished work or a verdict nobody recorded, and a
   commit made over it destroys the distinction. Step 7 re-reads them after the
   push for the drain's report; this reading is the one that decides whether the
   commit message may claim the ticket is done.

   **The push waits for step 6**, and that is not tidiness. `dror-review` takes
   its base from `git merge-base @{upstream} HEAD`, so a ticket pushed the moment
   it is committed has `@{upstream}` equal to `HEAD` and an empty diff — the
   extra round in step 6 would find nothing to review and end, every time. While
   the push waits, `@{upstream}` is still the previous ticket's tip, which is
   exactly this ticket's diff.
6. **Settle the ticket before the next one starts.**
   `dror-implement-ticket` ends by saying whether another `dror-review` /
   `dror-repair` round is **owed**, **optional** or **no**. Record the word and
   its grounds in the state file, and act on it here rather than at the end of
   the drain:

   **Read the grounds before spending on the word.** `dror-implement-ticket`
   returns **owed** with its grounds, and one of them — *a criterion only the
   user can settle* — is not something another round can move. Two more rounds of
   review and repair over an unchanged diff will find what the last ones found
   and hand back the same sentence, having spent a lens agent per lens and a
   refuter per finding, twice, to do it. That ground goes straight to §3a. The
   other grounds — the cap, a repair that touched production code — are exactly
   what a further round is for.

   - **owed, on grounds a round can move** — settle it now, still unpushed, and
     settle it the same way
     `dror-implement-ticket` does: **invoke `dror-review-repair`**, capped at
     two rounds. Not an inline review-then-repair — that skill owns the round,
     judges it, and brings four things an inline round has no way to reach: the
     account of why the tree is dirty carried into every round, its run tag, the
     check for another run editing this tree, and the rule that the full suite is
     owed to the last code change.

     **An owed-at-cap hand-back is a command, not a description.** Both that
     skill and `dror-implement-ticket` end an owed-at-cap by returning the
     command that would resume the loop. Where one comes back, run **that**
     rather than composing a fresh invocation of your own: it carries the report
     path, the tag and the round count this run reached, and a re-invented
     prompt starts a loop that thinks it is on round one. Report it verbatim in
     the summary too, since §3a hands it to the user. The prompt below is what to
     send when no command came back — add §0a's sentence to the command either
     way, because a command written by a run in this worktree still reaches a
     fresh agent that starts outside it.

     > `<§0a's sentence.>` Review and repair the unpushed work for ticket
     > `<N>`. **Cap the loop at two rounds.** A `dror-prove` follows, so pass
     > the ticket number down to every round's review and every round's repair,
     > and report which boxes moved. The tree is **committed and unpushed**: it
     > is this ticket's own work, already through two to three rounds of this
     > same loop inside `dror-implement-ticket`, and this is the round it said
     > was still owed —
     > so the diff you take from `git merge-base @{upstream} HEAD` is exactly
     > that ticket and nothing earlier.

     Then `dror-prove` for any box its repairs unticked — that stays this
     skill's own, because the loop deliberately ticks nothing — and then commit
     again. Its prompt opens with §0a's sentence too: it is a step like any
     other, but the agents it spawns beneath itself are not, and the sentence is
     what reaches them. **One box on that list is not proved by a test**: the criterion
     that *is* the project's verification gate is ticked on the full-suite run
     that counted for this round, quoted to it, exactly as
     `dror-implement-ticket`'s step 4 does — a repair unticks it like any other,
     and re-proving it with a test is proving the wrong thing.

     **And a prove that touched the tree owes the suite before the commit.**
     The chain's rule is that a green full suite is owed to the last code
     change, and the loop above honours it for its own rounds — but `dror-prove`
     runs none, and it writes: a test for a box that had none, production code
     for a criterion no repair took. So where it changed anything, run the
     project's full suite, plus lint and the type-check, and name that run.
     Otherwise this ticket's commit is pushed carrying code nothing has run,
     the next ticket is written on top of it, and the first full suite to see it
     is the one that fails under a later ticket's number.

     The word it returns is the ticket's verdict, taken as given: **owed** at
     its cap stops the drain (below), anything else settles the ticket. The next
     ticket is written on top of this one's code, so leaving production code that
     nothing has reviewed under the next ticket's diff is how a finding ends up
     attributed to the wrong ticket — the thing the whole branch layout exists to
     prevent.
   - **optional** or **no** — the ticket is settled. Optional is the user's
     call to make later, on the branch, which is what the branch outliving the
     run is for.

   **Still owed at that cap, and the drain stops.** Two rounds is the loop's
   own cap here and this skill does not raise it or run a second loop: a ticket
   still owed after them is not converging, and continuing to the next ticket
   would build on it while piling more work in front of the problem. Stop the
   loop, name the ticket, say what the last round found, and go to §3a — after
   the push below, because the work is real whatever the verdict.

   **Then push**, once: after the verdict settles, after the cap is reached, or
   after a stall. That is what leaves `dror-implement-ticket`'s own step 0 a
   clean, pushed tree for the next ticket, and the next review a base at this
   ticket's tip.
7. Re-read the ticket's boxes. All ticked: say it can close, and **do not close
   it** — closing stays the user's gesture, because every box on it was ticked by
   this same chain. Some unticked: say which, leave the ticket open, and carry
   on.

Termination: every round takes one ticket off the list and none puts one back,
and the extra review rounds inside a ticket are capped at two. The list is built
once and only shrinks, which is a stronger guarantee than the rescanning loop
had — there, termination rested on **attempted** growing.

**The state file.** A compaction mid-drain would lose the loop's state — the
list, what is left of it, and which numbers were attempted — and "tried and
stalled" is indistinguishable from "never tried" when read back from the tracker.
So write it to `<worktree>/.claude/dror-skills/drain-<ADR>.json` each round: the
ADR, the work list as built, what remains of it, the attempted and skipped
numbers, one line per round saying what happened, and — where §3a ended the run —
**which ticket stopped it and what was asked**. Read it at the start of a run for
the attempted and skipped numbers and the stopped ticket.

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
bookkeeping — commit **whatever this run wrote** and nothing else, push it, write
the state file — then say in three lines what stopped, on which ticket, and what
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
is no verdict on a ticket that was never implemented. The same applies at the
top of a **resumed** run — a tree that is dirty when the loop starts is the
previous session's interrupted ticket, and it is committed the same way before
anything new is picked — the state file says whose it was, which is the one thing
that separates it from the pre-existing dirt above, and the reason that file is
written before the work starts rather than after.

## 4. Merge nothing, remove nothing

The run ends with the branch pushed and the worktree in place. Merging into the
default branch is the user's call, and so is when — several rounds of review and repair
on the branch are the ordinary case, and each ticket's commits are what makes
that possible.

Say what the merge would be, and do not run it:

```
git -C <the user's checkout> merge --ff-only adr-<N>
git worktree remove --force ../<repo>-adr-<N>
```

`--ff-only` rather than a plain merge, so a checkout that has moved on refuses
instead of quietly making a merge commit. `--force` on the removal because the
symlinks are untracked files; it removes the links and never their targets.

## Present

The worktree path and the branch, then the work list as it was built and one line
per ticket on it: its
number, whether it finished, stalled or was **skipped** at step 2 and why, how many criteria are proven of how
many, and its round verdict — the word its settling loop returned, as that loop
gave it, with the report tag where a step 6 loop ran. A drain is many tickets
and the per-round lines belong to the ticket's own summary, so they stay there;
what travels up is the word, and re-wording it is how a reader loses track of
which layer said what. Then the tickets still blocked, marking any that
are **blocked behind a stall** — a different answer from blocked, and usually
the most useful line in the report — and any that are **waiting on the user's
call**, which is not blocked either and is the one row a reader can clear
themselves. Then the one sentence that matters: what is left to do on this ADR,
and stop.

A run that ended at §3a says so **first**, above the table of tickets: which
ticket stopped it, what the question is, and that the rest of the ADR is
untouched and waiting. A summary that opens with the tickets that went well and
buries the question at the bottom is how a run that needed an answer gets read as
a run that finished.

Done when the work list is empty, or §3a stopped the run and its question is on
screen; and every
delegated prompt named the worktree as the directory its
commands run in, every commit this skill pushed was made over a tree a full
suite had seen, every attempted ticket has a commit and a pushed state, the
state file matches what happened, nothing is merged, and that summary is on
screen.
