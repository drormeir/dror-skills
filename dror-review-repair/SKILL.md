---
name: dror-review-repair
description: Loop review and repair over the unpushed work until it converges - dror-review, then dror-repair on what survived, round after round while a round is still owed. Use when the user asks to review and fix in one run, or to keep reviewing until nothing is left.
---

# dror-review-repair

One run, one loop: `dror-review` → `dror-repair`, judged at the end of each
round, and round again while a round is still owed and the cap allows. **At
least two rounds wherever the first one repaired anything, and up to seven.**
Nothing else — no implementation, no criteria tests, no `dror-prove`.

This file adds the order, the tree the run starts from and the judgement of when
to stop, and nothing else. Both steps are invoked as themselves and each fetches
what it needs. It is **repo-agnostic** — it names no tracker, no path and no
runner of its own — but it does assume **git**, unconditionally: what it reviews
is the unpushed commits plus the working tree, narrowed only where the caller
says so.

## What this run is given

This skill takes a **focus** and a **scope**, both optional. Given neither, it
reviews and repairs every unpushed file with no context beyond the diff, which is
the ordinary run.

A caller invoking it as a step of its own chain may also set two things the
sections below define: a **lower round cap**, and the declaration that a
**`dror-prove` follows**, which is what lets the ticket travel down to both
sub-skills. A user asking for a review-and-repair sets neither.

The focus is **free-form**: a ticket number, a path or two, a sentence about what
the work was meant to do. Whatever arrives, it is carried into every round's
review and every round's repair as **one short paragraph of context**, so the
rounds judge one reading of the work and not several.

**A bare number is never read as anything.** `42` is a ticket, an ADR, a line, a
build, a version — and fetching the wrong one gives every round of this run a
false account of what the work was for. So a number must arrive **labelled**:
`ticket 42`, `ADR 0007`, `issue #42`, `PR 42`, `line 42 of foo.py`. Given an
unlabelled one, ask which it is; that is the one question this skill stops for,
and it costs a sentence against a whole run spent on the wrong document.

Only a **ticket** is fetched. Read it the way the **issue convention** fact says
this repo tracks work, and pass its substance down as the focus paragraph: what
the work was for, and what it was meant to satisfy. Pass it as *context*, never
as the sub-skills' ticket argument unless a prove follows — the next section says
why.

Any other labelled thing is carried as **text, unfetched**: an ADR number, a
design note, a file and line. This skill reviews unpushed code and has no
business reading a decision record to decide what a lens should think; where the
caller wants an ADR's substance in the focus, the caller reads it and passes the
paragraph.

**Focus never narrows anything.** A file the focus mentions and a file it does
not are reviewed alike; only the scope argument below changes what is looked at.
What the focus buys is a lens that knows what the work was trying to do, so it
stops reporting a deliberate choice as a defect, and a repair that knows what a
fix must not break.

**Narrowing the scope is a separate argument**, and only where the user asks for
it: `dror-review` takes a scope in plain text — paths, globs, named functions, a
`file:line` range — defaulting to every unpushed file. Where this run was given
one, pass it unchanged into **every** round's review, exactly as given; a scope
that drifts between rounds means round 3 reports what round 1 was told to ignore.
Say what it leaves out, once, before round 1. Never infer a scope from the focus:
a ticket naming two files is a hint about where to look, not an instruction to
review nothing else.

## No box moves, unless a prove follows

Handed a **ticket number** of its own, `dror-repair` clears the `- [x]` of any
criterion whose test it watched go red, and `dror-review` mints `unmet criterion`
findings against the criteria list. Both are right in a ticket run, where
`dror-prove` is there to tick a box back and to implement what nobody did.

This skill has no `dror-prove` in its loop, so by default an unticked box would
stay unticked at the end of the run and read as work undone. So by default
**neither sub-skill is given the number** — the ticket's substance travels as
focus text instead, and this run moves nothing in any ticket body.

**The caller may say that a prove follows**, and then the default is off: pass
the ticket number to every round's review and every round's repair, and let both
do their ticket work. Only a caller that will run `dror-prove` over the still-
unticked boxes *after* this loop returns may say so — `dror-implement-ticket` is
the one that does — and it is the caller's word that is trusted here, since this
skill cannot see what happens after it returns. Say in the summary which boxes
moved, so the caller's prove knows its list without re-deriving it.

It **commits nothing** either. The run ends with the tree changed and
uncommitted; what to commit is the user's call.

## 0. Know what is already in the tree

`dror-review` reviews **everything unpushed**, not a diff this run produced, so
work that was in the tree before the run started is reported and repaired by it.
That is usually exactly what was wanted here — unlike a ticket run, this skill
was asked for a pass over the tree as it stands — so it is a **report, not a
stop**.

**A caller that already knows why the tree is dirty says so, and then this step
repeats none of it.** A chain that just wrote an implementation is handing over
its own work on purpose; announcing it as "work already in the tree" tells the
reader the opposite of what happened. Take the caller's account, name only what
it did *not* cover, and where it separately marks work as pre-existing, keep that
mark — it is the one thing that stops a repair fixing another ticket's code under
this run's name.

Ask both, and say what they answer:

- `git status --porcelain` — uncommitted or untracked work.
- `git rev-list --count <base>..HEAD` — commits ahead of the review's base.

**`<base>` is `dror-review`'s base, found `dror-review`'s way**, or this run
names a scope the review will not use: `git rev-parse --abbrev-ref
--symbolic-full-name @{upstream}` and count from `git merge-base @{upstream}
HEAD` where there is one; with **no** upstream, `git merge-base origin/HEAD HEAD`,
then `origin/main` or `origin/master` where `origin/HEAD` is unset. A repo with
no usable remote ref at all has nothing to count against, and there everything is
unpushed by definition — say that rather than a number. Name which of the three
you used; step 1 will name it again and the two must agree.

**Both empty ends the run before it starts.** Nothing unpushed is nothing to
review, and `dror-review` would stop on the empty diff one step later anyway.
Say so and stop.

## Rounds

Each round is **review, then repair, then judge**. Announce the round before its
review — `round 2 of at most 7` — so a reader watching a long run can tell a
second pass from a stuck one.

### Each step runs in its own context

Steps 1 and 3 are each **spawned as one subagent**, told to invoke the skill
named and to work in that agent's own context — not run in this one. Seven rounds
of review and repair read far more than a single context should hold, and a loop
that runs out of window mid-round loses the judgement it exists to make.

**This costs nothing, because the handoff between the two is already a file.**
`dror-review` writes its report and stops; `dror-repair` reads that report. The
only things that have to survive a step are the report's path and a short
summary, so an agent boundary between them drops nothing a later round needs.

What each agent returns is exactly what step 4 weighs and what the summary
prints, and nothing else: **from the review** — the report path it wrote, how
many survivors, their kinds, which files they name, which lenses it dropped, and
its own one-line verdict on **whether a repair should follow**; **from the
repair** — one line per finding (what was found, the outcome), which files it
edited and whether any of them is **production** code, the verification run's
summary lines, and its own one-line answer to **whether another review is owed**.
From either, one word if a log under `~/.claude/dror-skills/` could not be
written — neither skill blocks on that, so an agent that says nothing is taken to
have written its lines, and the round is on the record. A step that returns a narrative instead of those facts has to be
asked again, which is the one way this arrangement costs more than it saves.

**That verdict is what step 2 reads**, and it is the review's to give because the
review is the one that met the findings: survivors that are all `Ruled out`
waiting to happen read differently from one confirmed crash, and a count alone
cannot say so. Step 2 follows it — no repair where the review says none is
warranted — and where the two disagree with the count, say so rather than pick
silently.

What each agent is **given** is small on purpose: the prompt below and the focus
paragraph where there is one. Not the previous rounds' transcripts, not the
previous report, and **not a list of what earlier rounds repaired** — a round
exists to review the code the last repair wrote, and a lens told that code has
already been fixed is being asked to trust the very thing it is there to check.
The current report is the open list, and it is written from the tree as it stands
now.

Keep in **this** context only the per-round lines, the report paths, and the word
step 4 answered. That is the whole state of the loop.

### The run's own report name

Before round 1, mint a **run tag** by the store's recipe
and use it for the whole run: the report is
`<repo>/.claude/dror-skills/review-report-<tag>.md`, every round. This is the
caller naming the path, which `../dror-internal-shared/REPORT-STORE.md` makes the
answer over any name the review would derive.

**It is what makes two copies of this loop safe in one checkout.** A ticketless
review takes the plain `review-report.md`, and the reference tells reports apart
by ticket number alone — so two ticketless runs are indistinguishable and the
second silently overwrites the first's findings, which is a report a repair is
about to read. A tag costs one command and removes the case.

Say the tag once, on screen, before round 1. It is the only way a reader looking
at a directory of reports can tell which file this run's is.

**It does not make two copies safe in one *tree*.** Both loops still review the
same unpushed work and repair it at the same time; the tag keeps their reports
apart and nothing else.

So **look for the other run and say what you find**, before round 1 and once
only: list `<repo>/.claude/dror-skills/` and read the front matter of every
`review-report*.md` that is not this run's, exactly as `dror-review`'s own
concurrency check does. A recently-written report under another tag is another
run in this tree. Name it on screen, carry that line into the summary, and
**pass it into every round's repair** — a repair meeting a failing test it did not
cause needs to know somebody else is editing, and that is the one place the
knowledge changes what happens rather than merely what is reported.

**It is a report, not a gate.** Isolating the two runs is the obvious answer and
it is not available here: this repo is worked concurrently on purpose, worktrees
are ruled out, and a lock would block a run somebody wants. What is available is
that neither run is surprised — see ADR 0024. A user who wants the two kept apart
gives them **disjoint scopes**, which the scope argument above already supports
and which nothing but the caller can decide.

### 1. Review

Invoke the `dror-review` skill, with the focus paragraph where this run has one
and no ticket number:

> Review the unpushed work. Report the survivors and change no behaviour. Write
> your report to `<repo>/.claude/dror-skills/review-report-<tag>.md` — that name
> is this run's and overrides the name you would derive. Scope: `<the scope, or
> "every unpushed file">`. For context, what this work was meant to do: `<the
> focus paragraph>` — focus, not scope. No ticket is passed to this run.

It finds and stops, which is what keeps the repair a separate step: the report is
written before anything is changed.

### 2. Exit if nothing needs repairing

**A review with no survivors ends the loop, here, before any repair.** Nothing to
repair means nothing new to review, so this is the ordinary way a run converges.
Say so, skip to the summary, and do not invent work to do. The report's
`## Refuted` section is not the list — those findings were raised and disproved.

**A review that wrote no report at all ends it the same way**, and that is not an
error: `dror-review` writes none when the diff it captured is empty, which a
narrow scope can produce even on a busy tree. Say which of the two happened.

Otherwise take the review's own verdict on whether a repair should follow. It
carries what the count cannot — a survivor that is a hazard for a later reader is
not the same call as a confirmed crash — and a run that repairs against the
review's "nothing here needs an edit" is inventing work under this loop's name.

### 3. Repair

Invoke the `dror-repair` skill:

> Repair the findings in `<the report file step 1 named>`: every confirmed bug
> and every gap in cover, each red before its fix and green after. For context,
> what this work was meant to do: `<the focus paragraph>` — a fix must not break
> it. The other reports in that directory belong to other runs — do not read or
> touch them. `<Where the concurrency check saw a neighbour: another run is
> editing this same working tree — …, last seen at … — so a file changing under
> you, or a test failing in code you did not touch, may be theirs.>`

**Name the tagged file, never the store's default.** The default
`review-report.md` may be another run's entirely, and passing it sends this
repair at somebody else's findings. Pass the path step 1 confirmed it wrote — it
should be the tagged one, and a review that reports any other name is a
disagreement to say out loud rather than work around.

**A fix that lands outside a narrowed scope is reported, not hidden.** The
repair's list comes from the report, so it normally stays inside — but a fix
reaching a file the scope excludes is code **no round of this run will ever
review**, since every round is narrowed the same way. The repair returns the
files it edited; compare them against the scope, and where one falls outside, say
so in that round's line and again in the summary. It is not an error and nothing
stops for it.

`dror-repair` runs the project's full suite, lint and type-check as its own gate,
and the suite is owed to the **last code change** — so a round whose repair
changed nothing at all owes no rerun, and every other round's evidence is that
repair's own run. Name the run that counted.

### 4. Judge the round

Weigh what happened, in this order:

- **What the repair says about itself.** It ends with its own word on whether
  another review is owed, and it is the one that watched every edit land. Take it
  as the strongest single input — not as the decision, which is this step's and
  is bounded by the cap. Where it says **yes** and the files it names are
  production code, the answer below is almost always **owed**. Its **tests
  alone** is a report on what it edited and not a recommendation to stop: at
  round 1 the floor takes the round anyway, and from round 2 on it is the
  ordinary case for **optional**.
- **What the repair changed.** A repair that edited production code — especially
  a file the review never named — is the strong case *for* another round: a
  review judges the diff as it stood *before* the repair touched it, so every
  repair leaves behind code nothing has reviewed. A repair that only added tests
  is a weaker case from round 2 on — a test changes nothing a lens reads for
  defects — and is no case at all at round 1, which the floor below settles
  before this weighing starts.
- **What the review said about itself.** Survivors clustered in one file, or
  mostly from one lens, have told you where a further pass would look. Nothing
  found across a large diff is the other reading, and worth one sentence either
  way.
- **The trend across rounds.** Fewer findings, of a lighter kind — a bug, then a
  gap, then a wording — is convergence, and another round buys the tail of a
  curve that has flattened. More findings, or heavier ones, says the diff is
  still moving.
- **What is left that a review cannot settle.** A finding whose fix waits on the
  user, or one deferred on the user's instruction, is not what another round is
  for.

**Round 1 is half a review, and the floor says so.** Where round 1 repaired
anything at all, round 2 runs — whatever the repair touched, and whatever the
weighing above would otherwise have said. The word for that round is **owed**,
with "the round-1 floor" as its grounds, and the loop goes back to step 1.

This is not a judgement about the repair; it is the measured recall of a single
review pass. One review does not cover a diff of any size: at `8681800` round 1
returned 4 findings in two files and round 2 returned **15** in two files round 1
never opened and the repair never touched. At `94cb2b6` round 1's one finding was
a gap in cover whose repair added a test and edited no production code — the
textbook **optional**, and a stop — and round 2 then found 9 findings across four
files nobody had looked at. So rounds 1 and 2 are one review split in two, and
the convergence judgement below is what governs from round 3 on.

The floor **never overrides the cap**: a caller that named a cap of one gets one
round, and the floor is reported as unmet rather than taken. It does not apply
where step 2 already ended the run — a review with no survivors, or one whose own
verdict was that no survivor needs an edit, means no repair happened and there is
nothing a second pass would be reviewing the results of. And it is spent once:
having run round 2, the loop weighs round 2 on the merits like any other.

Answer in **one of three words**, with the grounds in a sentence:

- **owed** — the repair changed production code that nothing has reviewed. Name
  the files. **Under the cap, take the round**: say so and go back to step 1.
- **optional** — repairs were confined to tests, or were small and local. Say
  what a round would look at, and **stop**: an optional round is the user's to
  ask for, and taking it automatically is how seven rounds becomes fourteen.
  **Never the answer at round 1 where a repair happened** — the floor above has
  already taken that round, and this word is what used to end a run one round
  before most of its findings.
- **no** — nothing survived review, or nothing was repaired, or the only thing
  left waits on the user. **Stop.**

**The cap is seven rounds and the run's own judgement does not raise it.** The
thing deciding whether another round is worth it is the same model that just did
the work, and it leans toward one more; the cap is what makes that lean harmless.
**A caller may name a lower one** — a chain that runs this loop as one of its own
steps has other work waiting and pays for these rounds twice over — and a lower
cap binds exactly as seven does, reported by number in every round's
announcement (`round 2 of at most 3`). A cap above seven is refused, whoever asks.
At the cap the word is reported and the loop ends whatever it says — an **owed**
at round 7 names the files nothing has reviewed and hands the user the command as
it would be typed:

> `/dror-review`, writing its report to
> `<repo>/.claude/dror-skills/review-report-<tag>.md`, then `/dror-repair` on
> what it finds in that file.

**Carry the tag into that command.** Typed without it, the review takes the
default `review-report.md` — which may be another run's, and is not the file this
run's reader is watching.

Never write **owed** at the cap and stop silently; a reader would take the stop
for convergence.

**Each round overwrites the last round's report**, because this run hands every
round the one tagged path. That is deliberate, not a limitation of the naming: a
per-round file would keep the trail, and the trail is not read — step 4 weighs
what the repair agent **returned**, and `~/.claude/dror-skills/repairs.tsv` keeps
each finding's outcome keyed by its id for a later retrospective. What the file
holds is therefore always the open list, which is what the next repair needs. A
round's findings a reader will want later belong in this run's summary, not in a
file the next round replaces.

The user may stop the loop at any point, and a run told to stop reports what it
has rather than finishing the round.

## Present

**One line per round**, in order, reading `round <k>: <n> survived, <what was
repaired>`. One line each, however many rounds ran: a reader wants to see the
curve flatten, and paragraphs hide it.

Then **why the loop ended**: the last round's word — **owed**, **optional** or
**no** — its grounds in one sentence, and where that word came from: a review
with no survivors, a repair that touched no production code, the cap, or
something only the user can settle. An **owed** at the cap carries the command as
well.

**Where a ticket travelled down** — a caller that said a prove follows — one more
line: which boxes the repairs unticked, by criterion number. It is what the
caller's prove takes as its list, and this run is the only one that watched them
move.

Then say the tree is left uncommitted, and name what was written outside it: this
run's report file, and the three logs under `~/.claude/dror-skills/` that every
round appends to — `refutations.tsv` and `runs.tsv` from each review,
`repairs.tsv` from each repair. **They are the point of running the rounds at
all** as far as a later `dror-review-retrospective` is concerned: one `runs.tsv` line
per round is what lets it see whether the findings thinned out, and a run that
skipped a log has lost that round from the record for good. Say if one could not
be written. Then stop.

Done when every round that found survivors has repaired them, every round that
found none is named as such, the full suite has run over the tree as it finally
stands **wherever this run changed it** — a run that repaired nothing changed
nothing and owes no suite — the loop's end is accounted for in one word with its
grounds, and that summary is on screen with nothing committed.

**The shortest legal run is one round that repairs nothing**: a review, no
survivors or a verdict that none needs an edit, and a stop. It writes a report or
explains why there was none, appends its `runs.tsv` line, and satisfies every
clause above. **A round that repairs anything is never the shortest run** — the
floor in step 4 takes a second one — so a one-round run that edited a file is a
run that stopped early, and is the one shape of this loop that is wrong.
