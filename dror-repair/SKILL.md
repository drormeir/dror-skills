---
name: dror-repair
description: Fix bugs already found, each one red before the fix and green after, and close named gaps in test cover. Use when asked to fix review findings, bugs this conversation named, or missing tests it named.
---

# dror-repair

Fix every bug this conversation has already named, and pin each one with a test.
Runs start to finish without stopping.

**Every bug found is on the list.** The default is the whole report, or
everything the conversation named. The user subtracts from it — "skip 4",
"leave the latent hazards" — and may add a bug of their own; naming a few is not
a way of choosing only those. Work that list and only that list; discovering
further bugs is someone else's run.

**A gap in cover is on that list too**, and it is the one item that is not a
bug: the code is sound and nothing is fixed, so what it needs is the test alone.
It is here rather than in its own skill because the work is the work of step 1 —
find the seam, write the test the way this project writes tests, prove it can
fail — and because a review that named a gap has nowhere else to send it. Its
route through the three steps is different at every step, and each one says how.

**Start from the written report if there is one.** It holds the last review's
findings with their `file:line` and failure scenarios. Read it and work from it.

**Which file it is, and whether it is yours, the store reference answers.**
`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill — holds
the naming, identity, staleness, finding-id and log rules every `dror-*` report
obeys, in one copy. Read it whole before working from a file. It is not restated
here.

Its `## Refuted` section is **not** the list. Those findings were raised and
then disproved, and they are kept only as evidence about the review itself.
Fixing one is changing working code to satisfy a mistake — the user has to name
it explicitly before it counts as a bug.

This skill is **repo-agnostic**: it names no tracker, no path and no runner of
its own. Everything about the project in hand arrives through the facts below.

## How a test is written

`../dror-internal-shared/WRITING-TESTS.md` — the shelf beside this skill — holds the rules
every `dror-*` skill writes tests by, in one copy: the **red** / **green** / **red by
mutation** / **unproven** / **untestable** vocabulary, the three rules every
test obeys, the three routes for where a test goes, how a test is proved to bite
when the code already works, and how expensive setup is shared. Read it whole
before step 1, and pass it to every agent that writes a test. It is not restated
here.

Two words are this skill's own:

- **covered** — a bug that went red and then green.
- **cover** — a gap in test cover: named behaviour that no test would catch the
  loss of. Nothing is broken, so nothing is fixed and no test can go red against
  the tree as it stands. It is closed by the reference's mutation route, which
  `dror-prove` runs for the same reason on a criterion whose code already works —
  one machine, two kinds of input.

## The ticket, when there is one

A ticket number may be passed to this run. If one is, read it the way the
**issue convention** fact says this repo tracks work, and number its acceptance
criteria 1..N, the same numbering `dror-prove` and `dror-review` use. A repo whose
convention came back unstated carries on without the ticket and says so; it is
focus, not scope, so nothing on the list depends on it.

It is **focus, not scope**: the list to repair is still the review's findings,
and a criterion nobody implemented is not a bug this run invents. What it buys
is two things — a cover item that matches a criterion is named by its number, so
the ticket and the repair can be read together, and a fix that would break a
criterion is caught while it is being written rather than at review.

**A box may be unticked, never ticked.** A criterion whose test this run saw go
**red** has its `- [x]` cleared, because the tree contradicts it. Ticking stays
with `dror-prove`, which holds the criterion-to-test mapping. Say which boxes
moved.

## Learn the project first

Invoke the `dror-internal-project-facts` skill. The verification commands, the test layout
and the declared scope are the ones that matter here: write the new tests the way this project
writes tests, and verify with the commands it actually uses.

That skill is a **step of this one**, not a hand-off: the moment the facts are
in hand, continue at **Step 1 — Red** in the same turn.

## Step 1 — Red

First decide whether a test can catch the bug at all. A wrong comment, a stale
document, a defect that only appears in real GUI timing — these are
**untestable**: record the reason, and carry them to step 2 with everything
else. Every other bug gets a test.

For a bug a test can catch, place the test by the reference's three routes —
enrich an existing test, enrich a test added in the work under review, or create
one file covering several bugs. Run that test alone and paste its failing
assertion, with the run's summary line.

A test that goes green before any fix means the bug was never real. Leave that
code alone, report the bug as not reproduced with the passing run quoted, and
keep the test.

**A cover item takes the same three routes and a different proof.** Its test is
written into this repo exactly as a bug's is, and it passes here — that is what
"the code is sound" means, and a green run in the tree is the wrong evidence,
because a test that asserts nothing passes too. So it is made **red by
mutation**, by the reference's route, with the finding's own failure scenario as
the mutation: a review that said "delete this line and the suite stays green" has
already named the edit, so make *that* edit. A scenario no copy can stage is
recorded as **unproven**.

Done when every bug on the list is red, untestable, or reported as not
reproduced — and every cover item red by mutation or unproven — with the output
or the reason on screen for each.

### Fan out, one agent per test file

This step is the one that parallelizes, because writing a failing test touches
test files and scratchpad copies and nothing else. **Group the list by the test
file each item's test will land in** — route 1 and route 2 name an existing
file, route 3 chooses one, and the skill already prefers one new file over
several — then spawn one subagent per group and let the groups run at once. Two
items that will edit one file are one group and one agent; grouping by file
rather than by item is what keeps two agents from writing the same file at once,
which no lock and no retry recovers from.

Each agent is told: the finding with its `file:line` and failure scenario, the
project facts already in hand (test layout, the command that runs one test), the
file it owns, and `dror-internal-shared/WRITING-TESTS.md` verbatim. It **writes tests
only**. A subagent
that edits production code has performed step 2 unobserved, out of order and
without the call-site check, so the fix step below would be repairing a tree it
no longer recognises; a cover item's mutation is made in that agent's **own**
scratchpad copy, never in the working tree, for the same reason the serial route
says so.

Each agent returns, per item: the test's name, the failing assertion and the
run's summary line — or `not reproduced` with the passing run, or `untestable`
with the reason, or `unproven` with what could not be staged. That output is
pasted here as if the run had been serial; an agent that returns a verdict with
no run behind it is an agent that believed a test would fail, which is the one
thing this skill does not accept.

A list of one item, or a list whose items all land in one file, is one group and
so runs serially on its own — no decision needed.

## Step 2 — Fix

Fix everything on the list, the untestable items included: typos, wrong
comments, stale documents.

**This step is serial and stays in this context**, and that is a decision rather
than an omission. The fixes land in one working tree with no worktree between
them, and unlike the tests they are not separable by file: two findings meeting
in a shared helper is the ordinary case, and the rule below — list the call
sites and group them before editing that helper — is a judgement about the whole
list that an agent holding one finding cannot make. So is reading a failure a
fix introduced. Step 3's suite, lint and type-check are one run over the whole
tree, and the report is one file; both are written here too.

**A cover item is fixed by nothing**, and that is the rule rather than an
omission: its finding says the code is sound, so an edit to production code here
is this run inventing a defect nobody found. The one exception is the wording a
gap often comes wrapped in — a comment or test docstring that describes a setup
or a guarantee the code does not have. That is a stale claim, it is repaired
like any other, and it is named in the report.

- Each fix lands in the production code path its finding names. A test, demo
  block or debug script is a different path.
- Before editing a shared helper, list its call sites and group them by whether
  they need the change.
- Update any comment, docstring or document the fix makes untrue. A stale claim
  about the code is part of the defect.
- **An existing test that now fails because it asserted the buggy behaviour**
  gets updated to expect the correct behaviour, and takes a row of its own in
  the report (`Test updated`) saying what it used to assert. Every such edit is
  visible in the report.

Done when every bug on the list has an edit behind it.

## Step 3 — Green

Run the touched tests while working. At the end run the project's full suite in
its quiet form, then its lint and type-check. **The suite is owed to the last
code change, not to this step**: a green full suite already seen *after* the
last edit this run made — a caller's own, or one from earlier in this run —
is that run, and repeating it proves nothing. Lint and type-check are cheap and
run regardless. Paste each command's summary
output — and for anything that fails, the failing assertion or diagnostic in
full.

**A failure a fix introduced is part of this run.** Read it: either the fix is
wrong and gets corrected, or the old test asserted the buggy behaviour, which is
the update-and-flag case from step 2. Re-run after each correction. The run does
not end on a red suite.

**A third reading exists wherever this tree is shared, and it is the one to rule
out first.** A working tree is not this run's alone — another session's review,
repair or implementation edits the same files — so a failure in code no finding
named and no fix touched may be **somebody else's edit**, arriving mid-run. The
tell is cheap: `git status --porcelain` a second time and compare it with what
the run started from, and read the failing test's own subject against your list.
Where the caller said a concurrent run was seen, take that as the likely answer
rather than the last. Do **not** repair it — fixing another run's in-flight code
under this run's name is the mistake, and it lands in the tree where nothing
attributes it. Name it in the report as `pre-existing failure`, say whose it
probably is, and leave it. A suite red only for that reason ends the run with the
red named, not chased.

Done when those commands are green in that output, and every covered bug has
its passing summary line on screen — a cover item's new test among them, since a
test that passes only in a mutated copy is the opposite of what was asked for.
Pre-existing failures the project declares out of scope are named as such.

Then mark the report — **the file this run read**, never the store's default
name where they differ. Add to every
finding this run handled a line saying it was repaired, carrying the two answers
below — what was found, and the repair's outcome — plus the test that holds it,
and leave the rest of the file as it stands. A
later run reads those marks and skips what is already done. Only when no report
file was involved at all is there nothing to mark — a run that subtracted from
or added to the report's list still marks every report finding it handled.

## Say what became of each finding

A review scores a finding as *survived* the moment a refuter fails to kill it,
and nothing ever revisits that. But this run is where a survivor meets the
tree: one turns out not to be reproducible, another is examined and ruled out.
Those are the review's false positives, and until they are written down
somewhere a later run can read, every one of them stays on the record as a
success.

So for every finding that carried an **id** in the report, append one line to
`~/.claude/dror-skills/repairs.tsv`, on the store reference's terms for every log:
create it with its header where it is absent, append only, never block the run.

The columns and their order are the store reference's (`REPORT-STORE.md`, "The
logs"), stated there once, including the rule that the same `files_edited` and
`production` go on every row this run appends. This run's own values: `outcome`
is the word from this run's report — `Fixed (red→green)`, `Couldn't reproduce`,
`Ruled out`, … — and `production` is answered yes or no, since this skill edits
production code.

**`files_edited` and `production` are the same answer this run already gives its caller** — the
files it edited and whether any is production code — written down instead of
spoken once. They are what lets a later reading ask the question no other column
can: a finding raised in a file the *previous* round's repair never touched is
one the previous round's review had in scope and did not return. That is the
only recall proxy these logs can carry, and it is unavailable retrospectively —
the run that edited the files is the only one that knows which they were.

The reference's rule that those two carry the **same** list on every row this run
appends — a `Ruled out` and a `Couldn't reproduce` included — has a reason that
is this skill's own: step 2 is deliberately serial and a shared helper is edited
for several findings at once, so a per-finding attribution would claim a
precision this skill does not have.

**Copy the id whole, exactly as the report spells it**, by the store reference's
rule.

A report whose findings carry no id — an older one, or one this skill was not
given — records nothing here, and that is not a failure: the join has no key,
and a line keyed on a guess is worse than an absent one.

Nothing is committed — committing is the user's. Two things are still owed
before the run ends: the report below, and the review-owed line after it.

## Report

Two things per item, answered separately, because what the review put on the
list and what this run did about it are different facts — a defect can be
corrected with no test, and a test can exist for something that turned out not
to be a defect at all.

They divide along one line: **the finding is a neutral observation, the outcome
carries the verdict.** "A test is red" does not say which side is wrong — the
test can be the broken one — and that diagnosis is the repair's work, not the
review's. So the finding never names the evidence behind it either: "a test
failed" and "reproduced by hand" are the same finding, and a column that
separates them reads as a claim about what was already in the tree.

- **What was found** — the *kind of thing* the review named, in a word. An open
  vocabulary; the usual ones:
  - `bug` — production code is wrong.
  - `failing test` — a test that was green is red now. Which side is wrong is
    undecided here; the outcome says.
  - `wrong test` — a **green** test that asserts the wrong thing: it proves
    nothing, or it pins the buggy behaviour in place. A suite run cannot see
    this one.
  - `gap` — the code is sound and named behaviour has no cover. The note names
    the mutation the new test was made red against.
  - `text` — a wrong comment, a stale docstring, a document describing
    behaviour that moved.
  - `timing` — a defect only real GUI or thread timing shows.
  - `pre-existing failure` — red before the work under review, so not this
    diff's.
- **Repair's outcome** — what this run did. Also open; the usual ones:
  - `Fixed (red→green)` — the whole cycle, and the strong claim: the test was
    seen red, the edit landed in the production path, the test was seen green.
  - `Fixed (no test)` — the edit landed, and no reasonable test can hold it
    (timing, real GUI). Deliberately the weaker claim; never write it where a
    test was possible and skipped.
  - `Test fixed` — the **test** was the wrong one. It was corrected and the
    production code left alone.
  - `Test updated` — the test asserted the buggy behaviour and was rewritten
    alongside the fix. It gets its own row, not just the note below the rows.
  - `Corrected` — a text edit landed, where no test could have caught it.
  - `Test added` — the code was already right; the test is the whole
    deliverable, proven red by mutation.
  - `Couldn't reproduce` — the test written for it passed before any fix. The
    test is kept and the code left alone.
  - `Duplicate of N` — it and item N are one defect; N carries the repair.
  - `Ruled out` — examined and found not to be a defect; nothing changed.
  - `Out of scope` — real, and in an area the **project** rules out (a retired
    directory, vendored code). Not the same as `Deferred`.
  - `Deferred` — real, and left unfixed on the **user's** instruction.

Never pair a finding with an outcome that contradicts it:

- `gap` ends in `Test added`, never in a `Fixed` — that would claim a defect
  nobody found.
- `failing test` ends in `Fixed (red→green)` or `Test fixed`, never in
  `Corrected` — something in the tree is wrong, and the row must say which side.
- `wrong test` ends in `Test updated` or `Test fixed`, never in a `Fixed` — the
  production path was not the thing at fault.

Run `printenv CLAUDE_CODE_ENTRYPOINT`. If it is `claude-vscode`, report one row
per item: **Item | File | Test | What was found | Repair's outcome | Note**.
`Test` names the test, or `—` when there is none. `Note` is empty unless the
pair leaves a reader guessing, and then it says in a few words what is missing
— the mutation used, "no test can catch a comment", "passed before the fix".

Otherwise report the same rows as one line each, in the same order, reading
`<item> — test: <name or none> — found: <kind> — outcome: <outcome> — <note>`.

Below the rows: the final verification output. A test that was updated is a
`Test updated` row above, not a footnote — but its `Note` carries what it used
to assert, which is the part a reader cannot reconstruct.

## Say whether another review is owed

The last line of the run, and the one a **looping caller** reads: does the tree
this run leaves behind need reviewing again? Answer in a word with the grounds in
half a sentence, and name the files.

- **yes** — production code was edited, so there is now code no review has seen.
  Strongest where an edit landed in a file the findings never named: a fix that
  reached beyond its finding is the case a further pass exists for.
- **tests alone** — the edits were tests and nothing else. A test changes
  nothing a review reads for defects, so a pass over *them* buys nothing. It is
  a statement about this run's edits and **not** about whether the review before
  it saw the whole diff, so it is never `no`: one review pass does not cover a
  diff, and a caller that stopped on this word after its first round has been
  measured losing most of its findings (ADR 0023).
- **no** — nothing was edited at all. A run that changed no file leaves nothing
  for a further pass to read that the last one did not.
- **the user's call** — production code moved, but only in the narrow way each
  finding described, and the run has nothing further to suggest.

It is a **report, not a decision**: this skill neither reviews nor loops, and
whether the next round is worth its cost belongs to whoever called. Answer it
even when nobody asked — a caller that does not want it ignores one line, while a
caller that needed it and did not get it has to ask again for what this run
already knew.

Name the files plainly, since that is the part a caller cannot re-derive without
a diff, and keep the whole thing to two lines. The run ends here, with the
changes uncommitted.
