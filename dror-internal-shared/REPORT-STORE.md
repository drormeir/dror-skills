# The report store: names, identity, ids and logs

The shared rules for every `dror-*` skill that writes a report, reads one, or
names the path both ends use. They live here, owned by the shelf and belonging to
none of the callers: one copy, so sharpening a rule sharpens every run that obeys
it. Read this file whole before writing or reading a report; do not restate it in
the calling skill.

What is **not** here is any report's own contents. Which findings a report holds,
in what order, under what headings, and which columns its skill appends to a log
belong to the skill that writes them.

## The store

`<repo>/.claude/dror-skills/` holds what one run leaves for the next: `facts.md`,
and the reports (ADR 0002). It is **disposable** — everything in it is
re-derivable, deleting it costs one re-run, and a file that cannot be read is a
miss and never an error.

Create the directory when it is not there. Nothing in the store is a history — a
report is replaced or set aside by the next run of the same thing; the logs
below are the history. **A loop's rounds are the exception** (ADR 0041): each
round keeps its own report, at the round-suffixed path its caller names, and no
round overwrites another. What a later run replaces is the last run's report of
the same thing, never an earlier round of its own.

## Which name a report takes

**The path is a parameter of the run, and the caller owns it.** A caller that
names one — a loop running several rounds, a second session sharing the checkout
— is the answer, whatever the default would have been. Write there, and name the
path you wrote on screen. This is the same rule the reading skills have for the
file they read, and the two together are what let one caller keep a review and
its repair pointed at one file.

**Undefined, the default applies**, derived from what was reviewed and carrying
that number and nothing else — no `#`, no title, no slug, no `ticket-` in front
of it:

- a code review given a ticket — `review-report-<n>.md`
- a code review given neither a path nor a ticket — `review-report.md`
- an ADR review — `adr-review-report-<n>.md`, `<n>` being the ADR's number; the
  bare `adr-review-report.md` only for a run that somehow has no number, which is
  close to unreachable, since an ADR is what that skill is invoked on.
- a skill review — `skill-review-report-<name>.md`, `<name>` being the skill's
  own name, which that run always has, since a skill is what it is invoked on.
- a skill review given a **document** rather than a skill —
  `doc-review-report-<slug>.md`, `<slug>` being the document's repo-relative
  path with every `/` and `.` turned into `-`, so
  `dror-internal-shared/REPORT-STORE.md` becomes
  `doc-review-report-dror-internal-shared-REPORT-STORE-md.md`. The path is the
  only name a document has that two of them cannot share.

One name per ticket, per ADR and per skill is what keeps two sessions in one
checkout from overwriting each other's work-product — a report a repair run is
about to read.

**Take the default's own name first.** The ticket-scoped name is the name a
ticketed run *has*, not a fallback for a collision: a run that reaches for it and
finds it free takes it, and a run that invents a third name while its own sits
free writes a file the repair cannot find (ADR 0021).

Only where the name it is entitled to is itself another run's is there a choice,
and it is a **narrow** one: **never overwrite a report you were not asked to
write.** A file there for another ticket or another ADR is another run's, and a
bare `review-report.md` holding another ticket's report is the same situation
wearing the default name — keep your own findings, take a name of your own, and
say on screen which file they went to and why.

**A caller-named path is claimed before anything is written to it**: run
[`claim-path.sh`](claim-path.sh), the script beside this file, in its
`next-free` mode with the path after it, and write the report to the path it
prints. It creates the file empty and prints either the path asked for
or the same name with a `-<k>` before the extension, and of two writers reaching
for one path exactly one wins, decided by the kernel rather than by a clock
reading or a look-then-write. Where it printed a path other than the one asked
for, that is another writer already there — say so on screen with the path it
gave, and tell the caller that name, since the caller is what a repair reads the
path from. The script owns how far the `-<k>` names run; this file does not
restate it.

**A run writes its report once.** The claim above stops another writer taking
the path; it cannot stop the claimant taking it twice, since by then the file is
the run's own. So before writing, read what is there: a report at that path
already carrying **this run's tag and this run's round** is this run's own
earlier write, and the run has repeated a stage it already finished. Do not
overwrite it and do not write beside it. Say on screen that the report was
already written, name the path, and end the run on that — a second pass over one
round is a defect to surface, not a result to file. Only a run that finds the
path empty, or holding another run's tag, writes.

**`next-free` is the right mode because a report's name is a filing convention.**
Nothing opens a report by guessing its name — a repair is told the path. The
script's other mode refuses instead of stepping aside, and it is for a file a
later run *does* open by name; WORKTREE.md owns that case and this file does not
restate it.

**A default name is not claimed.** It is the name of the *thing* reviewed rather
than of one run, so replacing the last run's report of the same ticket, ADR or
skill is what it is for — claiming it would leave a run that meant to replace a
report writing beside it instead.

## The identity line

A name can be taken, mistyped or slugged, so the name is a filing convention and
never the report's identity. The front matter carries it instead — `Ticket: <n>`,
or `Ticket: none`; `ADR: <n>` for an ADR review; `Skill: <name>` for a skill
review; `Document: <repo-relative path>` for a review given a document rather
than a skill — written even where the name already has the number, so that the
two can be compared (ADR 0021). A document's line carries the path unslugged,
since the slug in the file name is lossy and the path is what a reader opens.

**The front matter also says who wrote it.** `Run: <tag>`, this run's tag, and
`Round: <k>` or `Round: -` where no caller named one. The name may carry the tag
too, and it is written again here for the same reason the number is: a name is a
filing convention and the front matter is the fact. Together they are what lets
a reader that finds the file changed tell **its own run's second write from
another run's first** — the one question the path cannot answer, and the one
whose wrong answer blames a session that was never there.

**Whatever picked the file, check what it says it is** before working from it:

- It names **your** number, or `none` while you were given none: this is the
  report, carry on.
- It names **another**: stop and say so, naming both numbers. This is the one
  mistake that silently repairs somebody else's findings under your number's
  name, and the file name is exactly what will not reveal it.
- It carries **no** identity line at all — a report written before the line
  existed. Fall back to the file **name**: a `review-report-<n>.md`,
  `adr-review-report-<n>.md`, `skill-review-report-<name>.md` or
  `doc-review-report-<slug>.md` matching your
  number, name or path is yours, and anything else is
  read only when the caller named it outright. Never take a bare report for a
  numbered run's on the grounds that it is the only file present; it is as likely
  to be another number's round that could not take its own name.

Where no report answers, say so and work from what the conversation named — an
absent report is not a reason to read the nearest one.

**A report is stale-prone in two ways**, and both are checked before any work
starts. Its recorded base or `HEAD` may differ from the current one, and then its
line numbers came from another state of the tree — say so, and locate each
finding by what the code says rather than by the number. And a finding it already
carries as repaired was fixed by an earlier run: leave it alone and name it as
already done. A repair commits nothing (ADR 0007), so an unchanged `HEAD` is the
ordinary case and not evidence the report is fresh.

## The finding id

**`<head>-<tag>-r<k>-<n>`** — the short commit in the front matter, the run's
tag, the round with an `r` in front of it, and the finding's number in it:
`9af24df-1788272409342146839-r2-3`. Where no caller named a round it is `r-`,
the same fact the logs' `round` column writes as `-`. It is the only key joining
a report to the logs — the report names no lens, and a `file:line` moves. Each
part answers what none of the others can, and neither the tag nor the round is
optional: the tag separates two runs and the round separates one run's rounds,
which share a commit because a repair never commits (ADR 0050).

**The tag is minted by this recipe and no other**: the epoch nanoseconds from
`date +%s%9N` — unless the caller handed a tag in, in which case that one is
used unchanged. A skill that needs a tag says "mint a run tag by the store's
recipe" and does not restate the command. A clock reading, not a random draw.

**Every finding carries one, survivors and kills alike.** A report written
without ids cannot be joined to anything: its repair records nothing, and its log
lines answer only the questions that need no id. If a finding is worth writing
down it is worth a key, and the key costs one string.

**Match an id whole; never split it into parts.** Four shapes are in the logs by
age — `<head>-<n>`, `<head>-<hhmm>-<n>`, `<head>-<tag>-<hhmm>-<n>` and the
current one — and a reader that split on `-` and took position 2 as the minute
would read a tag as a time and produce a wrong answer rather than an error. The
last change makes this worse, not better: a round and a minute are both short and
both numeric, so a reader taking a position now reads one as the other with
nothing to notice. A writer copies the string verbatim from the report and never
rebuilds it. A collision here is **silent**, so its cost is paid entirely by a
later reader (ADR 0025, ADR 0050).

## The logs

Four tab-separated files under `~/.claude/dror-skills/`, outside any repo,
because the questions they answer are about the lenses and the skills rather than
about a project, and one repo's runs are too few to read anything into (ADR
0009):

- `refutations.tsv` — one line per merged finding, plus `dror-code-review`'s
  unmerged `tool` findings (ADR 0045).
- `runs.tsv` — one line per review run.
- `repairs.tsv` — one line per finding a repair handled.
- `handbacks.tsv` — one line per criterion a prove hands back to the user.

**The first three have several writers each**, so all their column lists live
here, once. A skill that appends to one of these files points at this section
and does not restate the list; what it does say in its own file is what its own
**values** are, which is the part that genuinely differs between the writers.

**`refutations.tsv`** — written by `dror-code-review`, `dror-adr-review` and
`dror-skill-review`:

`date` (ISO, from `date -I`) · `repo` (the directory name) · `head` (short
commit) · `lens` (the one that raised it; a merge's every-lens list joined by
`+`) · `path` (repo-relative file, no line number — line numbers go stale and
break grouping) · `kind` (the writing skill's closed kind vocabulary) ·
`verdict` (survived / refuted / unverified) · `claim` (was a claim comment
written: yes / no) · `summary` (under 80 characters, no tabs) · `id` (the
report's finding id, copied whole) · `report` (the path this run's report was
written to, as named on screen) · `round` (which round of a caller's loop this
run was, `1` upward, or `-` where the caller ran no loop) · `subject` (the
ticket or ADR number this run was given — or, for a skill review, the skill's
name, or the repo-relative path of the document it was given instead — or `-`) · `run_tag` (this run's tag, the same value
its `runs.tsv` row carries). **`id` and `report` keep their positions in
that order, and every column added later follows them**, so a row written
before the addition stays readable as the shorter row it is. Each writer says
in its own file what its `kind`, `path`, `claim` and `subject` values are.

**`round` is what makes a loop's rounds separable at all.** Without it a
three-round loop appends its findings as one undifferentiated block, and the
question a retrospective most wants to ask — did a later round find defects in
files an earlier round never opened, or in the code its repair had just
written — cannot be asked of the log at any price. It is written by the run,
from the number its caller handed in, and never read back out of a finding id —
the id now carries the round, and the rule above still forbids splitting one to
get at it. `round` separates a
loop's rounds; **`run_tag` is what joins them into one run** — ids may not be
split and report names are matched whole, so without this column no reader can
tell which round-1 rows belong with which round-2 rows once two loops share a
repo.

**`runs.tsv`** — written by `dror-code-review`, `dror-adr-review` and
`dror-skill-review`:

`date` · `repo` · `head` · `lenses_run` (the writer's own closed lens names,
joined by `+`) · `lenses_dropped` (the same, or `-`) · `findings` (how many
merged findings this run produced, kills included) · `run_tag` (this run's tag) ·
`concurrent` (what the run knows about who else was in the tree) · `round` (as
in `refutations.tsv` above) · `subject` (the same) · `elapsed_s` (whole seconds
this run took, from its own two clock readings, or `-` where it took none) ·
`lenses_lost` (the lenses this run launched whose output never came back).
Each writer says in its own file what it may write in `concurrent` — the two
differ, and the difference is the point: a review that runs a neighbour check of
its own can write `-` for *looked and saw nobody*, and one that runs none writes
`unchecked`, which is not the same fact.

**`lenses_lost` is the third state a lens can be in, and the two columns before
it cannot hold it.** A lens that launched and delivered nothing is neither run —
its axis was never judged — nor dropped, which says a run chose not to look. Put
it in either and the log asserts something false about what was covered. So it
has a column of its own, carrying the writer's own closed lens names joined by
`+`, or `-` where every launched lens returned. Only a run that counted what
came back against what it launched may write either, so **the column is written
by `dror-code-review`, `dror-adr-review` and `dror-skill-review`** — the three
that run that check. A writer that runs no such check ends its row at
`elapsed_s` and leaves this field off, by the append-only rule below: a short
row is the truth about a run that never had the fact, and `-` there would claim
a check that never ran.

**`elapsed_s` is a measurement, not bookkeeping.** A review run is a lens
fan-out and a refuter under each finding, and how much of a chain's wall-clock
that costs has never been recorded anywhere — so every judgement about whether
the loop is worth its rounds has been made from the round *count*, which the
one drain that measured both showed does not predict duration. Two `date +%s`
readings per run answer it directly. A run that did not read the clock writes
`-` and is excluded from any mean, exactly as an unworked round is.

**`repairs.tsv`** — written by `dror-code-repair`, `dror-adr-repair` and
`dror-skill-repair`:

`date` (ISO) · `repo` (the directory name) · `id` (copied whole from the report,
by the rule above) · `outcome` (the word from this run's own report) ·
`files_edited` (the repo-relative files **this run** edited, joined by `+`, or
`-` where it edited none; **more than six is the first six and `+N more`**) ·
`production` (did any of them sit in the production path: yes / no). Each writer
says in its own file what its `outcome` vocabulary is and what it may write in
`production`.

The **same list on every row a run appends**, including a row whose finding was
ruled out or not reproduced: `files_edited` and `production` describe the *run*,
not the finding, and a per-finding attribution would claim a precision no repair
has, since a shared helper is edited for several findings at once.

**`handbacks.tsv`** — written by `dror-prove` alone, one line per criterion it
hands back rather than ticks:

`date` (ISO) · `repo` (the directory name) · `head` (short commit) · `subject`
(the ticket number) · `criterion` (its number in the ticket, by Step 1's
numbering) · `state` (the verdict word: `noted`, `partial`, `criterion wrong`,
`question open`) · `check` (the command the Note carries, under 120 characters
and no tabs, or `-` where the Note carries none) · `recommendation` (`met`,
`not met`, `cannot say`, or `-`) · `evidence` (the store path the Note names, or
`-`) · `run_tag` (this run's tag).

It answers one question nothing else can: how often this chain stops for the
user, and how many of those stops arrived with the work behind them done. A row
whose `check` is `-` and whose `recommendation` is `-` is a hand-back the user
had to investigate themselves, and a run of them is the signal that the Note
rules are being written past.

What follows holds for all four.

**Create the directory and the file with its header row when they are not
there** — the first run's ordinary case, since nothing else creates that
directory. Write the header **only into a file that is absent or empty**: a
header appended over a file that already has one is a data row whose first column
reads its own name, and every later reading has to step around it.

**Append only; never rewrite what is already there.** Where a column has been
added since a file was written, add it to the **header line only** — the one
rewrite these files ever take — leaving every data row as it stands. Those rows
then hold fewer fields than there are columns, which is the truth about them, and
a value invented after the fact names a run nobody kept (ADR 0009).

**Nothing here blocks a run.** A log that cannot be written is one sentence to
the user under the findings, and the report still stands. All three are
disposable: deleting them costs `dror-review-retrospective` its history and
nothing else.
