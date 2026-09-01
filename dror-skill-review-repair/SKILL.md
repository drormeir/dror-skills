---
name: dror-skill-review-repair
description: Loop skill review and repair over one skill until it converges - dror-skill-review, then dror-skill-repair on what survived, round after round while a round is still owed. Use when the user names a skill and asks to check and fix it in one run, or to keep going until nothing is left.
context: fork
background: false
---

# dror-skill-review-repair

One run, one loop: `dror-skill-review` → `dror-skill-repair`, judged at the end
of each round, and round again while a round is still owed and the cap allows.
**Up to three rounds.** It is the pass you take **before** editing a skill that
has sat untouched while the repo moved — bring its text back in line, then work
on it — and never a step inside a chain. Nothing else — no code is read for
anything but evidence, no test is written, no skill is redesigned.

This file adds the order, the skill the run starts from and the judgement of
when to stop, and nothing else. Both steps are invoked as themselves and each
fetches what it needs. It is **convention-bound** (ADR 0011), inheriting the
binding from `dror-skill-review`: it takes a skill by name, so it assumes
skills as directories holding a `SKILL.md`, resolved by the rule
`dror-skill-review`'s own file states — including the path escape hatch and
the stop on no match.

**This run has a context of its own, and so does each of its steps.** The
frontmatter forks this file (ADR 0036), so what reaches it is this file and its
arguments — the skill, the focus — never the conversation that invoked it.
`dror-skill-review` and `dror-skill-repair` are forked the same way, which is
what "Each step runs in its own context" below rests on.

## What this run is given

**One skill, named as one.** A bare word is easy to misread: `review` is a
skill, a verb, half of three skill names — and running this loop on the wrong
one spends every round correcting sentences nobody asked about. So the name
must arrive as a skill's own — `dror-prove`, a path to its directory — and
given one that resolves to nothing or to two, ask which was meant. That is the
one question this skill stops for.

A **focus** is optional and free-form: a sentence about why the skill is being
checked now, a shelf file that moved, a run of it that misbehaved. It is
carried into every round's review and every round's repair as **one short
paragraph of context**, so the rounds judge one reading and not several.

**Focus never narrows anything.** The review reads the whole directory and
runs the lenses it chooses; a focus that mentioned two sentences does not
excuse the rest. What it buys is a lens that knows why the question was asked.

**The whole loop is one piece of work.** However many rounds it takes, the run
ends once, leaving the edited files for the user to read and commit.

## What this loop does not repair

One of the five kinds `dror-skill-review` reports is **not** this loop's work:
a **`conflict`** — two documents owning one rule differently, or two skills
deciding one question two ways — is a choice, and somebody must make it. It
goes to the user with both passages quoted.

**A `conflict` never makes a round owed.** A round that returned nothing else
has repaired nothing and will find the same conflict again, so a loop that
rounded on it would run to its cap correcting nothing. Say so in the round's
line and stop.

## 0. Know what is already in the tree

**Resolve the name to a directory first**, since every command below needs one
and round 1 has not run yet: `dror-skill-review`'s own resolution rule holds,
and its stop on no match is this run's stop as well.

Then read the skill's own state before round 1, and say what you find:

- `git log -1 --format=%h\ %ad --date=short -- <the skill's directory>` — the
  commit and date the skill last moved.
- `git status --porcelain <the skill's directory>` — whether it is already
  dirty.

**A skill with uncommitted edits already in the tree is a report, not a
stop.** Somebody is part-way through editing it — possibly the user, possibly
another run — and every round of this loop will review that work as though the
review had asked for it. Name it in one line before round 1 and carry the line
into the summary, so a finding against a sentence the user wrote five minutes
ago reads as what it is.

**A caller that already knows why the directory is dirty says so**, and then
this step repeats none of it: take the caller's account and name only what it
did not cover.

## Rounds

Each round is **review, then repair, then judge**. Announce the round before
its review — `round 2 of at most 3` — for the transcript and the summary; a
forked run's text reaches nobody until it returns (ADR 0042), which is what
the notification below is for.

**Fire one `notify-send` as each round begins, best-effort:**

```
notify-send "skill-review-repair <name> · round <k> of at most <cap>" "<the focus, in a few words>"
```

Ignore its exit status and never let it gate a round — it is absent on a
headless box and on macOS, and a cosmetic channel must not stop a loop. This
run is what the user typed — nothing invokes this loop from a chain — so there
is no caller's silence to honour, and the notification is the one thing a
watcher gets between the command and the summary.

### Each step runs in its own context

Steps 1 and 3 each run in an agent of their own, and nothing here arranges it:
`dror-skill-review` and `dror-skill-repair` carry `context: fork` in their
frontmatter (ADR 0036), so invoking either as a skill runs it apart from this
context and lands only its closing summary here. The prompt each step writes
below is that invocation's argument — the one thing that reaches the fork. A
review that reads a skill's directory, the files it points at and a fan-out of
refuters, three times over, reads far more than one context should hold, and a
loop that runs out of window mid-round loses the judgement it exists to make.

**This costs nothing, because the handoff between the two is already a file.**
`dror-skill-review` writes its report and stops; `dror-skill-repair` reads
that report. The only things that have to survive a step are the report's path
and a short summary.

What each agent returns is exactly what step 4 weighs and what the summary
prints, and nothing else: **from the review** — the report path it wrote, how
many survivors, their kinds, and its own one-line verdict on **whether a
repair should follow**; **from the repair** — one line per item (what was
found, the outcome), which files it edited, and its own one-line answer to
**whether another review is owed**. From either, one word if a log under
`~/.claude/dror-skills/` could not be written — neither skill blocks on that,
so an agent that says nothing is taken to have written its lines.

What each agent is **given** is small on purpose: the prompt below and the
focus paragraph where there is one. Not the previous rounds' transcripts, not
the previous report, and **not a list of what earlier rounds repaired** — a
round exists to review the sentences the last repair wrote, and a lens told
that a sentence has already been fixed is being asked to trust the very thing
it is there to check.

Keep in **this** context only the per-round lines, the report paths, the
conflicts and the word step 4 answered. That is the whole state of the loop.

### The run's own report name

Before round 1, mint a **run tag** by the store's recipe and use it for the
whole run: round `<k>`'s report is
`<repo>/.claude/dror-skills/skill-review-report-<name>-<tag>-r<k>.md`,
`<name>` being the skill's name. This is the caller naming the path, which
`../dror-internal-shared/REPORT-STORE.md` makes the answer over any name the
review would derive.

**The tag is the run's and the suffix is the round's**, so the loop leaves one
file per round rather than one file — the same arrangement as the other two
loops', and ADR 0041's decision ("each round keeps its report") is why: an
earlier round's grounds are the only evidence of what that round had in front
of it, and a single overwritten path destroys them as they are made.

**It is what makes two copies of this loop safe in one checkout.** Two runs
over one skill both reach for `skill-review-report-<name>.md`, and the second
overwrites the first's findings — a report a repair is about to read. A tag
costs one command and removes the case.

Say the tag once, on screen, before round 1. It is the only way a reader
looking at a directory of reports can tell which file is this run's.

**It does not make two copies safe in one *skill*.** Both loops still repair
the same prose at the same time, and a directory of documents has no seam a
tag divides: the second writer edits text the first has already moved. So
**look for the other run and say what you find**, before round 1 and once
only: list `<repo>/.claude/dror-skills/` and read the front matter of every
`skill-review-report*.md` that is not this run's. **Not this run's** means
every file carrying this run's tag, whatever its round suffix — before round 1
there are none of them, so this costs the check nothing. A recently-written
report under another tag naming **this** skill is another run on it — name it
on screen, carry it into the summary, and pass it into every round's repair.

**It is a report, not a gate** (ADR 0024). What is available is that neither
run is surprised; a user who wants the two kept apart runs them on different
skills.

### 1. Review

Invoke the `dror-skill-review` skill, with the focus paragraph where this run
has one:

> Review the skill `<name>`, at `<the directory step 0 resolved>`. Report the
> survivors and edit no text. Write your report to
> `<repo>/.claude/dror-skills/skill-review-report-<name>-<tag>-r<k>.md` — that
> name is this run's and overrides the name you would derive. Use `<tag>` as
> your run tag, so every round's finding ids carry it. This is **round `<k>`**
> of this loop; log it as that round. `<Where the concurrency check saw a
> neighbour: another run is on this skill — …, last seen at … — write its tag
> in your run row's `concurrent` column.>` For context, why this skill is
> being checked now: `<the focus paragraph>` — focus, not scope; read the
> directory whole.

It finds and stops, which is what keeps the repair a separate step: the report
is written before a sentence is changed. **That stop is the review's, not this
run's** — `../dror-internal-shared/DELEGATION.md`, the shelf beside this
skill, owns what that means and why this step ends the way it does, at
authoring time. A written report is **a deliverable's shape**, and the
review's closing stop is **a prohibition against guidance** — the two shapes a
run ends on by mistake, in DELEGATION.md's words. So this step's named next
action: **immediately after the review returns, and in the same turn, list
`<repo>/.claude/dror-skills/` and confirm the file it named is there** — or,
where it named none, **read what it returned instead**. A review that returned
`EMPTY SKILL:` reviewed a skill that is frontmatter and no procedure, which
step 0's `git` questions cannot see coming: that is not an error, so say what
it said and print §Present's summary. A review that named no report and did
**not** return that line has broken — it stopped before writing anything, and
its findings, if any, are lost. Say so plainly, do not read its silence as an
empty skill, and do not invoke it again in the same round without saying that
is what you are doing. That call is this step's last move, and it
is the "path step 1 confirmed it wrote" that step 3 passes on.

**Confirm the path; do not read the report.** Step 2 judges from the review's
own returned verdict and survivor list, and the loop's context holds only what
the rule above allows it. The report is written for `dror-skill-repair` to
read. Nor is this listing the concurrency check — that one reads other runs'
front matter and runs once, before round 1; this one confirms one path and
runs every round.

### 2. Exit if nothing needs repairing

**A review with no survivors ends the loop, here, before any repair.** Nothing
to repair means nothing new to review, and this is the ordinary way a run
converges. Say so and skip to the summary. The report's `## Refuted` section
is not the list — those findings were raised and disproved.

**A review whose survivors are all `conflict` ends it the same way.** There is
no sentence for `dror-skill-repair` to write, so a repair round would produce
a report of `Left — needs a decision` rows and change nothing. Carry them out
by the door above and stop.

Otherwise take the review's own verdict on whether a repair should follow. It
carries what the count cannot, and a run that repairs against the review's
"nothing here needs an edit" is inventing work under this loop's name.

### 3. Repair

Invoke the `dror-skill-repair` skill:

> Repair the findings in `<the report file step 1 named>`: every `text`,
> `hole`, `sprawl` and `echo`, each corrected sentence grounded in the tree as
> it stands, each restatement collapsed to a pointer, each echo synchronised
> in every copy it names. Redesign nothing. For context, why this skill is
> being checked now: `<the focus paragraph>`. The other reports in that
> directory belong to other runs — do not read or touch them. `<Where the
> concurrency check saw a neighbour: another run is editing this same skill —
> …, last seen at … — so a sentence changing under you may be theirs.>`

**Name this round's tagged file, never the store's default and never an
earlier round's.** The default `skill-review-report-<name>.md` may be another
run's entirely, and passing it sends this repair at somebody else's findings;
an earlier round's file sends it at findings this loop has already repaired.
Pass the path step 1 confirmed it wrote — this round's `-r<k>` file, or that
same name carrying a `-<k>` where the claim found another writer already
there. Any other name is a disagreement to say out loud rather than work
around.

`dror-skill-repair` has no suite to stand on: its evidence is that every
sentence it wrote was **grounded** in the tree, and its step 3 reads the
repaired files whole afterwards and greps the repo for old spellings. Take its
`ungrounded` items as they come — they are questions for the user, not work
for another round.

**The repair's summary is a step's result, not this run's reply**, and a
rewritten skill is a deliverable's shape (DELEGATION.md). So this step's named
next action, and it has two branches, both concrete: judge the round at step 4
and then **either invoke `dror-skill-review` again for the next round, in the
same turn, or print §Present's summary**. One of those two is how the turn
ends; a turn that relays the repair and does neither has stopped mid-round.

### 4. Judge the round

Weigh what happened, in this order:

- **What the repair says about itself.** It ends with its own word on whether
  another review is owed, and it is the one that watched every sentence land.
  Take it as the strongest single input — not as the decision, which is this
  step's and is bounded by the cap.
- **What the repair wrote.** Prose that landed is text no review has read —
  and here the prose is the machine, since an agent executes these files
  mid-run — so that is the case *for* another round: a review judges the skill
  as it stood *before* the repair touched it. An `echo` synchronised across
  several documents is the strongest form of it, since the copies were never
  in the reviewed directory at all.
- **What is left that a review cannot settle.** `ungrounded` items and
  conflicts are questions for the user, and another round asks them again word
  for word.
- **The trend across rounds.** A round returning the same findings as the last
  one, unrepaired, is not converging — it is a repair that could not ground
  them, and the answer is **no** with the question named.

**There is no round-1 floor here, and that is deliberate.**
`dror-code-review-repair` takes a second round whatever the first repaired,
because a single review pass was measured missing most of a code diff
(ADR 0023). That measurement is about a diff spread over files a pass has to
choose between; a skill is **one directory a lens reads whole**, and no such
recall gap has been measured for it. A floor here would be borrowing another
skill's evidence, so a round is taken on its merits from the first.

Answer in **one of three words**, with the grounds in a sentence:

- **owed** — the repair wrote prose that nothing has reviewed. Name the files.
  **Under the cap, take the round**: say so and go back to step 1.
- **optional** — the edits were narrow and local, or the only thing left waits
  on the user. Say what a round would look at, and **stop**: an optional round
  is the user's to ask for.
- **no** — nothing survived review, nothing was written, or every survivor was
  a `conflict`. **Stop.**

**The cap is three rounds and the run's own judgement does not raise it.** A
skill converges faster than a diff — one directory, one writer, and every
correction grounded before it is written — so the code loop's cap would be
that many readings of the same paragraphs. **A caller may name a lower one**,
and a lower cap binds exactly as three does, reported by number in every
round's announcement (`round 2 of at most 2`). A cap above three is refused,
whoever asks. At the cap the word is reported and the loop ends whatever it
says — an **owed** at round 3 names the files nothing has reviewed and hands
the user the command as it would be typed:

> `/dror-skill-review` on the skill `<name>`, writing its report to
> `<repo>/.claude/dror-skills/skill-review-report-<name>-<tag>-r<k+1>.md`,
> then `/dror-skill-repair` on what it finds in that file.

`<k+1>` and not the cap's own round: the user is being handed the round this
loop did not take, and pointing them at the last round's file would have them
repair findings this run already repaired.

Never write **owed** at the cap and stop silently; a reader would take the
stop for convergence.

The user may stop the loop at any point, and a run told to stop reports what
it has rather than finishing the round.

## Present

**One line per round**, in order, reading `round <k>: <n> survived, <what was
repaired>`. One line each, however many rounds ran: a reader wants to see the
curve flatten, and paragraphs hide it.

Then **why the loop ended**: the last round's word — **owed**, **optional** or
**no** — its grounds in one sentence, and where that word came from: a review
with no survivors, survivors that were all conflicts, a repair that wrote
nothing, the cap, or something only the user can settle. An **owed** at the
cap carries the command as well.

Then **what leaves this run for somebody else**, which is the part no round
repairs and the part a reader will otherwise lose:

- the **conflicts**, each as the question the user has to answer, with both
  passages the review carried;
- the **ungrounded** items, each with what could not be settled;
- any grep hit the repair's own check found that **no finding named** — the
  signal the next review should run `mirrors`.

Then say the skill is left uncommitted, name every file this run edited — the
skill's own files, and any index row, map entry or glossary line an `echo`
reached — and name what was written outside it: this run's report files, one
per round, and the logs under `~/.claude/dror-skills/` that every round
appends to — `refutations.tsv` and `runs.tsv` from each review, `repairs.tsv`
from each repair. Say if one could not be written. Then stop.

Done when every round that found repairable survivors has repaired them, every
round that found none is named as such, the repaired files have been read
whole after the last edit — `dror-skill-repair`'s own step 3, in the round
that made it — the loop's end is accounted for in one word with its grounds,
everything leaving the run for somebody else is named, and that summary is on
screen with nothing committed.

**The shortest legal run is one round that repairs nothing**: a review, no
survivors or none that this loop repairs, and a stop. It writes a report or
explains why there was none, appends its log lines, and satisfies every clause
above.
