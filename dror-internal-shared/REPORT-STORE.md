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

Create the directory when it is not there. Reports are overwritten by the next
run of the same thing, so nothing in the store is a history; the logs below are.

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

One name per ticket and per ADR is what keeps two sessions in one checkout from
overwriting each other's work-product — a report a repair run is about to read.

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

## The identity line

A name can be taken, mistyped or slugged, so the name is a filing convention and
never the report's identity. The front matter carries it instead — `Ticket: <n>`,
or `Ticket: none`; `ADR: <n>` for an ADR review — written even where the name
already has the number, so that the two can be compared (ADR 0021).

**Whatever picked the file, check what it says it is** before working from it:

- It names **your** number, or `none` while you were given none: this is the
  report, carry on.
- It names **another**: stop and say so, naming both numbers. This is the one
  mistake that silently repairs somebody else's findings under your number's
  name, and the file name is exactly what will not reveal it.
- It carries **no** identity line at all — a report written before the line
  existed. Fall back to the file **name**: a `review-report-<n>.md` or
  `adr-review-report-<n>.md` matching your number is yours, and anything else is
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

**`<head>-<tag>-<hhmm>-<n>`** — the short commit in the front matter, the run's
tag, the report's own time from the front matter, and the finding's number in it:
`9af24df-3f2a-1432-3`. It is the only key joining a report to the logs — the
report names no lens, and a `file:line` moves. Each part answers what none of the
others can, and neither the tag nor the minute is optional (ADR 0025).

**Every finding carries one, survivors and kills alike.** A report written
without ids cannot be joined to anything: its repair records nothing, and its log
lines answer only the questions that need no id. If a finding is worth writing
down it is worth a key, and the key costs one string.

**Match an id whole; never split it into parts.** Three shapes are in the logs by
age — `<head>-<n>`, `<head>-<hhmm>-<n>`, `<head>-<tag>-<hhmm>-<n>` — and a reader
that split on `-` and took position 2 as the minute would read a tag as a time
and produce a wrong answer rather than an error. A writer copies the string
verbatim from the report and never rebuilds it. A collision here is **silent**,
so its cost is paid entirely by a later reader (ADR 0025).

## The logs

Three tab-separated files under `~/.claude/dror-skills/`, outside any repo,
because the questions they answer are about the lenses and the skills rather than
about a project, and one repo's runs are too few to read anything into (ADR
0009):

- `refutations.tsv` — one line per merged finding.
- `runs.tsv` — one line per review run.
- `repairs.tsv` — one line per finding a repair handled.

Which columns each carries belongs to the skill that writes it. What follows
holds for all three.

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
