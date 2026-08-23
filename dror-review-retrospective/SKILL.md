---
name: dror-review-retrospective
description: Read the review log across runs and say what the lenses are getting wrong - which one produces false positives, which recurring assumption causes them, and what wording to change. Reports and stops.
disable-model-invocation: true
---

# dror-review-retrospective

This skill **reads history**. It says what `dror-review`'s lenses are getting
wrong across runs and what to change about them, and it stops there: no lens
section is edited until the user says which.

One run's kills say nothing — a lens that got one finding wrong on one diff got
one finding wrong. What this reads is the accumulation.

## The log

`~/.claude/dror-skills/refutations.tsv`, one line per merged finding, appended by every
`dror-review` run and never rewritten. Tab-separated; the columns are whatever
its own header row names — `dror-review` owns the schema and this skill assumes
none of it, so the log stays self-describing if the schema grows. The columns
read here are `date`, `repo`, `lens`, `path`, `verdict`, `claim` and `summary`;
a header missing one of those makes the questions that need it unanswerable,
which is said rather than guessed around.

`lens` is the lens that raised it, or several joined by `+` where the merge
folded them together. It is a **closed vocabulary** — a section name from
`dror-review/LENSES.md` or from `dror-adr-review/LENSES.md`, or the reserved
`criterion` — so a name outside that set is a
defective row from an older run, not a lens to report on: count it out, and say
how many rows were dropped and under what names.

The two pools answer different questions and their rates are **not comparable**
(ADR 0020): a code lens's finding is about a diff, an ADR lens's is about a
sentence, and a document's `hole` is refuted on grounds no code finding faces.
Report them apart, and never rank a lens of one against a lens of the other. The log written before this rule
carries five rows under `spec`. `verdict` is `survived`, `refuted` or `unverified`. Every
merged finding faces a refuter, so a line is never here unjudged. `claim` says
whether a claim comment was written where the refutation turned on an invisible
invariant.

## The two files beside it

Both are optional. A run that finds neither answers the questions it can and
says which it could not — they were added after the log, so early rows are
covered by neither.

`~/.claude/dror-skills/runs.tsv` — one line per review, holding the lenses **run** and
the lenses **dropped**. It is what supplies the denominator the log cannot: a
lens that ran and found nothing writes no finding, so without this file a lens
selected twice and a lens selected thirty times are indistinguishable, and a
lens with no rows at all could equally be one nobody chose or one that came back
clean every time. Say which, rather than reading a silence.

`~/.claude/dror-skills/repairs.tsv` — one line per finding a repair handled, keyed by
the report's id, carrying that run's outcome word. **Join on the whole string and
never on its parts**: the id has three shapes by age — `<head>-<n>`,
`<head>-<hhmm>-<n>` and `<head>-<tag>-<hhmm>-<n>` (ADR 0025) — and splitting on
`-` reads one shape's tag as another's minute. A **survivor** whose outcome is
`Couldn't reproduce` or `Ruled out`
is a finding that passed a lens and a refuter and was still wrong: it is a false
positive the review scored as a success, and it belongs in question 1's numbers
beside the refuted ones, named as the different thing it is. Rows with no id sit
this question out.

**An id that appears twice is a collision, not a repeat, and it is reported
rather than counted.** Two findings under one key are two different defects whose
outcomes cannot be told apart; the pair predates the tag and is bounded by it, so
say how many you found and drop them from the join. Counting one of them would
attribute a repair's answer to the wrong finding, and averaging them would invent
a third.

A missing log ends the run: say there is nothing to read yet and stop. A log
with fewer than about twenty findings in it ends the run the same way — the
answer would be noise, and a wording change made on noise costs the next review
its recall. Say how many lines are there and how many are wanted.

Read the whole file. It is one line per finding and stays small for years.

## What to look for

Six questions, in this order. Each is answered from the log, with the counts
that support it.

**Which lens is imprecise.** Refuted over total, per lens. A lens is not
imprecise because it has many kills — the busiest lens has the most of both.
Only the *share* is the signal, and only against the others: a lens killing at
twice the rate of its neighbours is the one whose section is too loose. Report
the rates side by side so the reader can see the baseline.

**Say what this question cannot see, every time you answer it.** It scores a
lens on the share of its findings that died, so every reading of it argues for
narrowing — and narrowing spends recall, which nothing in these files records: a
bug no lens raised leaves no row. A propose-then-refute design is *meant* to kill
findings (ADR 0003) and no one has ever said what rate is right, so a high share
is a question and not a verdict. One sentence saying so, beside the numbers.

Count a `+`-joined line for each lens named in it: the merge folding two lenses'
findings together is not evidence against either one.

**Rank no lens on fewer than twenty findings of its own.** The whole-log floor
above says why, and it applies again per lens: a log of four hundred rows can
still rest a lens's rate on seven of them, and a wording change bought at that
price costs the next review its recall. Under the floor, print the count and
leave the rate unranked.

The floor is on **rates, and on nothing else**. The question below reads
refuted findings for what they claimed, and a belief that recurs three times in
three runs is a real pattern at n=3 — a repeated wrong assumption is a
qualitative reading, not a proportion, and gating it on twenty rows would
discard the most useful thing in the file.

**Which assumption recurs.** Group the refuted summaries by what they claimed,
not by where. The same wrong belief arriving from different files across
different runs — "this can be `None`", "this path is not locked", "this is not
validated" — is a lens reasoning from something the codebase does not do. This
is the finding worth the run; the rate above only says which lens to read.

**Which lenses never earn their agent.** A lens whose findings are almost all
refuted, or which raises almost nothing across many runs, is costing a subagent
per review for nothing. Say so plainly, with its numbers — **findings per run it
was selected for**, from `runs.tsv`, not findings per row of the log. Without
that file the question cannot be answered at all for a lens with no rows, and
saying so is the answer.

**Whether a run's lens choice explains its numbers.** A diff of documents
reviewed through the code lenses gives `clone` nothing to enumerate and
`collateral` everything; a rate pooled over such a run is measuring the
selection, not the lens. Read `runs.tsv` for a run whose lens set or whose
changed paths sit apart from the rest, and name it as a confound rather than
folding it in.

**What a round found that the round before it had in scope.** The one question
about **recall** these files can carry, and the reason `repairs.tsv` records
`files_edited`. Order a head's rounds by the id's tag and minute — same tag,
ascending minute — and for each round after the first, count the findings whose
`path` the *previous* round's repair never edited. Those are findings the
previous round's review had in front of it and did not return.

Report it as a share per round index, never as a rate against anything else, and
say the count it rests on. It is **one-directional**: it counts misses that a
later round happened to catch, and can never see a miss nobody caught, so a low
number is not evidence of good recall. It is also unavailable before
`files_edited` existed and unreadable across rounds whose ids carry no tag — a
"round" assembled out of two concurrent runs is not a sequence, and ADR 0024's
`concurrent` column is what says which runs those were. Where either is missing,
say the question cannot be answered for those rows rather than approximating the
repair's reach from the previous round's findings, which overstates it.
**`unchecked` in that column is missing, not empty** — it is the word a review
that runs no neighbour check of its own writes (ADR 0027), and reading it as
"nobody else was here" is the confound the column exists to prevent.

**Where the code keeps needing claims.** Group the `claim = yes` lines by
`path`. A file that repeatedly makes reviewers reach the wrong conclusion is a
file whose reasoning is not written down, and the answer there is a comment in
that code, never a change to a lens.

**Normalise a per-file count before reading anything into it.** Claims, findings
and kills all follow how much a file changed, so a raw count names the busiest
file and nothing more. Divide by that file's own findings and compare against the
whole-log share; a file at the baseline is unremarkable however tall its bar.

Say when the log cannot answer a question — too few runs, one repo only, one
lens dominating the lines. A guess presented as a reading is worse than a gap,
because a lens edited on it gets narrower for no reason.

## Propose, do not edit

For each finding above, name the concrete change and quote the current wording.
Three things can be the target, and the question decides which:

- A lens raising false positives is a section of
  `~/.claude/skills/dror-review/LENSES.md` — name the sentence or bullet.
- Refuters killing real bugs, or letting weak findings through, is
  `~/.claude/skills/dror-review/REFUTING.md`.
- A file that keeps needing claims is neither: the change belongs in **that
  project's code**, as a comment, and no skill edit will help.

**Recall is what a wording change spends.** A lens narrowed until it stops
producing false positives stops producing findings, and the review's misses are
invisible — nothing in this log records a bug that nobody raised. So a proposal
has to say what the narrower wording would no longer catch. One that cannot say
is not ready to be made.

Then stop and wait. The user picks which proposals to apply; applying one is the
next turn's work, not this one's.

## Present

Every answer with its counts, then the proposals, then stop. No file is
written — this skill reads the log and changes nothing, including the log.

Done when every question above is answered with its counts or named
unanswerable, the imprecision question carries its own sentence about what it
cannot see, every proposal quotes the wording it would change and says what
the narrower wording would no longer catch, and nothing was edited.
