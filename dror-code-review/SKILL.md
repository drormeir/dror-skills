---
name: dror-code-review
description: Correctness review of the unpushed work - commits not yet on the remote plus the working tree - every finding tool-proven or refuted before it reaches you. Reports the survivors and changes no behaviour. Use when the user asks what is wrong with the work before pushing it, or wants findings without the fixing.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-code-review

This skill **finds**. It produces a bug report and STOPS, changing no behaviour:
the only source it writes is a comment where a refutation proved one was
missing.

**This run has a context of its own.** The frontmatter forks it (ADR 0036):
what reaches it is this file, the facts the line below injects, and the
arguments it was invoked with — never the conversation that invoked it. A
ticket number, a scope, a focus paragraph, a report name or a directory
override arrives as an
argument or not at all, and what goes back to the caller is the closing summary.

It is **repo-agnostic**: it names no tracker and no path of its own, and
everything about the project in hand arrives through the facts below. It does
assume **git** — "unpushed" is a git question and the whole scope is found with
git commands — which is the one thing it cannot take from the facts.

**A directory override may arrive as an argument** — the sentence "All
commands run in `<path>` …". Its provenance and the duties it obliges —
`<repo>` and the store, the void facts block and its stamp-script re-run
under `<path>`, the sentence at the top of every spawned agent's prompt, and
the no-override default — are the shelf's, in one copy:
`../dror-internal-shared/DIRECTORY-OVERRIDE.md`, read whole when the sentence
arrives. This skill's own part of the contract: every git command in this
file runs with `-C <path>`, and "every agent this run spawns" means lens and
refuter alike.

## The project facts

!`bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh`

The block above is the store's `facts.md`, printed by
`dror-internal-project-facts/facts.sh` before this text reached you, when its
stamp matched the tree (ADR 0037). The `domain` lens reviews against its
vocabulary and invariants, and its declared scope marks which findings are
noise. A block that begins `MISS:` means the store could not answer: invoke the
`dror-internal-project-facts` skill — it gathers in a subagent, rewrites the
store and returns the five facts — and hold what it returns as the facts from
then on. That skill is a **step of this one**, not a hand-off;
`../dror-internal-shared/DELEGATION.md` owns what that means, at authoring time.
Either way, the moment the facts are in hand, **fetch the ticket where a number
was passed, and otherwise list `<repo>/.claude/dror-skills/` for the concurrency
check, in the same turn** — the sections below, in their order, from there.

## The ticket, when there is one

A ticket number may be passed to this run. If one is, read it the way the
**issue convention** fact says this repo tracks work, and number its acceptance
criteria 1..N, the same numbering `dror-prove` and `dror-code-repair` use. A repo whose
convention came back unstated reviews without the ticket and says so. Carry that list into
every lens prompt beside the facts path: it is what the diff was written to
satisfy, and a lens that knows it stops reporting a deliberate choice as a
defect.

It is **focus, not scope**. The diff is still the whole scope, and a criterion
the diff does not touch is not this run's business. A criterion the diff
*claims* and misses is a finding of its own kind — `unmet criterion`, carrying
the criterion's number — which sorts with the latent hazards: it is neither a
bug in what was written nor a gap in cover.

**Nothing is written to the tracker here — no box, and no comment.** Ticking
belongs to `dror-prove`, which holds the criterion-to-test mapping, and unticking
to `dror-code-repair`, which watches a test go red. This run's per-criterion verdicts
— one line per criterion, `met` / `unmet` / `not touched by this diff` — go in
the **report**, in a section of their own, so the report carries the judgement
and the boxes carry the evidence. The ticket is read and never written.

## The scope, when the caller narrows it

**The default scope is every unpushed file**, and it is what a run given nothing
reviews. A caller may narrow it instead, in plain text: paths or globs, a
directory, named functions or classes, a `file:line` range, or a sentence
describing the area. Take it literally and review that and nothing else.

Narrowing is done **after** the diff is captured, never instead of capturing it:
find the base and take the whole unpushed diff as always, then keep the hunks the
scope names and drop the rest, and list the kept paths as the changed-paths list
every agent below is given. The base is still the base — a narrowed run reviews
part of the unpushed work, not a different range of history.

Say on screen what was narrowed to and **what that left out** — how many changed
files went unreviewed. A reader cannot otherwise tell a clean area from one
nobody looked at, and this is the same reason the report names the lenses that
were dropped.

A scope naming something the diff does not contain is worth one sentence and no
findings: say the diff does not touch it rather than widening to find something
to report. An **empty** result after narrowing ends the run exactly as an empty
diff does.

The narrowing is the caller's to get right, and it is what lets two runs share a
checkout without reviewing each other's work — disjoint scopes, one report path
each.

## Who else is in this checkout

This run reviews a working tree, and a working tree is shared. Another session's
review, repair or implementation edits the same files, and its edits arrive in
this run's diff indistinguishable from the work you were asked about. It is not
hypothetical — ADR 0025 records the run where it happened.

**Look before reviewing, and use what is already on disk.** List
`<repo>/.claude/dror-skills/` for `review-report*.md`, and for each one that is
not the name this run will take, read its front matter — the ticket, the base,
the `HEAD` and the time. A report there written **recently** under another name
is another run in this tree — unless its front matter carries **the tag this
run's caller gave**, in which case it is an earlier round of the caller's own
loop (its reports are one per round, `-r<n>`): this run's own history, not a
neighbour, and it goes unreported and out of `concurrent`.

It is a **heuristic and it is reported, never enforced.** A run between its start
and its first report write is invisible to this check, and a finished run's
report is indistinguishable from a live one, so a neighbour found is a fact to
say out loud and a neighbour not found proves nothing. Say what you found in one
line on screen and record it in the report's front matter — `Concurrent: <tag or
name>, <its time>` — or `Concurrent: none seen`, which is the honest wording for
a check that cannot see everything.

**Nothing here narrows the scope on its own, and nothing here stops.** Deciding
that two runs should take disjoint scopes is the *caller's*, and the scope
argument above is how it is expressed; a review that quietly reviewed less
because it guessed at a neighbour would leave changed files unlooked-at with
nobody told. What this section buys is that the user, reading a finding against a
file they did not touch this session, can tell the two readings apart.

**Mint a run tag** by the store's recipe — unless the caller gave one, in which
case that is the tag. It does **not** change the report's name, which ADR 0021
derives from the ticket; it identifies the *run* in the front matter and in the
run log below, so a later reading can tell which rows came from runs that
overlapped and pool them apart from the ones that did not.

## Review

**Find the base.** The default scope is everything not yet on the remote: the commits
this branch is ahead by, plus staged and unstaged work, plus untracked source
files. Committing is not a way of leaving the review, so the base is the
upstream branch, not `HEAD`.

Ask `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}`. A branch with
an upstream reviews from `git merge-base @{upstream} HEAD` — the merge base, not
the upstream tip, so someone else's commits pulled in on that branch are not
this run's work. A branch with **no** upstream still has commits not on the
remote, so try the remote's default branch next: `git merge-base origin/HEAD
HEAD`, and where `origin/HEAD` is unset (many clones never ran `git remote
set-head`) `origin/main` or `origin/master`. Only a repo with no usable remote
ref at all falls back to `HEAD`, which is the working tree alone. Say which of
the three bases was used, because they answer different questions and the user
should not have to guess which they got.

**Capture the diff once.** Write `git diff -W <base>` plus every untracked
source file to a single scratch file, and list the changed paths. `-W` extends
each hunk to its whole enclosing function, so the context every lens is told to
read around a hunk is paid for once here instead of fetched again per lens —
and the refuter slices, cut from this same capture, carry it for free. Where the caller
narrowed the scope, apply that narrowing here — keep the named hunks in the
scratch file, and let the changed-paths list carry only what was kept. Every
agent below reads that path. The diff is the review scope; pre-existing code
enters only where the diff touches it.

**Leave every hunk in.** Claim comments written by earlier runs' refuters
arrive inside ordinary hunks — this run's refuters write theirs after this
capture, so nothing here calls for re-capturing the diff. The claims stay: a
lens verifies a claim rather than reporting it, which is what stops a run
reading a prior run's conclusions back as fresh evidence.

An empty diff ends the run: report that there is nothing unpushed to review,
write no report, and stop. Reviewing something the user did not ask for is
worse than reviewing nothing.

**Run the project's own tools before any lens** (ADR 0045). The facts'
verification commands name the lint and type-check this repo already trusts;
run those two over the changed files — not the test suite, which is the
repair's evidence and a load a shared machine pays for. A diagnostic on a line
this diff added or changed is a **finding that skips the refuter**: the tool's
pasted output is its own proof (ADR 0006) and is the finding's failure
scenario. A diagnostic elsewhere in a changed file predates the diff — name it
in one line as pre-existing and raise no finding. Write the diagnostics that
counted to one file in the scratch directory; its path goes to every lens
below, which is told not to re-report what it holds. These findings enter the
report as confirmed bugs under the reserved lens name `tool`, and the pass is
not a lens: it appears in neither `lenses_run` nor `lenses_dropped`. A facts
block whose verification commands are unstated skips the pass, and the report
says so.

**Cut the caller boundary once, by command.** Every lens is capped at the
changed files plus their direct callers, and a lens made to find those callers
itself does the same search once per lens, on the cheap model. So before the
fan-out, for each changed file, search the repo for the file's stem and for the
top-level names its hunks touch —

```
grep -rn --exclude-dir=.git -e '<stem>' -e '<name>' <repo> \
  >> <scratch dir>/callers.txt
```

— excluding whatever else the facts' declared scope rules out. Remove a
`callers.txt` already sitting there first: a loop's rounds share the scratch
directory, and the append would otherwise stack a stale round under this one.
The matches go straight to the file and never through this context. Every lens is given its
path and reads its boundary from it instead of searching. It is a cache and it
is best-effort: a caller it misses may still be read when a hunk plainly points
there, and a lens says when it did.

**Run the lenses.** [`LENSES.md`](LENSES.md) is a **pool**, not a running order.
Choose from it the ones this diff raises and run each as one agent, all launched
in parallel, each given the scratch path, the changed-paths list, the path of
the store's `facts.md`, the paths of the tool-findings file and the callers file
from the two steps above, and the path of `LENSES.md` with the name of its lens —
it reads that file itself, and is told that the preamble and the section headed
with its name bind it while the other sections are other agents'.

**Point, never paste** (ADR 0038). Text this run writes into a prompt is output
tokens, and then sits in this context for the rest of the run, once per agent;
a path costs one read in an agent that is gone when it returns. So every agent
below is given paths — the facts, the lens file, the refuting file, its slice of
the diff — and never their contents. What is written into a prompt is only what
exists nowhere else: the finding, the criteria list, the lens's name.

Choosing is this skill's job, not the user's. Skip a lens whose concerns the
diff never raises — no cache, lifecycle or persisted data in the diff, no
`state` agent; no new variant of an existing pattern, no `clone`; a diff that
changes no behaviour, no `tests`. Where `clone` runs, keep `collateral` too: the
documents a new variant leaves behind are `collateral`'s bullet, and `clone` is
told to report missed sites in code only. **Five at most**, whatever the diff's size — a
wider diff makes each lens dig deeper, not multiply. Where more than five
qualify, keep the ones whose concerns this diff most obviously raises and say in
the report which were dropped, so a reader knows what was not looked at.

**Lenses run on the cheap model, refuters on the strong one.** Pass
`model: "sonnet"` to every lens agent and leave the refuters on the session's
own. Spend the tokens where the judgement is: a weak lens proposal costs one
refuter, a wrong refuter decision ships a false positive or buries a real bug.

**Cap what a lens reads.** The changed files, and the direct callers of what the
diff touches. A lens that cannot reach a verdict inside that boundary says so
and returns the question rather than widening — reading a subsystem to settle
one finding is the refuter's budget to spend, on one finding, not every lens's
on all of them.

**Merge.** Two lenses looking at adjacent concerns report one defect twice.
Group the returned findings by `file:line` and failure scenario before anything
is refuted: findings that name the same defect become one, keeping the clearest
statement of the scenario and noting every lens that raised it. One defect, one
finding, whatever found it.

**Refute.** Hand each merged finding to one independent agent, all launched in
parallel — one refuter per finding, however many survived the merge, with **no
cap**. Each is given: its finding; the path of the store's `facts.md`; the path
of a **slice file** holding the diff hunks touching its finding's files — not
the whole diff, since a refuter judges one `file:line` against the live tree
and the full diff read once per refuter is the run's dominant token cost; the
changed-paths list, so it still knows the run's scope; and the scratch path,
named as a fallback to read only when its one finding genuinely needs the wider
diff — that is the refuter's budget to spend, on one finding. It is also given
the path of [`REFUTING.md`](REFUTING.md), told that its general sections — the
default-to-refuted opening, the prefer-a-run section, the claim section and the
return section — bind it,
and that the missing-test section binds only a `cover` finding (the `tests`
lens's kind); no other kind reads it.

**The slice is cut by a command, not by you.** For each finding, once per file
it names, append that file's hunks from the scratch capture to the finding's
slice:

```
awk -v f='<path as it appears after b/>' \
  '/^diff --git /{keep = ($0 ~ (" b/" f "$"))} keep' <scratch path> \
  >> <scratch dir>/slice-<finding number>.diff
```

The capture is the one the lenses read, so the slice is the same diff they
saw; and the hunks never pass through this context, which is the point.

Every suspect is checked: cutting the list here would put unchecked suspicions
in the report, which is the one thing this step exists to prevent, and a reader
cannot tell an unchecked finding from a confirmed one. The cost is controlled
before this point, not here — fewer lenses, a tighter read boundary, and lenses
that kill their own weak findings rather than passing them on.

Survivors are the report.

## Write the report down

`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill — holds
the naming, identity, finding-id and log rules every `dror-*` report obeys, in
one copy. Read it whole before writing anything, and take this run's path from
it. It is not restated here.

Number the survivors: confirmed bugs first in severity order — the damage the
failure scenario does, a crash or corrupted data above a cosmetic fault — latent
hazards below. Save them under the name the reference gives, overwriting the
previous one. It is the run's record, and later work in this repo reads it
instead of deriving the same findings again.

Front matter first: **the ticket this report is for** — `Ticket: <n>`, or
`Ticket: none` for a review of no ticket — then the base the diff was taken
against and how it was chosen
(upstream merge base, the remote default branch's merge base, or `HEAD` for a
repo with no usable remote ref), the commit
`HEAD` was at, the time this report was written (`date +%H%M`, the same call the
log's date comes from), **this run's tag**, **what the concurrency check saw**,
the changed paths reviewed, and — where the caller
narrowed the scope — that scope as it was given, with the count of changed files
it left out. Both commits are
recorded because
either one moving is what makes the line numbers stale — a repair run reads them
to say so.

Then, **where a ticket was named**, a `## Criteria` section: one line per
criterion, in the ticket's own 1..N order, reading `met` / `unmet` / `not touched
by this diff`. It is the whole record of this run's per-criterion judgement —
nothing is posted to the tracker — and it is why a reader can tell "the diff
satisfies this" from "the diff never reaches it", which the findings alone do not
say. A run given no ticket has no such section.

Then one section per finding, numbered as on screen, each with its **id**, its
`file:line`,
its failure scenario, and what kind it is: a confirmed bug, a latent hazard, or
a gap in cover — the `tests` lens's findings, which are neither, and which sort
below the hazards. A survivor a refuter could not verify says so on its line.
Also name the lenses that were **not** run, since a reader cannot tell an area
that came back clean from one nobody looked at. Take
every `file:line` from the tree as it stands now: the lenses read it before the
claims went in, and a claim inserted above a survivor has moved it. The project
facts stay in `facts.md`, where they already are.

**Every finding carries an id**, survivors and kills alike, minted by the
reference's rule from the front matter's commit, this run's tag, the report's own
time and the finding's number. Number the kills on from the survivors, in the
order `## Refuted` lists them, so every merged finding has one and the two
sections never mint the same id twice.

**A finding is about fifteen lines** (ADR 0017): the `file:line`, the failure
scenario, the kind, and the one or two sentences of reasoning that make the
scenario believable — and not the refuter's route, which a repair redoes against
the tree as it stands. One line of a route survives that rule (ADR 0046): where
the refuter's verdict came from an execution, the finding carries `repro:` and
the exact command, verbatim, for the repair to replay. A `tool` finding's
`repro:` is the tool command itself.

**Then record the kills.** A last section, `## Refuted`, holding every finding
that did *not* survive: its id, its `file:line`, the lens that raised it, what
it claimed in one sentence, and why the refuter killed it. Say for each whether
a claim comment was written, and where.

It is the run's only record of its own *precision*. Keep it terse — one short
paragraph per kill, no failure scenarios, since nothing downstream acts on
these.

## Append to the log

The report is overwritten every run, and one run's kills are too few to read
anything into. So every **merged finding**, survivor and kill alike — and every
`tool` finding, which reaches the report without passing through the merge — is
appended as one line to `~/.claude/dror-skills/refutations.tsv`, on the
reference's terms for every log: create it with its header where it is absent,
append only, never block the run.

Survivors go in as well as kills, because a lens's kill count says nothing on
its own: what matters is the *share* of its findings that died, and that needs
the denominator.

One tab-separated line per finding — the columns and their order are the store
reference's (`REPORT-STORE.md`, "The logs"), stated there once. This run's own
values: `kind` is `bug / hazard / cover`, `path` is the finding's repo-relative
file, `claim` records whether a claim comment was written, `yes` / `no`,
`subject` is the ticket number this run was given, or `-` where it was given
none, and `run_tag` is this run's tag — the caller's where one was given, the
minted one otherwise.

**`round` is the caller's to say and never this run's to guess.** A loop that
runs this skill several times over one diff names the round in its prompt, and
that number goes in the column unchanged; a run nobody numbered writes `-`.
Counting rounds from what is already in the log would be the guess — two loops
sharing a checkout interleave their rows, and the count would be of neither.

**Why the path is worth a column.** The log's `summary` holds what a finding
*claimed*; the `## Refuted` section above holds **why it died**, which is the one
thing a retrospective needs and cannot reconstruct — a measurement over
nineteen days could read the ground from about ten kills in a hundred and forty,
because a summary under eighty characters has no room for it. The report is
overwritten by the next run of the same thing, so this is not a history and does
not pretend to be one: it points at a file that is there until the next run on
that ticket, and gone after. That is still every run whose report is current,
which is where a retrospective's freshest evidence sits, and a dead path is a
miss and never an error.

**The `lens` column is a closed vocabulary**: a section name from `LENSES.md`,
the reserved `criterion` for an `unmet criterion` finding, which no lens
raises, or the reserved `tool` for a mechanical-pass finding (ADR 0045) — its
row writes `survived` for `verdict` and `no` for `claim`, since it faced no
refuter. Nothing else may be written there — a name outside that set is a bug in
this run, not a new lens, and it silently corrupts every rate
`dror-review-retrospective` computes. Where the merge joined several, join their names
with `+` from the same closed set.

## Record the run itself

A lens that ran and found nothing writes no line above, so the log alone cannot
tell an area that came back clean from one nobody looked at — and every rate
computed from it is missing its denominator. The report says which lenses were
dropped; that fact dies with the report unless it is written where later runs
can read it.

So append one line to `~/.claude/dror-skills/runs.tsv`, on the same terms as the
log above — the columns and their order are the store reference's
(`REPORT-STORE.md`, "The logs"), stated there once. A **separate file**,
deliberately: the refutation log's contract is one line per finding, and a
run-level row inside it would be counted as a finding by everything that reads
it.

This run's own values: `lenses_run` and `lenses_dropped` carry the closed names
from [`LENSES.md`](LENSES.md), `concurrent` carries the tags or names the
check above saw, joined by `+`, or **`-` for none seen** — never `unchecked`,
which is what a review that runs no check of its own writes there — and `round`
and `subject` are the same values the finding log's section above gives them.

**`elapsed_s` needs two readings, and the first one is easy to miss.** Run
`date +%s` immediately before launching the lenses and again as this line is
written, and put the difference in the column. Take the first reading at the
lenses rather than at the top of the run: everything before them is reading the
prompt, and what this column is for is the cost of the fan-out and the refuters
under it. A run that reached this point without the first reading writes `-`
and does not reconstruct one — a duration invented from a report's timestamp
would be a different quantity wearing this column's name.

**`run_tag` and `concurrent` are what make every rate in this file readable
later.**
Without them a run that shared its tree with another is pooled with one that had
it to itself, and the difference is invisible: the neighbour's edits were in this
run's diff, so its findings are partly about work this run was never asked to
judge. A row cannot be corrected after the fact — the only moment anyone knows
who else was here is now. Where a file predates them, they arrive on the
header line, as any added column does.

One line per review, whether it found anything or not — a run that produced no
findings is exactly the run the log cannot see, and the only one this file
exists to record.

## Present

Show that same numbered list, in that order. Below it, **name the report file
this run wrote**, since a repair run has to be pointed at it and only this run
knows which name it took. Then name each file a claim was written into and what
it records — the working tree moved, so say so rather than leave it to be found
in a diff.

Then **one line saying whether a repair should follow**, and why in half a
sentence. It is a judgement the count cannot make: a confirmed crash and a hazard
noted for a later reader are one survivor each, and only this run has met them.
Three answers — *yes*, naming what most needs the edit; *no*, where every
survivor is something to know rather than something to change; *the user's call*,
where the fix is a decision rather than a correction. It binds nobody; a caller
that repairs anyway is entitled to, and a looping caller reads this line to
decide whether to spend a repair at all.

Then stop and wait.

Done when the tool pass has run or been skipped as unstated, every lens has
returned, the findings have been merged, every merged
finding has faced a refuter, the claims the refutations called for are written,
the repair-or-not line is on screen,
this run's report
file holds the survivors, the refuted and — where a ticket was named — the
per-criterion verdicts, every merged and every `tool` finding has a line in
`~/.claude/dror-skills/refutations.tsv`, the run has its line in
`~/.claude/dror-skills/runs.tsv`, and that same list is on screen — with no line
of code changed.
