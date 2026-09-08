# A phase sweeps every ADR, one at a time, in a skill that owns the set

`dror-adr-sweep` runs `dror-adr-review-repair` over every member of a repo's
decision directory, sequentially, in ascending number order, under one phase tag,
and rolls the members up into one table with every question they left collected
under it. It does not fork.

## The want

Refining a whole set of decisions before any of them is implemented is a real
phase, and a bounded one: no ticket has been worked, so nothing downstream has to
be undone. Doing it by typing the loop once per ADR is not the same thing, and
two of the four reasons are correctness rather than convenience.

**The runs write into each other's documents.** A repair synchronises the copies
of what it wrote — the conventions doc, the glossary, a README index, a sibling
ADR's amendment note — so two members reach for one file. Sequential is safe;
parallel is not, and nothing beneath prevents it: the loop's own concurrency check
is a report and not a gate (ADR 0024), and it says so.

**Order matters, because ADRs cite each other.** A repair grounds every sentence
in the tree as it stands, so a member repaired early is grounded against
documents a later member then moves.

**The summaries do not add up**, and **the user-facing doors get buried.** Each
run prints its own rounds, its ending word, its breaches, conflicts, revisits,
ungrounded items and ticket drafts. Seventeen of those is not a phase report, and
the part that most needs collecting — the questions only the user can answer — is
the part scattered across seventeen transcripts.

## Considered options

**Extending `dror-adr-review-repair` to accept a set** was rejected. Its "one ADR,
named as one" stop exists because a wrong document costs three rounds of edits to
prose nobody asked about, and a set argument would need an exception written into
exactly that sentence. It would also make a skill that is deliberately about one
document carry the ordering, the roll-up and the resumption, and stop being
testable on its own.

**Nothing** — the user types the invocations — was rejected on the two
correctness reasons above: nothing in the typed sequence keeps two loops out of
one glossary, and nothing collects the questions.

**A citation graph for the ordering** was rejected. It is the ordering this wants,
and building one means reading every member in the phase's own context before the
first loop runs — the reading each member's fork exists to keep out — paid whether
or not any member has a finding. Ascending number is the cheap approximation:
decisions are numbered as they are taken, so a citation nearly always points
backwards.

**Two passes over the set** was rejected as a second sweep wearing a loop's
clothes. A second sweep is one command, and the summary says when it is worth
typing.

**A budget across the phase** — a total round count a member could exhaust — was
rejected as a cap on the wrong thing. Each member gets the loop's own cap, which
that file fixes; a phase that is too expensive is cut by cutting the set, which
the user does with the estimate in front of them.

## The decision

A skill that owns the set and nothing about a document. It resolves the decision
directory through `ADR-FILE.md`, takes as members the files whose names that same
rule would resolve a number to, resolves each member by number so one being worked
in a worktree is read there (ADR 0032), orders by number, runs one member at a
time, and hands every member the phase's tag.

**It does not fork**, and that is the same trade `dror-adr-resume` made. Forked,
it would spend a level of the spawn-depth cap on bookkeeping, and the member loop
— already `dror-adr-review-repair` → `dror-adr-review` → lenses and refuters —
would pay for it at the leaves, where the review's precision is. ADR 0043's rule
is that the chain gains no depth. What this costs is that the phase's own lines
sit in the user's session; they are one per member, and every member's work is
behind a fork of its own.

**Not forking buys one thing back**: this run can ask. It spends that on the
estimate before the phase starts and on the resumption question, and on nothing
else — every other question belongs to a member's loop and travels in its summary.

## Consequences

**A member that writes no report is skipped, not a failure.** A stub ADR ends its
review before any lens runs, and a phase over a directory with three stubs in it
is a phase.

**A phase is resumable**, through a state file beside the reports that is a
current position rather than a history — the drain's shape, for the drain's
reason. A resumed phase keeps the tag from the file, so its reports stay one
series.

**`dror-adr-review-repair` gains one clause**: a caller may hand it its run tag,
as it already hands one to `dror-adr-review`. Nothing else about it changes, and a
direct run mints its own tag exactly as before.

**The phase reports one thing the members cannot**: that a second sweep is what
checks the members whose turn came before the later repairs landed. It is said
once, in the summary, where any member repaired anything.

**The questions go to a file, not to the screen.** Each member's loop hands back
conflicts, revisits, ungrounded items, breaches and unfiled ticket drafts, and a
draft is a whole ticket body. Printed, a set of them is more than a screen holds
and more than a reader takes in after hours of waiting — and, since this run does
not fork, every one of them would also sit in the user's session for the rest of
the phase. So they are appended to a phase report as each member ends, and the
summary is one table of counts with that report's path under it. What the screen
loses is nothing a reader could have acted on there; what it buys is a sweep over
a whole directory that costs its session a row per document.
