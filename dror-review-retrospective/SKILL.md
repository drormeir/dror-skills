---
name: dror-review-retrospective
description: Read the review logs across runs and say what the lenses are getting wrong and what the rounds are worth - which lens produces false positives, which recurring assumption causes them, what a later round caught that an earlier one had in front of it, and what a round costs. Reports and stops.
disable-model-invocation: true
---

# dror-review-retrospective

This skill **reads history**. It says what the lenses are getting wrong across
runs and what to change about them, and it stops there: no lens section is
edited until the user says which.

**Both pools are in scope** — `dror-code-review`'s lenses and `dror-adr-review`'s —
because both write the one log. What they are never allowed is to be read
against each other: their rates answer different questions, and the rule for
keeping them apart is in "The log" below.

One run's kills say nothing — a lens that got one finding wrong on one diff got
one finding wrong. What this reads is the accumulation.

## The log

`~/.claude/dror-skills/refutations.tsv`, one line per merged finding — plus
the unmerged `tool` rows (ADR 0045) — appended by
every `dror-code-review` and every `dror-adr-review` run and never rewritten.
Tab-separated; the columns are whatever its own header row names — the shelf's
`REPORT-STORE.md` owns the schema and this skill assumes none of it, so the log
stays self-describing if the schema grows. The columns
read here are `date`, `repo`, `lens`, `path`, `verdict`, `claim`, `summary`,
`round`, `subject` and `run_tag`; a header missing one of those makes the
questions that need it unanswerable, which is said rather than guessed around.

**`round`, `subject` and `run_tag` arrived late and most rows predate them**
(ADR 0041).
A row without them is not a round-1 row and not a ticketless run — it is a row
written before anyone recorded which round it came from. The two questions below
that need `round` are answered over the rows that carry it, with the count of
rows they had to leave out stated beside the answer.

**`summary` is what a finding claimed, never why it died.** Under eighty
characters there is no room for the refuter's ground, so the question below
about a recurring assumption reads only the beliefs the claim itself names, and
the ones a summary leaves implicit are invisible to it. Say so when answering
that question: an assumption you could not see is not an assumption that was not
there.

**Where a row carries `report`, the ground may still be on disk.** That column
holds the path the run wrote its report to, and its `## Refuted` section gives a
paragraph per kill — the id joins them. Reports are **overwritten by the next
run of the same ticket or ADR**, so this reaches the current report for each and
nothing older: it is a pointer, never a history, and most rows will point at a
file that has moved on. A loop's rounds are the exception since ADR 0041 — each
keeps its own `-r<n>` file, so a run's rounds resolve together or not at all,
and a whole run's grounds are readable where any of it is. Read the ones that answer, count them, and say how many
of the refuted findings you could reach that way against how many there are. A
path that no longer resolves is a miss and never an error, and a row with no
`report` column at all predates it.

`lens` is the lens that raised it, or several joined by `+` where the merge
folded them together. It is a **closed vocabulary** — a section name from
`dror-code-review/LENSES.md` or from `dror-adr-review/LENSES.md`, or the reserved
`criterion` or `tool` — so a name outside that set is a
defective row from an older run, not a lens to report on: count it out, and say
how many rows were dropped and under what names.

A `tool` row (ADR 0045) faced no refuter — its verdict is `survived` by
construction — so it is counted out of every precision rate, and a refuted
`tool` row is a defective row, not a signal.

The two pools answer different questions and their rates are **not comparable**
(ADR 0020): a code lens's finding is about a diff, an ADR lens's is about a
sentence, and a document's `hole` is refuted on grounds no code finding faces.
Report them apart, and never rank a lens of one against a lens of the other.

**Inside the ADR pool the same split runs again, along its five axes** (ADR
0033). Only `claims`, `breach` and `outcome` are judged against the code; the
rest are judged against the document itself, against other documents, against
the ticket set, or against the reader. Those refute on grounds that have nothing
to do with each other, so ranking `coherence` against `claims` measures the axis
and not the lens. Group the ADR pool by axis before comparing anything within
it, and say which axis a rate belongs to whenever you print one. The log written before this rule
carries five rows under `spec`. `verdict` is `survived`, `refuted` or `unverified`. Every
merged finding faces a refuter, so the only line here that never faced one is a
`tool` row. `claim` says
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
clean every time. Say which, rather than reading a silence. It also carries
`round` and `elapsed_s`, which is where the cost question below reads what a
review run is worth in wall-clock.

`~/.claude/dror-skills/repairs.tsv` — one line per finding a repair handled, keyed by
the report's id, carrying that run's outcome word. **Join on the whole string and
never on its parts** — the store reference's rule
(`../dror-internal-shared/REPORT-STORE.md`, "The finding id"), stated there once
with the shapes that make splitting wrong. A **survivor** whose outcome is
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

Seven questions, in this order. Each is answered from the log, with the counts
that support it.

**Which lens is imprecise.** Refuted over total, per lens. A lens is not
imprecise because it has many kills — the busiest lens has the most of both.
Only the *share* is the signal, and only against the others: a lens killing at
twice the rate of its neighbours is the one whose section is too loose. Report
the rates side by side so the reader can see the baseline.

**Split the rate by `kind` before ranking any lens on it.** A lens's rate pools
bugs, hazards and gaps in cover, and those die at very different rates, so a
lens that raises mostly hazards reads as loose when what is loose is the kind.
Report refuted-over-total per kind first, then the per-lens rates *within* the
kind that dominates — on one measured log the per-lens spread collapsed to a
single band once hazards were set aside, which is a different answer entirely
from the one the pooled rates gave. A lens ranked on a pooled rate is ranked on
its mix.

**One standing trial to report on.** `dror-code-review/LENSES.md` requires a hazard to
name the live caller that reaches it, a gate added on this log's evidence and
explicitly unproven: it buys precision with recall, and no file here records
recall. So each run of this skill says what became of hazards since — the count
raised, the count that survived, and the survivors' rate — and states plainly
whether the survivors fell with the kills. A gate that cut both is a gate to
argue for removing, and saying so is this skill's job, not a later reader's.

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
`files_edited`. Group a run's rows by `run_tag` and order them by `round`; for
each round after the first, sort its findings into three by `path`:

**Bucket one** — a file the previous round's review already named. The round is
returning to known ground. **Bucket two** — a file the previous round's *repair*
edited, from that round's `files_edited`. This is new code, written after the
previous review looked, and finding a defect there is the round doing exactly
what another round is for. **Bucket three** — neither. The previous round's
review had that file in its diff, never named it, and no repair touched it. That
is a miss the earlier round could have caught.

Report the three as counts per round index, never as a rate against anything
else, and say what they rest on.

**This is the question that decides what the round-1 floor is.**
`dror-code-review-repair` takes round 2 unconditionally where round 1 repaired
anything, and its grounds are two runs whose round-2 findings landed in files
round 1 never opened — bucket three. If bucket three dominates across many
tickets, the floor is compensating for a review that does not cover its diff,
and the answer is in `dror-code-review`'s lens fan-out — each lens given the whole
diff, none accountable for any particular file, and a cap (that file's, under
"Run the lenses") keeping a wider diff from adding any. If bucket two dominates,
the floor is convergence exactly as it says, and narrowing anything would spend
real recall. ADR 0041 exists because neither could be told from the other, so say
which the counts support and how thin the evidence is — the two runs the floor
cites are two.

It is **one-directional**: it counts misses that a later round happened to
catch, and can never see a miss nobody caught, so a small bucket three is not
evidence of good recall. It needs `round` and `run_tag` on both rounds' rows and
`files_edited` on the repair's, and it is unreadable where two concurrent runs
were pooled into one apparent sequence — ADR 0024's `concurrent` column is what
says which runs those were, and **`unchecked` there is missing, not empty**, the
word a review that runs no neighbour check of its own writes (ADR 0027). Where
any of those is absent, say the question cannot be answered for those rows
rather than approximating the repair's reach from the previous round's findings,
which overstates it and would fold bucket three into bucket two — the one
confusion this question exists to prevent.

**What a round costs.** From `runs.tsv`'s `elapsed_s`, the mean seconds a review
run takes, split by round index and by how many lenses it ran. This is the other
half of every argument about whether a loop's later rounds are worth taking:
until this column existed the only thing on record was the round *count*, and
the one drain that measured both showed the count does not predict duration.

Report it beside the buckets above and never instead of them. A round that is
cheap and finds bucket-three defects is a round to keep whatever it costs; an
expensive round that finds only bucket one is the case for a lower cap. Rows
with `-` took no reading and are excluded from the mean rather than counted as
zero, and the count excluded is stated.

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
Four things can be the target, and the question decides which:

- A lens raising false positives is a section of that lens's own `LENSES.md` —
  name the sentence or bullet. **Which file that is follows from the lens's
  pool**, the same disjoint naming that kept the two apart in every count above:
  a code lens is `dror-code-review/LENSES.md`, an ADR lens is
  `dror-adr-review/LENSES.md`. A proposal aimed at the wrong pool's file edits a
  lens that never raised the finding.
- Refuters killing real bugs, or letting weak findings through, is that pool's
  `REFUTING.md` — `dror-code-review/REFUTING.md` or `dror-adr-review/REFUTING.md`,
  chosen the same way.
- A file that keeps needing claims is neither: the change belongs in **that
  project's code**, as a comment, and no skill edit will help. This one is a
  code-pool answer only; an ADR review writes no claim comments.
- **The round questions target neither a lens nor a refuter.** A bucket-three
  answer is about how `dror-code-review` distributes its diff across lenses — its
  "Run the lenses" section and the cap that keeps a wider diff from adding any —
  and a bucket-two-plus-cost answer is about `dror-code-review-repair`'s round-1 floor
  and its cap. Name the file and quote the sentence as for any other target. This
  is the one proposal here that changes how much gets reviewed rather than how a
  finding is worded, so it is also the one where **the recall sentence below is
  not a formality**: a cap lowered on cost alone spends exactly the recall the
  bucket counts were measuring.

**Name these by their path relative to this skill's own directory** —
`../dror-code-review/LENSES.md` — and open them there to quote from. An absolute
path under the author's checkout is wrong for every installed copy, and the
quotation this section requires is a read that then fails.

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
