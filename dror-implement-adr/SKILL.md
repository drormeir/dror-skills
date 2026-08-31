---
name: dror-implement-adr
description: Work one ADR's ticket list to exhaustion on a branch of its own - a side worktree off the remote head, one ticket at a time through dror-implement-ticket, committed ticket by ticket, stopping for the user the moment a ticket raises a question only they can answer. Use when the user names an ADR number and asks to implement it, drain it, or work its remaining tickets.
disable-model-invocation: true
context: fork
background: false
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

The ADR number is this skill's one argument. Without it, say so and stop.

**Every delegated skill is a step of this one, not a hand-off.**
`../dror-internal-shared/DELEGATION.md` — the shelf beside this skill — owns what
a sub-skill's closing contract means to a caller and why every step below ends on
a named next action, at authoring time. A drain that ends on a sub-skill's
closing sentence has worked no ticket at all.

**This run has a context of its own.** The frontmatter forks it (ADR 0036), so
what reaches it is this file and its argument — the ADR number — never the
conversation that invoked it, and a question that is the user's (§3a) goes back
as this run's result for the caller to put.

**A step and a spawn are not alternatives**, which is what §0a's warning and the
paragraph above are each half of. `dror-show-tickets` at §2 is a step run in this
context; the ticket run at §3 step 4 is a step run in an agent of its own; the
lens and refuter agents `dror-review` spawns far beneath both are neither this
skill's steps nor its business. What makes something a step is that this run is
not finished when it returns — DELEGATION.md says so for both ways of invoking,
and names the spawned one as the case where the sub-skill's closing sentences
come back *inside a result* that the next turn can still mistake for its own.
What makes something a spawn is where its commands run, which is §0a's subject
and the reason that section is written as hard as it is.

**One ticket at a time, never two.** Each is written on top of the last one's
commit, and §0's layout exists so that one ticket's diff is one ticket's review.

**Why the worktree.** Several ADRs are worked in parallel, in separate sessions,
against one repository. Each session therefore gets a checkout of its own, so
one run's tree is never another run's review scope, and the user's own checkout
stays free for the work they are doing by hand.

**A long ADR is drained across sessions, and that is free.** §3's fork keeps
each ticket's working context out of this one, so a drain lives far longer than
it used to — but not without bound: the work list, the round lines and §2's
table stay here for the whole run. Stopping after a few rounds and re-invoking
this skill costs nothing that matters. §Present prints, the state file carries
the attempted set and the durations the ETA is built from, and `RESUME.md`
rebuilds the list against a tracker that has meanwhile moved — which a fresh run
does better than a long one, since the tracker really has moved.

**The moment is the user's, and this skill does not pick it.** It cannot read how
much context it has left, so a rule telling it to stop when the window is tight
would be a judgement made exactly as judgement is going — the shape
DELEGATION.md already rejects. Nothing here stops on a count of rounds either;
what is written down is only that stopping is cheap, so that a user watching a
long drain knows they may.

## 0. Prepare the branch and the worktree

`../dror-internal-shared/WORKTREE.md` — the shelf beside this skill — holds the
naming, placement, guards, environment and re-entry rules for an ADR worktree, in
one copy. Read it whole before creating or adopting anything, and take this run's
path and branch from it. It is not restated here.

What this skill owes it is the number: the worktree is `adr-<N>` on branch
`adr-<N>`, both from the ADR this run was given.

**Its preflight is a step of this one, not a hand-off.** Run it before the first
ticket and report its four lines; a failure stops the run here, which is the
whole point of asking at a moment when there is nothing to blame the answer on.
Everything past §0a assumes an environment that was proved rather than built.

**Then the baseline: the project's full suite, once, in the worktree, before the
first ticket.** The tree is the remote head and nothing of this run's is in it,
so a red here is pre-existing by construction, and it is the cheapest moment
there will ever be to say so: every ticket's step 0 would find the same red,
every round would be spent around it, and every ticket would end open on its
gate. A red baseline is a §3a stop before any ticket is picked — the failing
tests by subject, their assertions, and no fix — unless the project declares
the failure out of scope, in which case it is named and carried into every
ticket's prompt. Green, record the command, its summary line and the sha, and
hand them to the first ticket's prompt as its baseline; each later ticket's
baseline is the previous ticket's counted full-suite run over the tip it
starts from, handed the same way, so no ticket pays for a suite the chain has
already seen. That run comes back in the ticket's summary named against **its
commit's sha**, not the `HEAD` it ran under: it was made before the commit,
over the tree the commit then held, and step 0 of the next ticket checks the
sha against `HEAD` — handed the pre-commit sha it runs the suite again over a
tree the chain has already seen, once per ticket (ADR 0040).

## 0a. Carry the path into every delegated prompt

Resolve the worktree to an **absolute** path once, and put it in every prompt
this skill hands to another skill. Not as background — as the directory that
prompt's commands run in, named in its first sentence:

> All commands run in `<absolute worktree path>`. It is a `git worktree`, not
> the primary working directory; use `git -C <path>` for every git command and
> read and write files under that path only. Carry this paragraph verbatim
> into every prompt you hand to another skill or agent.

**This is the whole isolation, and prose is the only thing holding it.** A
changed working directory is **not inherited by a spawned agent**, and a skill
forked by its frontmatter is a spawned agent in exactly this sense: it starts in
the session's primary working directory — the user's checkout — whatever `cd`
ran here. `dror-review` spawns a lens agent per lens and a refuter under each,
so a step merely *expected* to be in the worktree runs its `git status` and
`git merge-base` against the user's tree, reports their uncommitted work as this
ticket's, and lets `dror-repair` edit it under this ticket's number. Silently,
and by default rather than by accident — which is what §0 built the second
checkout to prevent.

Downstream, the sentence is more than prose: `dror-implement-ticket` reads it
as the directory override that folds its review-repair loop into its own
context, and `dror-review` and `dror-repair` take it as an argument of their
own — which is what keeps every fork of the chain under the harness's
spawn-depth cap and its arguments delivered (ADR 0043). The forwarding clause
above is how it travels. Everything else obeys it as prose: say it in the
prompt, and say it again in the prompt each round, since a prompt is all a
fresh agent has.

**Check this skill's own commands too**, cheaply: `git -C <path> rev-parse
--show-toplevel` must answer the worktree before the loop starts and after any
step that could have moved. It is a backstop and not the fix — it can only see
the commands this skill runs itself, never the ones inside a subagent, and a run
that leans on it instead of on the prompt has guarded the one place that was
never at risk.

**So the agent is made to answer the question the backstop cannot ask.** §3 step
4 runs a whole ticket inside a spawned agent, which is exactly the blind spot the
paragraph above names, and the whole of that ticket's work is on the far side of
it. The prompt therefore requires `git rev-parse --show-toplevel` as the **first
line of what that agent returns**, and this skill reads that line before it reads
anything else. It is not proof — an agent that ran the check in the right place
and its work in the wrong one would still pass — but it converts a silent default
into a claim on the record, made by the only party that could see, and a wrong
answer is caught at the first ticket rather than at the merge.

## 1. The project facts warm themselves

**Do not invoke `dror-internal-project-facts` on its own.**
`dror-implement-ticket`'s file opens with the store's stamp script (ADR 0037),
every ticket, and invokes the gather only on a miss — so a separate call here
buys nothing the first ticket does not buy anyway. (`dror-show-tickets` does not
use it: it is convention-bound and names its own commands.)

Where it runs is fixed rather than chosen: the script runs in the session
shell's working directory — the user's checkout, since nothing in this skill
`cd`s — so the store it reads is that checkout's, and a miss gathers into it.
The worktree is cut from the same rule files, so the facts are the same; what
could differ is a rule file this ADR's own branch changes, and that is what a
gather after the merge is for.

## 2. Map the ADR

Invoke `dror-show-tickets` for ADR `<N>`, with §0a's sentence — it reads the
tracker rather than the tree, but it reaches the repo for the ADR file and for
what landed, and one skill in this run answering from a different checkout is how a
row comes back `Ready` that is not. Its table is the loop's input: which tickets
are `Ready`, which are blocked and behind what, which can close.

**This is the only scan of the run**, so read the table properly here rather than
leaning on a later one to correct it — §3 builds its whole work list from it and
never asks again.

Its table is a step's output and not this run's reply. Its "nothing else — no
plan, no next steps" is that skill refusing to invent work of its own, and the
loop below is not invented work.

**The table is where this skill most often ends by mistake** — **a deliverable's
shape** followed by **a prohibition against guidance**, in DELEGATION.md's words. So this step's named next action:
**immediately after printing the table, and in the same turn, run `date +%s` for
§3's start-of-run reading.** That call is the step's last move, and a turn that
shows the table and makes no such call has stopped here.

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

**A spec row reading `No tickets yet` ends the run here**, before any worktree
work. It says the decision was published and nothing was ever cut from it, so
the node set is empty for want of tickets rather than for want of work — and a
drain that reported "nothing left" would be saying the ADR is finished. Say that
the ADR has no tickets, that writing them is the next step and whose call that
is, and stop.

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

**A virgin ADR pays one line for this section.** Three questions, from the calls
already made — is there a state file, is the branch ahead of its remote, does
§2's table show an open ticket with every criterion ticked? All three answering
"nothing" is the ordinary case: say so in one line — a drain that prints no such
line is indistinguishable from one that never looked — and the list §3 built
stands as it is.

**Any other answer means an earlier session left work behind: read
[`RESUME.md`](RESUME.md), beside this file, whole, before picking a ticket.** It
holds the read-side of resumption (ADR 0031) — which round entries to trust and
which tickets go to the front, when the tracker outranks the state file, whose
work a dirty tree is, the right-place check, and how a stopped or owed ticket
re-enters. Its outcome is an amended list and one line saying what it found.

### The clock and the ETA

You have no clock of your own, so the drain reads one: `date +%s`, epoch
seconds, arithmetic without a date library. Three moments and no others —
**once** at §2's end, where that section sends you, then once at each round's
step 1 and once at its step 7. Every duration below is a subtraction between two
of them, so a round costs two `date` calls and the run costs one more.

§2's reading is the run's start, and round 1's step 1 lands seconds after it:
drop the `elapsed` field from that one line rather than printing `elapsed 0m`.

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

### The ticket runs in its own context

Step 4 invokes `dror-implement-ticket` once per ticket, and that skill's own
frontmatter forks it (ADR 0036): the run happens in an agent of its own and
only its closing summary lands here. Nothing in this file spawns it — the
arrangement ADR 0035 chose is now the sub-skill's to provide, and what this
step writes is the invocation's argument. Steps 5, 6 and 7
stay here, in this context, because they are git and tracker questions this skill
asks for itself and the answers are what §Present is built from.

**Why.** A ticket run is the whole chain — an implementation, two proves, a
review-repair loop of up to three rounds and sometimes a settling loop after it —
and every source file it reads, every suite it runs and every instruction file it
loads would otherwise land here and stay, ticket after ticket, until a drain of
any length runs out of window in the middle of the list it exists to work. The
drain does not need any of that. It needs a handful of facts per ticket, all of
which fit in a returned summary. `dror-review-repair` makes the same arrangement
for its own two steps and gives the same reason; this is that reason one layer up,
where the multiplier is the ticket count. What it costs, and the three cheaper
things that were tried against it first, are ADR 0035.

**What the agent returns**, and nothing else — this is what steps 5 to 7 read and
what §Present relays:

- **The toplevel it ran in**, from `git rev-parse --show-toplevel`, as the first
  line. §0a says why it is first.
- **The commit** — short sha and subject — and whether it was pushed, or the
  reason it was held.
- **The criteria**: how many are proven of how many, and the number of every box
  still open with the verdict that left it open.
- **The loop's word** — **owed**, **optional** or **no** — with its grounds in a
  sentence, and where it ends **owed at the cap**, the hand-back command
  verbatim. Step 6 acts on this word and cannot re-derive it.
- **The report tag**, where its step 5 ran a settling loop.
- **The counted run** — the full-suite run its close read as the gate: its
  command, its summary line, green or red, and the commit's sha it is named
  against. Green, it is the next ticket's baseline; step 4 hands it on.
- **Whether the ticket was closed**, and where it was not, which of that skill's
  three conditions did not hold.
- **Where it stopped early**: which of the four stops below, what it wrote to the
  tree before stopping, and the question it would have asked.

A summary that comes back as narrative instead of those facts has to be asked
again, which is the one way this arrangement costs more than it saves. A ticket
run that ends on a bare "done" leaves this skill nothing to carry into §Present,
and DELEGATION.md names that a defect in the sub-skill — true, and no help
mid-drain, which is why the prompt lists the facts rather than trusting them.

**What the agent is given** is small on purpose: §0a's sentence, the ticket
number, and the baseline. Not the work list, not the ADR's table, not the
summaries of the tickets already worked. A ticket run judges one ticket's
contract, and knowing what the drain did before it changes nothing it is allowed
to do — while a tree written against another ticket's account of itself is the
thing §0's layout exists to prevent.

**The two overridable stops become this skill's to put.** A spawned agent cannot
ask the user anything, so where `dror-implement-ticket` would have stopped on a
dirty tree or an open blocker and offered the override itself, it returns the
question instead and the drain takes it to §3a. What that costs is real and small:
an override answered at §3a resumes through a fresh run of the ticket rather than
continuing where that run stood. Inside a drain it is nearly free, because those
two stops are the two a drain does not produce — the tree is clean by
construction after each round's commit and push, and §3's topological sort works
every blocker before anything that waits on it. A direct
`dror-implement-ticket` run is untouched and still asks for itself, which is
what that skill's own file says and what DELEGATION.md forbids editing it for.

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
   `dror-implement-ticket` run — hours, not minutes — and §Present's table does
   not arrive until the whole ADR is done, so without this line a user watching
   a drain cannot tell a run on its second ticket from one on its last.

   **Fire the notification, append it to the progress log, and print it too** —
   in that order, and all three. This run is forked (ADR 0036), so its text
   returns only at the end: the notification is what reaches a user who is not
   watching anything, the log is what a `tail -f` shows, and the print is for
   whoever reads the transcript afterwards. The two sections below hold both.
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
4. **Invoke the ticket**, by the section above: `dror-implement-ticket` with
   that number, its argument opening with §0a's sentence and asking for the
   facts that section lists; the fork is the skill's own.
   "In the worktree" is not a place this skill can put it, and for a forked
   agent that sentence is the only thing that puts it there at all: the agent
   starts in the session's primary working directory whatever this skill did,
   and that run's own step 0 then asks `git status` and `git merge-base`
   wherever it is standing, which decides what the whole chain reviews. Then the
   baseline, in one line: the green full-suite run over this tip — §0's for the
   first ticket, the previous ticket's counted run for every later one — as
   command, summary line and **the tip's sha**, so that run's step 0 takes it
   instead of paying for the suite again. The previous ticket's summary already
   names its counted run against its commit; pass that line as it came. A red
   counted run, or a stopped ticket whose recovery in step 5 ran the suite,
   hands on the recovery's run where it was green, and otherwise nothing —
   step 0 then runs its own and finds the red as pre-existing, which is the
   stop §0 describes. Where §0 carried an out-of-scope failure, its
   name goes on the same line.

   **Read the returned toplevel first, before the rest of the summary.** Anything
   but the worktree and this round is over: nothing here is committed, closed or
   counted — the work is wherever that agent left it and this skill did not watch
   it land — and the drain goes to §3a naming the path that came back. A summary
   that arrives without that line is the same stop; asking again is cheaper than
   any of the eight facts below being about the wrong tree.

   What comes back is a summary. **It is one ticket's summary, not the drain's**
   — a deliverable's shape (DELEGATION.md), arriving as an agent's *result*,
   which is the shape that reads most like a finished turn. So this step's named
   next action: record the summary against the round, then **immediately, in the
   same turn, run step 5's `git log --oneline <the previous tip>..HEAD`.**

   Four things stop that run — a repo tracking no tickets, a dirty or unpushed
   tree, an open blocker, an implementation it could not honestly finish. The
   agent puts none of them to the user, because it cannot; it returns the
   question and the drain stops on it at §3a, which is where the user is. **Answer
   none of them on the ticket's behalf** — the loop wanting the drain to keep
   moving is precisely the interest that must not decide an override — and carry
   the question up in the words it came back in.
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
     the type-check, and name the run — green, it is the next ticket's baseline,
     named against the commit this makes. Red, commit all the same, marked partial
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
   the ticket run has already spent its loop's cap and its settling cap on top of
   it, and a ticket not converging after all of those gets the user, not one more
   round under the drain's name. So the words mean:

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
   lines — notified, appended to the progress log and printed, as at step 1:**

   ```
   [ADR <N>] <done>/<total> done · <left> left · <stalled> stalled · #<ticket> <verdict>
   [ADR <N>] #<ticket> took <d> · elapsed <total so far> · ETA ~<estimate> for <left> left
   ```

   `<done>` counts the rounds that finished — worked or skipped — `<left>` is
   what remains on the list, and `<stalled>` counts the rounds whose `outcome`
   reads `stopped`. A stop ends a session, so a count above one is only ever
   read out of the state file a resumed run inherited; a `finished` round whose
   ticket stayed open still counts as done — the round did its work, and the
   open ticket is the tracker's story, told in the summary. `<stalled>` is the
   number that says whether the drain is going
   well or merely going. `<verdict>` is the word step 6 recorded, as that loop
   gave it, or `skipped — <why>`; §Present's rule against re-wording it holds
   here for the same reason.
   The counts are the state file's, written the same round, so the line and the
   file cannot disagree.

   `<d>` is this round's step 7 reading minus its step 1 reading, and
   `<elapsed>` is step 7's minus the run's start. Round both to something a human
   reads at a glance — `12m`, `1h 40m` — since a drain measured to the second
   claims a precision it does not have.

   The ETA obeys §The clock and the ETA: a plain mean of **worked** rounds
   only, `(from <k> worked)` where any round was skipped or stalled, and
   `ETA — one sample` / `ETA — none yet` where there is no mean to take.

   A stop at §3a prints this line too, before §3a's three lines: the last thing
   on screen should say how much of the ADR the stop leaves untouched.

Termination: every round takes one ticket off the list and none puts one back,
and the extra review rounds inside a ticket are capped at two. The list is built
once and only shrinks.

**The notification.** The one channel a forked run has to a user who is not
reading a file. `notify-send` is fired once as a ticket is picked, once as its
round closes, and once where §3a stops the run:

```
notify-send "ADR <N> · ticket <i>/<total>" "#<ticket> starting"
notify-send "ADR <N> · <done>/<total> done" "#<ticket> <verdict> · <left> left · ETA ~<estimate>"
notify-send -u critical "ADR <N> stopped — needs you" "#<ticket>: <the question, in one line>"
```

Fire the last one **before** §3a's own lines, so the desktop says a drain is
waiting at the moment it starts waiting rather than after the summary is
composed.

`<estimate>` obeys §The clock and the ETA, exactly as the printed line does —
the same mean, and the same `one sample` / `none yet` words where there is no
mean to take. Never a number invented for the notification.

**Why this and not the printed line.** A forked skill delivers only its final
message (ADR 0042), so every progress line this run prints is written where
only this context can read it — the user watching a drain sees nothing between
the invocation and the summary, whatever the file says about emitting text. A
`notify-send` is a tool call, and its *effect* lands on the desktop rather than
in the transcript, which is why the fork does not swallow it.

**Best-effort, never a gate.** `notify-send` is absent on a headless box and
on macOS, and a run that treated its failure as an error would stop a drain over
a cosmetic channel. Ignore the exit status, never make a round depend on it, and
say nothing about it on screen — the progress log below is the record, and this
is only the tap on the shoulder.

**Three, and not one per step.** A notification per sub-skill would be a
notification every few minutes for hours, which is how a user learns to dismiss
them without reading. The ticket boundary is the granularity the user asked for,
and the stop is the only one that must interrupt — hence `-u critical` on that
one alone.

**The progress log.** `<worktree>/.claude/dror-skills/drain-<ADR>.log`, plain
text, one line appended as each is composed: step 1's starting line and step 7's
two closing lines, verbatim, plus the work list once when §3 builds it and
§3a's three lines where a stop ends the run. Nothing else — it is a progress
log and not a second report.

**It exists because this run has no other channel to the user.** A forked skill
returns its closing summary and nothing before it (ADR 0042), so a drain that
runs for hours shows nothing at all until it is finished, and a user cannot tell
it from a hung one. The filesystem is what is visible while a fork is working,
and the state file is JSON written for a resumed run to parse rather than for a
person to watch. This is the same lines in the order they happened, so
`tail -f` answers "where is it now".

**Append, never rewrite** — the opposite of the state file below, and for the
opposite reason: what a watcher wants is the sequence. It is written under the
store, so step 5's rule keeps it out of the commit like everything else there,
and it is disposable in the same way — a line that could not be written is
never a reason to stop a round.

Name its path in §Present, since that is the first moment this run can tell
anyone anything.

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
middle of. A round entry left at `picked` **is** that signal, and `RESUME.md`
is what reads it.

**Rewriting a round entry is allowed here and nowhere else.** These are the logs'
opposite: `refutations.tsv` and its neighbours are append-only histories, and
this file is a *current position* that is rewritten every round by design. It
holds no history worth protecting — losing it costs one re-attempted ticket, as
below.

**What a resumed run does with this file** — the fresh scan, the stopped ticket
picked first, an owed stop waiting on the push — **is `RESUME.md`'s to say.**
What the file carries across is what the tracker cannot say: which numbers this
drain already tried, and which question it stopped on.

Like every store in this chain it is disposable: unreadable is a miss, never an
error, and the cost of losing it is re-attempting a stalled ticket once.

## 3a. Stop for the user's judgement

A round that **stopped** rather than finished ends the drain, and the user is
asked — and so does a red baseline at §0, before any round exists.
`dror-implement-ticket` refusing on an open blocker, refusing on a tree it
found dirty or red, ending on a criterion it could not honestly implement, a
returned toplevel that is not the worktree, a ticket
still **owed** at its cap or owed on a criterion only the user can settle, a
`Needs your call` row that is all the ADR has left,
a `dror-show-tickets` row whose status this skill cannot read at all — each of
those is a call about *what should be built*, and this loop's judgement is only
about *what to build next*. **Unreadable is the test in that last one**, not
unpickable: a status the table minted and this skill simply does not act on is
step 2's business and never a stop.

**Two of them are the user's to override, and offering the override is this
skill's** — the dirty tree and the open blocker. `dror-implement-ticket` offers
them itself when a user runs it directly; step 4's agent cannot, so it returns
the question and this is where it is put. Say what the ticket found, say that
proceeding over it is available, and stop. An override given here costs a fresh
run of that ticket rather than a continuation of the stopped one, which is what
§3's fork section says the arrangement costs and the one place it is paid.

**Fire the critical notification first**, by §The notification's third line,
before the bookkeeping below and before the three lines are composed. A drain
stops because it needs an answer, and the minutes spent committing and writing
the state file are minutes the user could already have been reading the
question. This is the one notification that is allowed to interrupt, and the
only moment in a drain where the difference is worth anything.

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

"Whatever this run wrote" is the whole of it, and on two of the stop causes that
is **nothing**. A ticket refused because the tree was already dirty wrote no
line, and committing what it found would put another ticket's work under this
one's number — which is the refusal happening anyway, one step later and under a
commit message that lies about it. Report the dirt, name it as pre-existing, and
commit none of it. A **toplevel that came back wrong** is the same answer for a
harder reason: this skill does not know what that agent wrote or where, so there
is nothing here it can honestly commit and no tree it can honestly claim to have
read. Name the path that came back, name the worktree it should have been, say
the ticket's work is wherever that agent left it, and commit nothing.

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

**A resumed run's dirty tree is neither of the cases above.** It is the previous
session's interrupted ticket, not this run's stall and not pre-existing dirt —
and whether it commits as partial or resumes one step from done is `RESUME.md`'s
distinction, made there at the start of the run, not here.

## 4. Merge nothing; remove the worktree only from a clean finish

The run ends with the branch pushed. Merging into the default branch is the
user's call, and so is when — several rounds of review and repair on the branch
are the ordinary case, and each ticket's commits are what makes that possible.
Say what the merge would be, and do not run it:

```
git -C <the user's checkout> merge --ff-only adr-<N>
```

`--ff-only` rather than a plain merge, so a checkout that has moved on refuses
instead of quietly making a merge commit.

**The worktree is removed when nothing about the run needs it any more**, and
only then. Every condition below must hold, read from the tree and the state
file rather than from memory of the run; any one failing leaves the worktree
standing, with a line naming which:

- The work list is empty and the run did not stop at §3a.
- Every round in the state file reads `finished`, and every ticket it names is
  `CLOSED` on the tracker — no round `stopped` or `skipped`, no
  verdict of **owed**. An **optional** verdict does not hold it: that call is
  made on the branch, which survives the directory, from a fresh worktree or
  from the checkout after the merge.
- From inside the worktree, `git status --porcelain` is empty and
  `git rev-list --count @{upstream}..HEAD` is `0`.
- The worktree is at the shelf's path, `.claude/adr-wip/adr-<N>`. One
  adopted from anywhere else was made by the user and is theirs to remove.
- Nothing shared points into it. Where the project is a Python package,
  `pip show <package>` in the user's checkout's venv must name the checkout and
  not the worktree — an editable install made from the worktree into the shared
  venv would leave the user's imports pointing at a deleted path.

Then, from the user's checkout and never with `rm -rf`:

```
git -C <the user's checkout> worktree remove --force .claude/adr-wip/adr-<N>
```

Why `--force`, why never `rm -rf`, and what dies with the directory are the
shelf's to say — WORKTREE.md's "Leaving it" holds them, in one
copy. Confirm with `git worktree list`, which must no
longer name the path, and say so. **The branch `adr-<N>` is never deleted**,
local or remote: it is what the merge above reads from.

## Present

The worktree path and the branch, **the progress log's path**, whether the
worktree was removed or which of
§4's conditions kept it, then the work list as it was built and one line
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
state file matches what happened, nothing is merged, the worktree is removed
where every one of §4's conditions held and otherwise named as standing with
the condition that kept it, and that summary is on screen.
