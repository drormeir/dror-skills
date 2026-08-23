---
name: dror-implement-adr
description: Work one ADR's ticket list to exhaustion on a branch of its own - a side worktree off the remote head, one commit per ticket, dror-implement-ticket for each. Use when the user names an ADR number and asks to implement it, drain it, or work its remaining tickets.
disable-model-invocation: true
---

# dror-implement-adr

One ADR goes in. The skill prepares a working directory of its own, then works
the ADR's ticket graph one ticket at a time until nothing is left that can be
worked on.

It owns no implementation. It is `dror-show-tickets` for the map and
`dror-implement-ticket` for the work, plus the isolation, the loop and the
bookkeeping between them — the same relationship `dror-implement-ticket` has to
`dror-prove` / `dror-review` / `dror-repair`.

The ADR number is this skill's one argument. Without it, ask for it.

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
git worktree add ../<repo>-adr-<N> -b adr-<N> origin/main
git -C ../<repo>-adr-<N> push -u origin adr-<N>
```

Three things that look optional and are not:

- **Off `origin/main`, not `HEAD`.** The user's checkout may hold uncommitted
  work and unpushed commits. Starting from the remote head is what makes the
  branch's contents exactly this ADR's work.
- **Beside the repository, never inside it.** A worktree under the checkout is
  collected by the parent's own test run — this repository's pytest
  configuration replaces pytest's default hidden-directory skip, so even a
  dot-directory is walked, and mypy does not read `.gitignore` at all.
- **Pushed, with upstream set.** `dror-review` derives its base from
  `git merge-base @{upstream} HEAD`. With the branch tracking `origin/adr-<N>`
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
changed working directory is **not inherited by a spawned agent**: the shell
state persists within one agent's own commands, while an agent spawned from it
starts in the session's primary working directory — the user's checkout. The
chain below this skill is built out of such agents: `dror-review-repair` spawns
its review and its repair, and `dror-review` spawns a lens agent per lens and a
refuter under each. So a `cd` performed here reaches none of them, and a step
that is merely *expected* to be in the worktree runs its `git status` and its
`git merge-base` against the user's tree — reporting their uncommitted work as
this ticket's, and letting `dror-repair` edit it under this ticket's number.
That is silent, it is the default rather than an accident, and it is exactly
what §0 built the second checkout to prevent.

Nothing downstream takes a directory argument, which is why this is stated in
words rather than passed: say it in the prompt, and say it again in the prompt
each round, since a prompt is all a fresh agent has.

**Check this skill's own commands too**, cheaply: `git -C <path> rev-parse
--show-toplevel` must answer the worktree before the loop starts and after any
step that could have moved. It is a backstop and not the fix — it can only see
the commands this skill runs itself, never the ones inside a subagent, and a run
that leans on it instead of on the prompt has guarded the one place that was
never at risk.

## 1. Learn the project

Invoke `dror-internal-project-facts`, with §0a's sentence at the head of its prompt.
`dror-show-tickets` and `dror-implement-ticket` invoke it themselves and read the
same cached facts; the cache lives in the worktree's own store, so the first
round pays for the gather — and a gather that ran in the user's checkout writes
its `facts.md` there and leaves the worktree paying again every round.

## 2. Map the ADR

Invoke `dror-show-tickets` for ADR `<N>`, with §0a's sentence — it reads the
tracker rather than the tree, but it reaches the repo for the facts and for what
landed, and one skill in this run answering from a different checkout is how a
row comes back `Ready` that is not. Its table is the loop's input: which tickets
are `Ready`, which are blocked and behind what, which can close.

That skill's vocabulary is convention-bound — it knows this project's tracker —
and this skill inherits that binding by using its words. Nothing else here names
a tracker.

## 3. The loop

Keep a set of **attempted** ticket numbers. A set, not a queue: a ticket whose
run left criteria unproven is still `Ready` on the next scan and looks exactly
like one never touched, so without the set the loop re-picks it forever, and
nothing ever returns to a member, so there is no order to keep.

Each round:

1. Re-run `dror-show-tickets` for the ADR. The previous round may have unblocked
   something, and the boxes it ticked are on the table now.
2. Pick the first `Ready` row whose number is not in **attempted**. None: the
   loop is done — leave it and go to §4.
3. Add it to **attempted**, and write the state file (below) before the work
   starts, not after.
4. Invoke `dror-implement-ticket` with that number, its prompt opening with
   §0a's sentence. "In the worktree" is not a place this skill can put it — that
   run's own step 0 asks `git status` and `git merge-base` in whatever directory
   its agent starts in, and the answer decides what the whole chain reviews.
5. **Commit, and do not push yet.** One commit, naming the ticket. This is this
   skill's own act: `dror-implement-ticket` ends uncommitted by contract and
   `dror-repair` never commits (ADR 0007), so the commit belongs to the caller
   that wants ticket-sized history.

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

   - **owed** — settle it now, still unpushed, and settle it the same way
     `dror-implement-ticket` does: **invoke `dror-review-repair`**, capped at
     two rounds. Not an inline review-then-repair — that skill owns the round,
     judges it, and brings four things an inline round has no way to reach: the
     account of why the tree is dirty carried into every round, its run tag, the
     check for another run editing this tree, and the rule that the full suite is
     owed to the last code change.

     > `<§0a's sentence.>` Review and repair the unpushed work for ticket
     > `<N>`. **Cap the loop at two rounds.** A `dror-prove` follows, so pass
     > the ticket number down to every round's review and every round's repair,
     > and report which boxes moved. The tree is **committed and unpushed**: it
     > is this ticket's own work, already reviewed once inside
     > `dror-implement-ticket`, and this is the round it said was still owed —
     > so the diff you take from `git merge-base @{upstream} HEAD` is exactly
     > that ticket and nothing earlier.

     Then `dror-prove` for any box its repairs unticked — that stays this
     skill's own, because the loop deliberately ticks nothing — and then commit
     again. Its prompt opens with §0a's sentence too; it is a separate
     invocation, so it is a fresh agent starting in the primary working
     directory. **One box on that list is not proved by a test**: the criterion
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
   loop, name the ticket, say what the last round found, and go to §4 — after
   the push below, because the work is real whatever the verdict.

   **Then push**, once: after the verdict settles, after the cap is reached, or
   after a stall. That is what leaves `dror-implement-ticket`'s own step 0 a
   clean, pushed tree for the next ticket, and the next review a base at this
   ticket's tip.
7. Re-read the ticket's boxes. All ticked: say it can close, and **do not close
   it** — closing stays the user's gesture, because every box on it was ticked by
   this same chain. Some unticked: say which, leave the ticket open, and carry
   on.

A round that **stopped** rather than finished — `dror-implement-ticket` refusing
on an open blocker, or ending on a criterion it could not honestly implement — is
recorded and the loop continues to the next `Ready` ticket. It is not a reason to
stop the drain: a ticket that depended on the stalled one is not `Ready` and will
not be picked, which is the graph saying so by itself.

**A stall still commits.** Whatever it wrote before it stopped is in the tree,
and `dror-implement-ticket`'s own step 0 refuses a dirty tree — so a stall left
uncommitted jams the very next ticket. Commit it under the ticket's number,
marked as the partial work it is, push it with the rest, and skip step 6: there
is no verdict on a ticket that was never implemented. The same applies at the
top of a **resumed** run — a tree that is dirty when the loop starts is the
previous session's interrupted ticket, and it is committed the same way before
anything new is picked.

Termination: every round either closes work or grows **attempted**, the ticket
set is finite, and the extra review rounds inside a ticket are capped at two.

**The state file.** The loop's whole state is **attempted**, and a compaction
mid-drain would lose it — "tried and stalled" is indistinguishable from "never
tried" when read back from the tracker. So write it to
`<worktree>/.claude/dror-skills/drain-<ADR>.json` each round: the ADR, the attempted
numbers, and one line per round saying what happened. Read it at the start of a
run and treat it as the starting **attempted** set. Like every store in this
chain it is disposable: unreadable is a miss, never an error, and the cost of
losing it is re-attempting a stalled ticket once.

## 4. Merge nothing, remove nothing

The run ends with the branch pushed and the worktree in place. Merging into
`main` is the user's call, and so is when — several rounds of review and repair
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

The worktree path and the branch, then one line per attempted ticket: its
number, whether it finished or stalled, how many criteria are proven of how
many, and its round verdict — the word its settling loop returned, as that loop
gave it, with the report tag where a step 6 loop ran. A drain is many tickets
and the per-round lines belong to the ticket's own summary, so they stay there;
what travels up is the word, and re-wording it is how a reader loses track of
which layer said what. Then the tickets still blocked, marking any that
are **blocked behind a stall** — a different answer from blocked, and usually
the most useful line in the report. Then the one sentence that matters: what is left to do on this ADR,
and stop.

Done when the ready set is empty or every remaining ready ticket has been
attempted, every delegated prompt named the worktree as the directory its
commands run in, every commit this skill pushed was made over a tree a full
suite had seen, every attempted ticket has a commit and a pushed state, the
state file matches what happened, nothing is merged, and that summary is on
screen.
