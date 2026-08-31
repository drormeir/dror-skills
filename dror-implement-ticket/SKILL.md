---
name: dror-implement-ticket
description: Take one ticket from unwritten to closed - implement it, prove its criteria, loop review and repair until it converges, prove whatever is still unticked, then commit, push and close it. Use when the user names a ticket number and asks to implement it end to end.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-implement-ticket

One ticket, one run: **implement**, then `dror-prove`, then `dror-code-review-repair`
— which loops review and repair on its own until it converges — and then
`dror-prove` once more over whatever is still unticked when the loop returns.

**The loop is delegated, and it is delegated whole.** This file does not spell
out rounds, judge one, or count them: `dror-code-review-repair` owns that, and this
skill gives it a ticket, a cap and the promise that a prove follows. The
re-prove runs once, at the end, over every box that is still open.

The ticket number is this skill's one argument. Without it, say so and stop —
there is no default ticket and guessing one is worse than stopping. Every step
below is handed that same number, so the runs judge one contract and not several
readings of it.

**This run has a context of its own.** The frontmatter forks it (ADR 0036):
what reaches it is this file, the facts the line below injects, and the
arguments it was invoked with — never the conversation that invoked it. An
override the user has given arrives as an argument or not at all; a question
only the user can answer is returned as the result, and the caller puts it;
and what goes back to the caller is the closing summary. Every skill this one
invokes is forked the same way, so their working context never lands here.

Steps 0 and 1 and the summary are this skill's own work. The rest are the dror
chain, each
invoked as itself; this file adds the order, the ticket, the tree it starts from
and the reading of what came back, and nothing else. It is
**repo-agnostic** in the one sense that matters: it names no tracker, no path
and no runner of its own, and takes all three from the facts. It does assume
**git**, unconditionally — step 0 and the review's whole scope are commits and a
working tree — so a repo under another VCS is out, and that is the one
assumption to state rather than discover.

## The project facts

!`bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh`

The block above is the store's `facts.md`, printed by
`dror-internal-project-facts/facts.sh` before this text reached you, when its
stamp matched the tree (ADR 0037). Its test layout, verification commands and
issue convention are what step 1 needs: build the way this project builds,
verify with the command it actually uses, and read the ticket the way this
project tracks tickets. A block that begins `MISS:` means the store could not
answer: invoke the `dror-internal-project-facts` skill — it gathers in a
subagent, rewrites the store and returns the five facts — and hold what it
returns as the facts from then on. The later steps run the same script at their
own top and read the same store.

That skill is a **step of this one**, not a hand-off, and so is every other
skill this file invokes: `../dror-internal-shared/DELEGATION.md` — the shelf
beside this skill — owns what a sub-skill's closing contract means to a caller
and why every delegating step below ends on a named next action, at authoring
time. Here the action is: the moment the facts are in hand, **run step 0's
`git status` in the same turn**. Step 0's two git questions need no facts, but
its third — the baseline suite — needs the verification command, so the facts
come first. What step 0 may not do is be skipped, which is what naming step 1
here would invite.

**A repo whose issue convention came back unstated stops here**, and says so.
Every step below is handed a ticket number and three of them fetch the ticket
themselves; with no way to read one, step 1 has no criteria to build against and
the chain has no contract to judge. `dror-prove` reaches the same conclusion one
step later and stops for the same reason — stopping here costs the user one
sentence instead of an implementation written against a guess.

## Run start to finish

Four things stop this skill, all of them at or before step 1 and so all of them
*before* the chain runs: a repo that tracks no tickets, an unpushed tree, a
blocker still open, and an
implementation that could not honestly be finished. Each says what it found
rather than reporting around it. The middle two are the user's to override —
the run cannot ask, so it returns the question as its result, and the override,
when given, arrives as an argument on the next invocation; the
first and the last are not — with no ticket there is no contract, and with a
half-written implementation there is nothing for the chain to judge.

Past that point the remaining steps run without stopping between them: prove, the
review-repair loop, prove again, settle whatever round is still owed, commit,
push, close. A step that finds nothing to do says so and the
run continues; nothing here waits on an answer, because the question every step
would ask — "is this ticket's work done?" — is what the next step exists to
answer with evidence.

The cost is the one thing to know before starting a run: step 3 is **two to
three** rounds of review and repair — two whenever the first round repairs
anything, which is the ordinary case — each spawning its own lens and refuter
agents, so a ticket whose diff keeps moving costs several times what a clean one
does.

## 0. Start from a pushed, green tree

Step 3 reviews **everything unpushed**, not this ticket's diff, so work left in
the tree before this run starts is reported and repaired under this ticket's
name. Committing does not remove it — an unpushed commit is in scope exactly as
a modified file is. And a test that is red before this run writes a line is the
same work arriving through the suite instead of through `git status`: nothing
in the chain may fix it — `dror-code-repair` names it `pre-existing failure` and
leaves it, by rule — and the gate criterion can never tick over it, so every
round is spent and the ticket ends open on a red that was known before step 1.

Before anything is written, ask three questions and report all three:

- `git status --porcelain` — is there uncommitted or untracked work?
- `git rev-list --count <base>..HEAD` — is the branch ahead of what step 3 will
  review from?

**`<base>` is `dror-code-review`'s base, found `dror-code-review`'s way**, because a
disagreement here reports work the review will not see, or stops a run over work
that is already pushed. So: `git rev-parse --abbrev-ref
--symbolic-full-name @{upstream}` and count from `git merge-base @{upstream}
HEAD` where there is one; where there is **no** upstream — which does not mean
nothing is pushed, only that this branch tracks nothing — try
`git merge-base origin/HEAD HEAD`, then `origin/main` or `origin/master` where
`origin/HEAD` is unset. Only a repo with no usable remote ref at all has nothing
to count against, and there every commit is unpushed by definition: say that is
the case rather than reporting a number. Name which of the three you used, since
step 3 will name it again and the two must agree.

- **The project's full suite**, in its quiet form, over the tree as found — the
  **baseline**. A caller may hand this step a green run instead: the command,
  its summary line and the commit whose tree it ran over. Take it only where
  `HEAD` is that commit and the tree is clean; otherwise run the suite here.
  Name which. A run made over a working tree that was then committed whole is
  a run over that commit's tree — the sha to check is the commit's, which is
  how §Present names this run's own, and not the `HEAD` of the moment it ran.

A non-empty status, or a count that is anything but `0`, and the run **stops
before step 1**, naming what it found. The two commands say "nothing"
differently — an empty output and the string `0` — so read each one's answer,
not the presence of output.

**A red baseline stops the run the same way.** Name each failing test by its
subject, paste its assertion, and say it is **pre-existing** — red on a tree
this run had not touched. Do not fix it and do not guess whose it is beyond what
`git log -1 -- <its file>` says; the answer is the user's, since a fix here is
code under this ticket's number that no finding and no criterion asked for. A
failure the project itself declares out of scope is not a stop: name it and
carry on, and carry the name down to step 3 so the loop reads it the same way.

This skill commits its own ticket at step 6 and pushes it at step 7, and neither
of those makes the work already sitting here this run's to carry: a run that
started dirty and said nothing would hand back a review of somebody else's work
with this ticket's number on it, and then commit it under that number too.

The user may say to proceed anyway — over the dirt, or over the red. Then
continue, and carry one sentence naming the pre-existing work, or the
pre-existing red tests by subject, into **step 3's prompt**, which is where the
loop is handed everything it knows. Over a red, say now what it costs: the gate
criterion ticks only on a green full suite, so unless the red is fixed outside
this run before step 4, step 8 leaves the ticket open on it. The review needs it so its findings can be read
against that work; the repair needs it more, because a repair told nothing will
fix another ticket's code under this ticket's name and leave it in the tree —
which is the outcome step 0 exists to prevent, still happening one step later.
The loop carries it into **every** round on its own; passing it once is enough,
and passing it at all is not optional.

## 1. Implement

Read the ticket the way the **issue convention** fact says this repo tracks work,
and number its acceptance criteria 1..N. That numbering is the chain's: `dror-prove`,
`dror-code-review` and `dror-code-repair` all count the boxes in the ticket's own order,
and a run that renumbers them makes three later reports unreadable against the
ticket.

**Read what blocks it before writing anything.** A ticket usually says what it
depends on — a `## Blocked by` or `## Depends on` section, a `#number`, a
`blocked` label. Check the state of each thing it names the same way the ticket
itself was read. A blocker still open stops the run and says which: implementing
on top of work that has not landed is the one mistake nothing downstream can
detect, because every later step judges this ticket's criteria and none of them
knows what the ticket was waiting for. As with step 0, the user may say to
proceed anyway. A ticket that names no dependency has none — this step reads,
it does not hunt. On a repo of ADRs and GitHub issues, `dror-show-tickets` over
the parent ADR is the fuller map, and worth a look when the answer is unclear.

Write the implementation the ticket describes, and nothing the ticket does not.
Typecheck and run the affected tests as you go, with this project's own
verification commands; run the full suite once, at the end of this step. Read
its result against step 0's baseline: a test red there is not this step's and is
named as such, not chased; a test red here and green there is this step's, and
this step fixes it before it ends.

**A step that cannot be finished ends the run here.** An ambiguous criterion, a
criterion the code contradicts, a dependency discovered mid-way — say what
stopped it, what was written so far, and stop. The three steps below all judge an
implementation against the criteria, and running them over one that is knowingly
incomplete spends three runs to rediscover what this step already knew. Partial
work is not a failure to report around: leave it in the tree, name it, and let
the user decide. The exception is a criterion this step simply did not *satisfy*
while the implementation itself is complete and coherent — that is step 2's
answer to give, not this step's guess to make.

**Do not write the criteria tests here.** Step 2 writes one test per criterion and
proves each one bites, so a test written now is a second author of the same set —
the duplication this chain exists to avoid. Matt's `/tdd` is not invoked for the
same reason. Tests that are part of *building* the thing — a seam you could not
write without one — are yours to write; the criteria list is not.

**Tick no box.** `dror-prove` ticks, and only what it saw go green.

## 2. Prove

Invoke the `dror-prove` skill for this ticket:

> Prove ticket `<N>`: one test per acceptance criterion, each seen to fail before
> it counts, and tick only the boxes whose tests went green. Go ahead without
> showing me the split first — this is a chain run. The implementation is
> written, so a criterion needing production code is one this step may write,
> and a criterion the full suite will settle later (the verification gate) is
> left unticked with its Note naming the run it waits on.

**The waiver is deliberate and it is narrow.** `dror-prove` shows its
classification and waits, "unless the user has already said to go ahead" — and
here they have, by asking for a run this file promises will not stop. What is
*not* waived is the question it asks about a criterion that reads two ways: that
one still stops, and rightly, because guessing produces a green box against a
test proving something else. It should rarely fire, since step 1 already ends
the run on an ambiguous criterion.

**Its closing summary is a step's output, not this run's reply.** A ticket list
with fresh ticks is **a deliverable's shape** (DELEGATION.md), so this step's
named next action: **immediately after that summary, and in the same turn, invoke
`dror-code-review-repair` as step 3 says.** The boxes are proven, the ticket is
not finished, and nothing but step 3 will find what the implementation got wrong.

## 3. Loop review and repair

Invoke the `dror-code-review-repair` skill. It runs `dror-code-review` and `dror-code-repair` as
rounds until the work converges, judges each round itself, and stops on its own
cap — none of which is this file's business any more.

**Under a directory override, fold the loop in instead of invoking it.** A
drain run's arguments carry §0a's sentence — "All commands run in `<path>` …"
— and one fork below this run is the harness's spawn-depth cap, which delivers
a fork invoked from there with no arguments at all (ADR 0043): a forked loop
would fork `dror-code-review` at the cap, and that review would review the
session's checkout in good faith and never learn it. So where the sentence is
in this run's arguments, read `../dror-code-review-repair/SKILL.md` — beside this
skill's own base directory — and follow it here, whole: it still owns the
rounds, the tag, the floor and the judgement, and its steps run exactly as it
says — as spawned agents given the step files, by the shelf's
`../dror-internal-shared/STEP-AGENT.md`, so no fork is left to lose its
arguments. Carry the override sentence into each of those briefs, as it
instructs. The loop file's closing summary becomes this step's result rather
than a returned one, and its stop is its own (DELEGATION.md) — this step's
named next action below still ends the step. Without the sentence, invoke the
skill as ever. Either way, the prompt:

> Review and repair the unpushed work for ticket `<N>`. **A `dror-prove` follows
> this loop**, so pass the ticket number down to every round's review and every
> round's repair: a criterion the diff claims and misses is an `unmet criterion`
> finding, and a box whose test a repair sees go red is unticked by it. **Cap the
> loop at three rounds.** Report which boxes moved, so the prove that follows
> knows its list. **This is a chain run: notify nothing.**
>
> The tree is dirty **because this run wrote it** — the implementation for this
> ticket, and the tests a prove wrote for its criteria. That is the work you are
> being asked to review, not work left behind by somebody else. `<Where step 0
> found the tree dirty and the user said to proceed: and this work was also in
> the tree before the run started — …>` `<Where step 0's baseline was red and
> the user said to proceed, or a failure is declared out of scope: these tests
> were red before the run started and are pre-existing failures, not this
> ticket's — …>`

**Tell the loop why the tree is dirty.** Its own step 0 asks `git status` and
reports what it finds, which is right for a user invoking it directly and
misleading here: everything it sees was written minutes ago by steps 1 and 2. Say
so in the prompt, and keep step 0's pre-existing-work sentence **separate and
labelled** where there is one — the whole point of that sentence is to mark the
work this ticket did *not* produce, and a loop that cannot tell the two apart
repairs another ticket's code under this ticket's name, which is the outcome step
0 exists to prevent.

**Pass the number, not the criteria.** Every skill in the chain fetches the
ticket itself and numbers the criteria 1..N in body order, so pasting the list
has it read twice and invites two numberings of one contract.

**The two options in that prompt are the whole interface.** "A prove follows" is
what lets the ticket travel down at all — without it the loop deliberately runs
ticketless, so that no box is left unticked with nobody to tick it back. Three
rounds rather than the loop's own default cap is this chain paying for the rounds
twice over: it has an implementation and two proves around them.

**Three rounds is measured, not guessed** — a *cap*, sitting above the round-1
floor the loop enforces itself (ADR 0023): rounds 1 and 2 are one
review split in two, and round 3 is the first that is really a second look.
The loop reports **owed** at its cap where a case for
continuing is still live, and hands over the command; that answer travels into
this run's summary unchanged.

What comes back is a per-round line, the word the loop ended on with its grounds,
the boxes its repairs unticked, and the verification runs those repairs made.
Carry all of it into this run's summary as it was given — a chain that re-words a
delegated result is a chain whose reader cannot tell which layer said what.

**The chain's rule for the full suite: it is owed to the last code change**,
whoever made it. So: the loop repaired and its last round ran a suite, that is
the run; nothing has changed code since step 1's suite, that one still stands;
anything else — no round ran a suite, or step 2's new tests have never been in
one (a test file can break collection or share a fixture, which a targeted run
cannot see) — **run the project's full suite here**, before step 4. Say which of
the three happened, and name the run that counted.

**The rule outlives this step.** Step 4 can change the tree too — `dror-prove`
writes tests, and production code for an `unmet criterion` no repair carried —
so a step 4 that touched the tree owes the suite again, after it and before the
summary. Never a chain that ends with code no full suite has seen.

**The loop's summary is a step's result, not this run's reply**, and this is the
hardest of the three to hold: where the loop ends **owed** it hands back a
`/dror-code-review` command, **a hand-back command** in DELEGATION.md's words. It is
not one here; the command travels into this run's summary unchanged and the
ticket has still to be proven, committed, pushed and closed. So this step's named
next action: **immediately after the loop returns, and in the same turn, run the
full suite where the rule above owes one, and otherwise fetch the ticket's boxes
for step 4.** One of those two calls is this step's last move, and a turn that
relays the loop's summary and makes neither has stopped inside a step.

## 4. Prove what is still unticked

The loop changed code, and only `dror-prove` ticks a box — so a criterion a
repair unticked stays unticked however green its test now is, and the ticket
understates itself until somebody proves it again.

**This step is outside the loop, and it runs once.** Rounds of review and repair
settle what the *code* should be; a box is a claim about the code as it finally
stands, and re-proving one in every round spends a full mutation pass on a
criterion the next round may untick again. So the boxes are settled here, after
the tree has stopped moving.

Read the ticket's boxes as they stand now. Every criterion still unticked is this
step's list: the ones the loop's repairs unticked, and any step 2 could not
prove. Nothing else — a criterion already ticked is proven, and proving it again
means mutation-proving a passing test a second time for no new information.

One verdict comes off that list: a **`criterion wrong`** waits on the user's
rewording and on nothing this run can do, so re-proving it spends a pass to
re-derive the answer step 2 already gave. Say it is still standing and leave it.
A `not testable` **stays on** the list, deliberately: its verdict was reached
against the tree before the loop touched it, and a repair that added a seam is
exactly what makes such a criterion testable.

So does a **`gate`** — the criterion that *is* the project's verification gate
("the suite is green, plus lint and the type-check"). It is the one criterion
this chain answers itself: step 3's rule above owes the last code change a green
full suite, and that run is its whole evidence. Left off this list it stays
unticked with the run that satisfies it already on screen — which is how a
finished ticket comes to read as unfinished, and how one gets closed with a box
open that was green in fact all along.

**The list is read off the boxes, never off memory of step 2.** Count the
`- [ ]` lines in the body as it stands now; a step that decides its list from
what it remembers concluding will drop exactly the criterion whose verdict was
"nothing to do here", which is the one this step exists for. An empty list —
no `- [ ]` left — skips this step. Otherwise invoke
`dror-prove` scoped to that list:

> Prove ticket `<N>`, criteria `<the still-unticked numbers>` only. The other
> criteria are ticked and proven; leave them and their tests alone. Each of these
> must be seen to fail before it counts, and tick only what went green — except a
> criterion that *is* the verification gate, whose evidence is the full-suite run
> that counted for this chain: `<quote its summary line, and say which step made
> it>`. Tick that one on the run, not on a test.
>
> **Write the production code a criterion still needs.** Some of these are
> unticked because nothing implements them — a review found an `unmet criterion`
> and no repair took it. Implementing it is this step's job here: write the
> test, see it red, write the code, see it green. Go ahead without showing me
> the split first.

**That last paragraph is not a courtesy, it is the only route an `unmet
criterion` has.** `dror-code-review` mints the kind, and `dror-code-repair` will not take
it — its list is bugs and gaps in cover, and it does not invent an
implementation nobody found missing. So the finding arrives here or nowhere, and
`dror-prove` writes code only where the run it is in says code is its job. Say
so, or the one finding ticket-mode exists to produce falls between the two
skills every time.

A criterion that fails here for the same reason it failed in step 2 is a real
answer, not a retry: say so and leave it unticked.

**If this step changed the tree, the full suite is owed again**, by step 3's own
rule: `dror-prove` does not run one, so a test file or a line of production code
added here has been seen by targeted runs alone. Run it before the summary and
name it as the run that counted. And where the prove left the gate criterion
unticked as waiting on a later run, this run is that run: green, it settles the
gate — tick it, as step 6's rule settles one — since step 5's prove ticks it
the same way and no step after that does.

**A box this step leaves unticked is where the run ends, and no round follows
it.** The loop is behind us: a criterion that failed here for the same reason it
failed in step 2 is the ticket's problem, not a review's, and another pass over
the code will not tick it. Say which box, why, and leave it — step 8 is where
that costs the ticket its close.

**This prove's summary is a step's output, not this run's reply** — the same
**deliverable's shape** (DELEGATION.md) as step 2's, and the run's last
finished-looking artifact before the commit. So this step's named next action:
**immediately after the prove returns, and in the same turn, run the full suite
where this step touched the tree; then, where step 3's word was **owed**, read
[`SETTLING.md`](SETTLING.md), and otherwise fetch the ticket body for step 6's
count.** One of those is this step's last move, and a turn that relays the
prove's summary and makes none has stopped inside a step. Branch on the bare
word here: whether those grounds are ones a round can move is the first question
that file asks, and asking it twice is how the two answers come apart.

## 5. Settle a round still owed

**optional** or **no** — nothing to settle, and this step is one line. The loop
judged its own last round and stopped on the merits; optional is the user's call
to make later, on the branch. Go to step 6.

**owed** — [`SETTLING.md`](SETTLING.md), beside this file, owns what happens
between that word and the commit: whether a further loop runs and what it is
capped at, what the prove after it must tick, and what the commit and the push
may do while the word still stands. Read it whole before acting on the word, and
do not act on it from memory of this section — the cap and the push-hold live
there, in one copy.

It is a separate file because most tickets never reach it, and a ticket run is
spawned once per ticket by `dror-implement-adr`.

## 6. Commit the ticket

One commit, this ticket's work. It is what gives every ticket a commit id of its
own: a ticket whose work is still loose in the working tree is indistinguishable
from the next ticket's, and the distinction cannot be recovered later by reading
a diff.

**The boxes go first.** Read the body as it stands now — step 5 may have moved
one since step 4 did — and count the
`- [ ]` lines. Every box ticked, and the message says the ticket is done. Any box
still open, and the work is committed all the same — it is real and losing it is
worse — but the message says so in a line of its own (`partial: criterion <n>
open`), and so does the report. An unticked box is either work not done or a
verdict nobody recorded, and a commit that reads as finished over one destroys
the distinction. Settling it first is better than annotating it, and step 4's
route is how: a `gate` the verification run already answered is settled by
ticking it, not by a caveat in a commit message.

**Stage the ticket's files by path, never `git add -A`.** Where this runs inside
an ADR worktree, `<worktree>/.claude/dror-skills/` holds the drain's state file
and this chain's review reports, and nothing gitignores it for you — an `-A`
lands that bookkeeping in the branch's history.

**Name the ticket, never with a closing keyword.** `Closes #N`, `Fixes #N`,
`Resolves #N` are not references — where the tracker reads commit messages they
*are* the close, performed by the push, whatever the boxes say and long after
anyone is reading the reply that would have said a box was open. Closing is step 8's act,
made after the push and against three conditions it reads for itself; a keyword
makes it instead at push time, with none of them checked. Write `#N` or
`for #N`.

A run that changed nothing in the tree commits nothing and says so. That is the
ordinary end of a tests-only request, not a failure.

## 7. Push the ticket's branch

`git push` once, to the branch's own upstream. It is what makes the ticket's work
visible to anyone who is not at this machine, and it is what leaves the next
ticket's step 0 a clean, pushed tree rather than one that stops it.

**It is also what closes the review window**, which is why nothing above may be
left owing: `dror-code-review` takes its scope from `git merge-base @{upstream} HEAD`,
so once this push lands, `@{upstream}` is `HEAD` and this ticket's diff is no
longer reviewable as unpushed work by anything. Step 5 exists to be finished
before this line, not after it.

**And where step 5 ended still owed, do not push** — step 5's hold applies
here, for the reason it gives. The commit stands and the push waits: say the
branch is unpushed and why, and that the review comes before the push.

**Never onto the remote's default branch.** Where `HEAD` is `main`, `master` or
whatever `origin/HEAD` names, this run commits and stops: say the commit is
unpushed and why, and leave the push to the user. The chain's own habitat is a
ticket branch — `adr-<N>` under a drain — and a run started on the default branch
by hand is the case this rule is for.

**Where the branch has no upstream**, set one to the remote of the same name
(`git push -u origin <branch>`) — a branch that tracks nothing makes every later
`dror-code-review` fall back to the remote's default branch and take the whole
accumulated diff as one ticket's. Where there is no usable remote at all, say so
and stop at the commit.

## 8. Close the ticket

Three conditions, all three, and the ticket is closed with the command the
**issue convention** fact names — on a GitHub repo,
`gh issue close <N> --comment "<one line: the branch, and the sha that did it>"`:

1. **Every box ticked.** Count the `- [ ]` lines in the body as it stands now,
   fetched again rather than remembered — steps 4 and 5 may both have moved
   boxes, and the count that decides a close is the one on the tracker, not the
   one in this run's notes.
2. **The full-suite gate green over the tree as it finally stands.** Named, with
   its summary line, and made *after* the last code change — step 3's rule says
   which run that is. A ticket closed on a green from before the final repair is
   closed on a tree nobody has.
3. **Step 7 pushed.** A closed ticket whose only copy of the work is a commit on
   one machine reads as done to everyone who cannot see that machine. So the
   default-branch case, the no-remote case and the still-owed case above close
   nothing: they commit, say why they did not push, and leave the ticket open.

Any condition failing leaves the ticket **open**, with one line saying which —
and that is not a failure of the run, it is the run reporting what it found.

**Nothing here reopens, rewords or unticks.** A `criterion wrong` waiting on
the user's call holds the ticket open by condition 1 and is meant to; the answer
is theirs, and this step's only move is to leave it alone and say so.

This close is deliberate, and the objection it overrules is real: every box on
this ticket was ticked by this same chain, so the close inherits whatever the
proofs were worth. It is taken because reopening is one command, and the
alternative is a queue of finished tickets nobody can tell from unfinished ones.
Where a criterion's evidence is thin, the verdict itself says so — `unproven` and
`partial` do not tick, so they hold the ticket open on their own, which is the
check that matters rather than the gesture.

## Present

Two short lines for the work that happened once — what was implemented, and how
many criteria are proven of how many — then **the loop's own per-round lines**,
in order and as it gave them: `round <k>: <n> survived, <what was repaired>`. One
line each, however many rounds ran: a reader wants to see the curve flatten, and
three paragraphs hide it. Pass them through rather than re-word them, so a reader
can tell which layer said what.

Then one line for what the run wrote **outside the tree**: the boxes
`dror-prove` ticked and the loop's repairs unticked. Those are the only marks
this chain leaves on the ticket — `dror-code-review` writes its per-criterion verdicts
into its own report and posts nothing. The three logs under
`~/.claude/dror-skills/` carry a line per round for a later retrospective. Then
the commit: its short sha, its subject, and the branch it was pushed to — or, on
the default branch, a repo with no remote, or a round still owed, that it is
unpushed and why. Then **the counted run**, on one line the next ticket's step 0
can take as its baseline: its command, its summary line, green or red, and
**that commit's sha** — the run was made over the tree the commit holds, since
every edit after it owed a suite before step 6 by step 3's rule, and a caller
handed the `HEAD` it ran under instead pays for the suite again over a tree it
has already seen (ADR 0040). Then
whether the ticket was **closed**, and where it was not, which of step 8's three
conditions did not hold. Say it rather than leave it to be discovered.

Then the one sentence that matters — which criteria are green and which are not,
counted from the ticket's boxes as they stand now, **after steps 4 and 5**. Then **why
the loop ended**: the word it returned — **owed**, **optional** or **no** — its
grounds in one sentence, and where that word came from — a review with no
survivors, a repair that touched no production code, the three-round cap, or a
criterion only the user can settle. An **owed** at the cap carries the loop's
hand-back command as well. Then stop.

Done when the implementation is written, the loop has returned with its word and
its per-round lines, the full suite has run over the tree as it finally stands —
after step 4, where that step changed it — every criterion has a proven state,
every box a repair unticked has been proved again or explicitly left red, the
loop's end is accounted for in one word with its grounds, a round still owed has
been run or explained, this ticket's work is in one commit named by its sha and
pushed to its branch or held unpushed with the reason named, the ticket is closed
or the condition that held it open is named, and that summary is on screen.
