---
name: dror-implement-ticket
description: Take one ticket from unwritten to closable - implement it, prove its criteria, loop review and repair until it converges, then prove whatever is still unticked. Use when the user names a ticket number and asks to implement it end to end.
---

# dror-implement-ticket

One ticket, one run: **implement**, then `dror-prove`, then `dror-review-repair`
— which loops review and repair on its own until it converges — and then
`dror-prove` once more over whatever is still unticked when the loop returns.

**The loop is delegated, and it is delegated whole.** This file does not spell
out rounds, judge one, or count them: `dror-review-repair` owns that, and this
skill gives it a ticket, a cap and the promise that a prove follows. What
changed from the old chain is that the re-prove is no longer *inside* a round —
it runs once, at the end, over every box that is still open.

The ticket number is this skill's one argument. Without it, ask for it — there is
no default ticket and guessing one is worse than asking. Every step below is
handed that same number, so the runs judge one contract and not several readings
of it.

Steps 0 and 1 and the summary are this skill's own work. The rest are the dror
chain, each
invoked as itself; this file adds the order, the ticket, the tree it starts from
and the reading of what came back, and nothing else. It is
**repo-agnostic** in the one sense that matters: it names no tracker, no path
and no runner of its own, and takes all three from the facts. It does assume
**git**, unconditionally — step 0 and the review's whole scope are commits and a
working tree — so a repo under another VCS is out, and that is the one
assumption to state rather than discover.

## Learn the project first

Invoke the `dror-internal-project-facts` skill. Its test layout, verification commands and
issue convention are what step 1 needs: build the way this project builds, verify
with the command it actually uses, and read the ticket the way this project
tracks tickets. The later steps invoke it themselves and read the same cached
facts.

That skill is a **step of this one**, not a hand-off: the moment the facts are in
hand, continue at **step 0** in the same turn. Step 0 needs no facts, so it may
equally run before this section — what it may not do is be skipped, which is
what naming step 1 here would invite.

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
rather than reporting around it. The middle two are the user's to override; the
first and the last are not — with no ticket there is no contract, and with a
half-written implementation there is nothing for the chain to judge.

Past that point the remaining steps run without stopping between them: prove, the
review-repair loop, prove again. A step that finds nothing to do says so and the
run continues; nothing here waits on an answer, because the question every step
would ask — "is this ticket's work done?" — is what the next step exists to
answer with evidence.

The cost is the one thing to know before starting a run: step 3 is **two to
three** rounds of review and repair — two whenever the first round repairs
anything, which is the ordinary case — each spawning its own lens and refuter
agents, so a ticket whose diff keeps moving costs several times what a clean one
does.

## 0. Start from a pushed tree

Step 3 reviews **everything unpushed**, not this ticket's diff, so work left in
the tree before this run starts is reported and repaired under this ticket's
name. Committing does not remove it — an unpushed commit is in scope exactly as
a modified file is.

Before anything is written, ask two questions and report both:

- `git status --porcelain` — is there uncommitted or untracked work?
- `git rev-list --count <base>..HEAD` — is the branch ahead of what step 3 will
  review from?

**`<base>` is `dror-review`'s base, found `dror-review`'s way**, because a
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

A non-empty status, or a count that is anything but `0`, and the run **stops
before step 1**, naming what it found. The two commands say "nothing"
differently — an empty output and the string `0` — so read each one's answer,
not the presence of output.

Committing and pushing is the user's call and this skill does neither; a run that
started dirty and said nothing would hand back a review of somebody else's work
with this ticket's number on it.

The user may say to proceed anyway. Then continue, and carry one sentence naming
the pre-existing work into **step 3's prompt**, which is where the loop is
handed everything it knows. The review needs it so its findings can be read
against that work; the repair needs it more, because a repair told nothing will
fix another ticket's code under this ticket's name and leave it in the tree —
which is the outcome step 0 exists to prevent, still happening one step later.
The loop carries it into **every** round on its own; passing it once is enough,
and passing it at all is not optional.

## 1. Implement

Read the ticket the way the **issue convention** fact says this repo tracks work
— on a GitHub repo that is `gh issue view <n> --json title,body,state` — and
number its acceptance criteria 1..N. That numbering is the chain's: `dror-prove`,
`dror-review` and `dror-repair` all count the boxes in the ticket's own order,
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
verification commands; run the full suite once, at the end of this step.

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

## 3. Loop review and repair

Invoke the `dror-review-repair` skill. It runs `dror-review` and `dror-repair` as
rounds until the work converges, judges each round itself, and stops on its own
cap — none of which is this file's business any more:

> Review and repair the unpushed work for ticket `<N>`. **A `dror-prove` follows
> this loop**, so pass the ticket number down to every round's review and every
> round's repair: a criterion the diff claims and misses is an `unmet criterion`
> finding, and a box whose test a repair sees go red is unticked by it. **Cap the
> loop at three rounds.** Report which boxes moved, so the prove that follows
> knows its list.
>
> The tree is dirty **because this run wrote it** — the implementation for this
> ticket, and the tests a prove wrote for its criteria. That is the work you are
> being asked to review, not work left behind by somebody else. `<Where step 0
> found the tree dirty and the user said to proceed: and this work was also in
> the tree before the run started — …>`

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
rounds rather than the loop's own seven is this chain paying for the rounds twice
over: it has an implementation and two proves around them.

**Three rounds is measured, not guessed** — and it is a *cap*, over a floor of
two that the loop enforces itself. The first measurement said round 2 found one
gap and no bug and the curve was already flat; a wider reading of the refutation
log says the opposite about round 2 in particular, which is why the floor exists
(ADR 0023): one review pass does not cover a diff, so rounds 1 and 2 are one
review split in two and round 3 is the first that is really a second look. Three
is what that costs. The loop reports **owed** at its cap where a case for
continuing is still live, and hands over the command; that answer travels into
this run's summary unchanged.

What comes back is a per-round line, the word the loop ended on with its grounds,
the boxes its repairs unticked, and the verification runs those repairs made.
Carry all of it into this run's summary as it was given — a chain that re-words a
delegated result is a chain whose reader cannot tell which layer said what.

**Where the tree started dirty** (step 0, proceeding on the user's say-so), the
sentence naming that pre-existing work goes into this prompt: the loop passes it
to every round's review and every round's repair, and a repair told nothing will
fix another ticket's code under this ticket's name.

**The chain's rule for the full suite: it is owed to the last code change.** A
green full suite seen *after* the last edit any step made is the run, whoever ran
it — a round's `dror-repair` gate, or step 1's when nothing has changed code
since. So: the loop repaired and its last round ran a suite, that is the run; the
loop repaired nothing and step 2 added no test either, step 1's suite still
stands and nothing is re-run; anything else — no round ran a suite, or step 2's
new tests have never been in one — **run the project's full suite here**, before
step 4. A test file added in step 2 is a change like any other: it can break
collection or share a fixture, and a targeted run cannot see that. Say which of
the three happened, and name the run that counted.

**The rule outlives this step.** It is owed to the last code change wherever that
change is made, and step 4 is a step that can make one: `dror-prove` writes a
test for a criterion that had none, and writes production code for a criterion no
repair took — an `unmet criterion` finding is neither a bug nor a gap in cover,
so a repair's list may never have carried it. So a step 4 that touched the tree
owes the suite again, after it and before the summary. Never a chain that ends
with code no full suite has seen.

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
criterion` has.** `dror-review` mints the kind, and `dror-repair` will not take
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
gate — tick it, as the closing rule below settles one — since no step follows
this one.

**A box this step leaves unticked is where the run ends, and no round follows
it.** The loop is behind us: a criterion that failed here for the same reason it
failed in step 2 is the ticket's problem, not a review's, and another pass over
the code will not tick it. Say which box, why, and leave it — the next section is
about what that costs at closing time.

## Commit nothing

This run ends with the working tree changed and uncommitted. What to commit, and
where, is the user's call and the one thing these steps cannot judge — in
particular whether a criterion still unticked after step 4 leaves this ticket
closable at all.

**And when the user does ask for the commit, the boxes go first.** A ticket is
closed only with every criterion ticked; an unticked box at the moment of
closing is either work that is not done or a verdict nobody recorded, and
closing over it destroys the distinction. So before committing: read the body,
and if any `- [ ]` is left, either settle it (step 4's route — a `gate` the
verification run already answered is settled by ticking it) or say plainly which
box is open and let the user decide, rather than closing and tidying afterwards.

And where the tracker reads commit messages, a **closing keyword closes the
ticket** — `Closes #N`, `Fixes #N`, `Resolves #N` on the default branch — at
push time, silently, whatever the boxes say. It is not a note about what the
commit relates to; it is the close itself, performed by the push, and it
happens before anyone reads the reply that would have said a box was open.
Write one only when the ticket is genuinely ready to close and the user asked
for that; otherwise name the ticket without the keyword (`#N`, `for #N`) and
close it as its own step, after the boxes are settled.

## Present

Two short lines for the work that happened once — what was implemented, and how
many criteria are proven of how many — then **the loop's own per-round lines**,
in order and as it gave them: `round <k>: <n> survived, <what was repaired>`. One
line each, however many rounds ran: a reader wants to see the curve flatten, and
three paragraphs hide it. Pass them through rather than re-word them, so a reader
can tell which layer said what.

Then one line for what the run wrote **outside the tree**: the boxes
`dror-prove` ticked and the loop's repairs unticked. Those are the only marks
this chain leaves on the ticket — `dror-review` writes its per-criterion verdicts
into its own report and posts nothing. The three logs under
`~/.claude/dror-skills/` carry a line per round for a later retrospective. The
tree is left uncommitted and the ticket's boxes are not — say so rather than
leave it to be discovered.

Then the one sentence that matters — which criteria are green and which are not,
counted from the ticket's boxes as they stand now, **after step 4**. Then **why
the loop ended**: the word it returned — **owed**, **optional** or **no** — its
grounds in one sentence, and where that word came from — a review with no
survivors, a repair that touched no production code, the three-round cap, or a
criterion only the user can settle. An **owed** at the cap carries the loop's
hand-back command as well. Then stop.

Done when the implementation is written, the loop has returned with its word and
its per-round lines, the full suite has run over the tree as it finally stands —
after step 4, where that step changed it — every criterion has a proven state,
every box a repair unticked has been proved again or explicitly left red, the
loop's end is accounted for in one word with its grounds, and that summary is on
screen with nothing committed.
