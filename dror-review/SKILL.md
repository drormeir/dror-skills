---
name: dror-review
description: Correctness review of the unpushed work - commits not yet on the remote plus the working tree - every finding refuted before it reaches you. Reports the survivors and changes no behaviour.
---

# dror-review

This skill **finds**. It produces a bug report and STOPS, changing no behaviour:
the only source it writes is a comment where a refutation proved one was
missing.

It is **repo-agnostic**: it names no tracker and no path of its own, and
everything about the project in hand arrives through the facts below. It does
assume **git** — "unpushed" is a git question and the whole scope is found with
git commands — which is the one thing it cannot take from the facts.

## Learn the project first

Invoke the `dror-internal-project-facts` skill and carry what it returns into every agent
prompt below: the `domain` lens reviews against its vocabulary and invariants,
and its declared scope marks which findings are noise.

That skill is a **step of this one**, not a hand-off: the moment the facts are
in hand, continue at **Review** below in the same turn.

## The ticket, when there is one

A ticket number may be passed to this run. If one is, read it the way the
**issue convention** fact says this repo tracks work — on a GitHub repo that is
`gh issue view <n> --json title,body,state` — and number its acceptance criteria
1..N, the same numbering `dror-prove` and `dror-repair` use. A repo whose
convention came back unstated reviews without the ticket and says so. Carry that list into
every lens prompt beside the project facts: it is what the diff was written to
satisfy, and a lens that knows it stops reporting a deliberate choice as a
defect.

It is **focus, not scope**. The diff is still the whole scope, and a criterion
the diff does not touch is not this run's business. A criterion the diff
*claims* and misses is a finding of its own kind — `unmet criterion`, carrying
the criterion's number — which sorts with the latent hazards: it is neither a
bug in what was written nor a gap in cover.

**Nothing is written to the tracker here — no box, and no comment.** Ticking
belongs to `dror-prove`, which holds the criterion-to-test mapping, and unticking
to `dror-repair`, which watches a test go red. This run's per-criterion verdicts
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
this run's diff indistinguishable from the work you were asked about. That is not
hypothetical: `~/.claude/dror-skills/refutations.tsv` holds five finding ids
minted twice at one commit inside one minute, from two runs on unrelated subject
matter, and three of them now carry two different repair outcomes under one key.

**Look before reviewing, and use what is already on disk.** List
`<repo>/.claude/dror-skills/` for `review-report*.md`, and for each one that is
not the name this run will take, read its front matter — the ticket, the base,
the `HEAD` and the time. A report there written **recently** under another name
is another run in this tree.

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

**Mint a run tag** — four hex characters from `openssl rand -hex 2`, or the last
four of `date +%s` where that is not there — unless the caller gave one, in which
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

**Capture the diff once.** Write `git diff <base>` plus every untracked source
file to a single scratch file, and list the changed paths. Where the caller
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

**Run the lenses.** [`LENSES.md`](LENSES.md) is a **pool**, not a running order.
Choose from it the ones this diff raises and run each as one agent, all launched
in parallel, each given the scratch path, the changed-paths list, the project
facts above, and `LENSES.md`'s preamble plus its own lens section, verbatim.

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
cap**. Each is given: its finding; the project facts; the diff hunks touching
its finding's files, sliced from the scratch file by you — not the whole diff,
since a refuter judges one `file:line` against the live tree and the full diff
read once per refuter is the run's dominant token cost; the changed-paths list,
so it still knows the run's scope; and the scratch path, named as a fallback to
read only when its one finding genuinely needs the wider diff — that is the
refuter's budget to spend, on one finding. It is also given
[`REFUTING.md`](REFUTING.md)'s general sections verbatim — the
default-to-refuted opening, the claim section and the return section; a `cover`
finding (the `tests` lens's kind) additionally gets that file's missing-test
section, which no other kind needs.

Every suspect is checked: cutting the list here would put unchecked suspicions
in the report, which is the one thing this step exists to prevent, and a reader
cannot tell an unchecked finding from a confirmed one. The cost is controlled
before this point, not here — fewer lenses, a tighter read boundary, and lenses
that kill their own weak findings rather than passing them on.

Survivors are the report.

## Write the report down

Number the survivors: confirmed bugs first in severity order — the damage the
failure scenario does, a crash or corrupted data above a cosmetic fault — latent
hazards below. Save them to the store `dror-internal-project-facts` describes,
overwriting the previous one. It is the run's record, and later work in this
repo reads it instead of deriving the same findings again.

**The report's path is a parameter of this run, and the caller owns it.** A
caller that names one — a loop running several rounds, a second session sharing
the checkout — is the answer, whatever the default would have been. Write there,
create the directory if it is not there, and name the path you wrote on screen.
This is the same rule `dror-repair` has for the file it reads, and the two
together are what let one caller keep a review and its repair pointed at one
file.

**Undefined, the default applies**, and it is derived from what was reviewed: a
run given a ticket writes `<repo>/.claude/dror-skills/review-report-<n>.md`,
`<n>` being that ticket's number and nothing else — no `#`, no title, no slug, no
`ticket-` in front of it — and a run given neither a path nor a ticket writes
`<repo>/.claude/dror-skills/review-report.md`.

**Take the default's own name first.** The one observed failure of this rule is a
run that found `review-report.md` taken by another session and invented a third
name for itself while `review-report-<n>.md` sat free — a file `dror-repair` then
cannot find by the rule it is given. The ticket-scoped name is not a fallback for
a collision; it is the name a ticketed run has.

Only when the name it is entitled to is itself another run's is there a choice,
and it is a **narrow** one: **never overwrite a report you were not asked to
write**. A file there for *another* ticket is another run's, and a plain
`review-report.md` holding another ticket's report is the same situation wearing
the default name — keep your own findings, take a name of your own, and say on
screen which file they went to and why. The concurrency this guards against is
not hypothetical: the file being overwritten is one a repair run is about to
read. A caller that minted a path has already removed the case, which is the
reason to prefer passing one.

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

**The ticket line is what makes the file's name checkable.** A file name can be
taken by another run, mistyped or slugged, so a reader — and `dror-repair`
above all — cannot trust it alone. The line inside can be compared: a repair
holding ticket `<n>` reads the report it was pointed at, finds `Ticket:` and
refuses a file that names another ticket, whatever it is called. Write it even
where the name already carries the number; the point is that the two can be
compared.
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

**The id is `<head>-<tag>-<hhmm>-<n>`** — the short commit in the front matter,
this run's tag, the report's own time from the front matter, and the finding's
own number, so `9af24df-3f2a-1432-3`. It is what lets a later run say what became
of *this* finding: the repair records its outcome under that id, and the log
carries it in a column of its own. Nothing else joins them — the report carries
no lens, and a `file:line` moves. Number the kills on from the
survivors, in the order `## Refuted` lists them, so every merged finding has one
and the two sections never mint the same id twice.

**Three parts before the number, because each answers something the others
cannot.** A repair never commits (ADR 0007), so `HEAD` does not move between a
review, the repair that follows it and the review after that — and
`dror-implement-ticket` runs that cycle up to three times in one run, at one
`HEAD`. The **minute** is what separates those rounds: on `<head>-<n>` alone,
round 1's third finding and round 2's third finding are one id in the log, and
the repair outcomes recorded under it are two different defects'.

The **tag** is what separates two runs that share the tree, which the minute
cannot: two reviews at one commit inside one minute was written off as a case not
worth carrying for, and it then happened — five ids minted twice at `22a7d02`,
three of them now carrying two different repair outcomes each, from two
concurrent runs on unrelated subject matter (ADR 0025). Rounds are minutes apart
because a repair runs the suite between them; concurrent runs are not, and
nothing about their timing is under anyone's control.

Neither part is optional and neither replaces the other. A collision here is
**silent** — an append-only log cannot notice that a key it already holds has
arrived meaning something else — so the id is the one place in these skills where
the cost of being wrong is paid entirely by a later reader.

**Every finding carries one, survivors and kills alike, and this is not
optional.** A report written without ids cannot be joined to anything: its
repair records nothing (`dror-repair` writes no row it cannot key), and its log
lines answer only the questions that need no id. If a finding is worth writing
down it is worth a key, and the key costs one string.

**A finding is about fifteen lines.** This file is read start to finish by a
repair run and by you tomorrow, so it carries what is needed to act: the
`file:line`, the failure scenario, the kind, and the one or two sentences of
reasoning that make the scenario believable. What it does not carry is the
refuter's route — the files traced, the call sites checked, the reasoning
retold twice. A repair run redoes that work anyway, against the tree as it
stands, and reading a stale account of it first is worse than reading none.

**Then record the kills.** A last section, `## Refuted`, holding every finding
that did *not* survive: its id, its `file:line`, the lens that raised it, what
it claimed in one sentence, and why the refuter killed it. Say for each whether
a claim comment was written, and where.

It is the run's only record of its own *precision*. Keep it terse — one short
paragraph per kill, no failure scenarios, since nothing downstream acts on
these.

## Append to the log

The report is overwritten every run, and one run's kills are too few to read
anything into. So every **merged finding**, survivor and kill alike, is also
appended as one line to `~/.claude/dror-skills/refutations.tsv` — outside any repo,
because the question it answers is about the lenses and not about a project.
Create `~/.claude/dror-skills/` and the file with its header row when they are not
there — this is the first run's ordinary case, since nothing else creates that
directory. Write the header **only into a file that is absent or empty** — a
header appended over a file that already has one is a data row whose `lens`
column reads `lens`, and every later reading of the log then has to step around
it. Append only; never rewrite what is already in it.

Survivors go in as well as kills, because a lens's kill count says nothing on
its own: what matters is the *share* of its findings that died, and that needs
the denominator.

One tab-separated line per finding, these columns in this order:

`date` (ISO, from `date -I`) · `repo` (the directory name) · `head` (short
commit) · `lens` (the one that raised it; the merge's every-lens list joined by
`+`) · `path` (repo-relative file, no line number — line numbers go stale and
break grouping) · `kind` (bug / hazard / cover) · `verdict` (survived /
refuted / unverified) · `claim` (was a claim comment written: yes / no) ·
`summary` (under 80 characters, no tabs) · `id` (the report's
`<head>-<tag>-<hhmm>-<n>`).

**`id` is last, and a log written before it existed keeps every row it has.**
Where the header does not name it, add it to the **header line only** — the one
rewrite this file ever takes, bounded to that line and leaving every data row
exactly as it stands. Those older rows then hold nine fields under ten columns,
which is the truth about them: they have no id, they answer every question that
does not need one, and they sit out the ones that do. Never restate an old row
to fill it in — an id invented after the fact names a report nobody kept. A row
carrying an id in either older shape — `<head>-<n>`, or `<head>-<hhmm>-<n>` — is
left as it stands for the same reason; all three read as ids, and which one a row
uses says when it was written. **A reader joining on the id must therefore not
parse it into parts**: match it whole. The parts have grown twice and the field
count is what tells the shapes apart, so a join that split on `-` and took
position 2 as the minute would silently read a tag as a time.

**The `lens` column is a closed vocabulary**: a section name from `LENSES.md`,
or the reserved `criterion` for an `unmet criterion` finding, which no lens
raises. Nothing else may be written there — a name outside that set is a bug in
this run, not a new lens, and it silently corrupts every rate
`dror-review-retrospective` computes. Where the merge joined several, join their names
with `+` from the same closed set.

## Record the run itself

A lens that ran and found nothing writes no line above, so the log alone cannot
tell an area that came back clean from one nobody looked at — and every rate
computed from it is missing its denominator. The report says which lenses were
dropped; that fact dies with the report unless it is written where later runs
can read it.

So append one line to `~/.claude/dror-skills/runs.tsv`, created with its header on the
same terms as the log above. A **separate file**, deliberately: the log's
contract is one line per merged finding, and a run-level row inside it would be
counted as a finding by everything that reads it.

`date` · `repo` · `head` · `lenses_run` (the closed names, joined by `+`) ·
`lenses_dropped` (the same, or `-`) · `findings` (how many merged findings this
run produced, kills included) · `run_tag` (this run's tag) · `concurrent` (the
tags or names the check above saw, joined by `+`, or `-` for none seen).

**The last two columns are what make every rate in this file readable later.**
Without them a run that shared its tree with another is pooled with one that had
it to itself, and the difference is invisible: the neighbour's edits were in this
run's diff, so its findings are partly about work this run was never asked to
judge. A row cannot be corrected after the fact — the only moment anyone knows
who else was here is now. Add both to the **header line only** where a file
predates them, exactly as `refutations.tsv`'s `id` column was added, and leave
every existing data row as it stands: those rows hold six fields under eight
columns, which is the truth about them.

One line per review, whether it found anything or not — a run that produced no
findings is exactly the run the log cannot see, and the only one this file
exists to record.

Nothing here blocks the run: a log or a run file that cannot be written is one
sentence to the user under the findings, and the report still stands. Both are
disposable — deleting them costs `dror-review-retrospective` its history and nothing
else.

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

Done when every lens has returned, the findings have been merged, every merged
finding has faced a refuter, the claims the refutations called for are written,
the repair-or-not line is on screen,
this run's report
file holds the survivors, the refuted and — where a ticket was named — the
per-criterion verdicts, every merged finding has a line in
`~/.claude/dror-skills/refutations.tsv`, the run has its line in
`~/.claude/dror-skills/runs.tsv`, and that same list is on screen — with no line
of code changed.
