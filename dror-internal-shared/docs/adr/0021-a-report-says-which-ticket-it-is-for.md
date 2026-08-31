# A report says which ticket it is for, and the name is not the answer

A review report is named after what was reviewed — `review-report-<n>.md`, bare
`review-report.md` for a review of no ticket — and `dror-code-repair` was told to
find its file by that name alone, falling back to the bare one when the ticketed
name was absent.

Both halves fail in the same way. A name can be **taken** (two sessions, one
checkout — the case the ticketed name was invented for), **mistyped**, or
**slugged** by a run improvising around a collision; and the bare name is not a
default so much as *whichever run most recently had no ticket, or had one and
could not take its own name*. A real store held four reports, one of them called
`review-report-ticket-73.md` while `review-report-73.md` was free, and the bare
`review-report.md` holding round 2 of a different ticket entirely. A repair
following the fallback reads that one and fixes another ticket's findings under
this ticket's name.

So the report carries `Ticket: <n>` — or `Ticket: none` — in its front matter,
and **that line is the report's identity**. The name is a filing convention and
stays one. `dror-code-repair` compares the line against the number it was handed and
stops on a mismatch, whatever the file is called, and the bare-name fallback is
gone: where no report answers, the run says so.

## Considered options

**Keeping the fallback and warning about it** was rejected: the instruction
already carried the warning ("never read a *different* ticket's report because
it is the only file present") one sentence after the rule that produces exactly
that outcome, and the warning is unactionable — nothing in the file said whose
it was.

**Naming the report after the ticket and the head** was rejected as a fix to the
wrong layer: it makes collisions rarer without making any report checkable, and
a reader still has only a name to trust.

**Recording the ticket in the store as an index** was rejected for ADR 0002's
reason — a store is disposable and re-derivable, and an index that can go stale
against the files it indexes is worse than the files answering for themselves.

## Consequences

A report written before this line existed has no `Ticket:`, so `dror-code-repair`
falls back to the file **name** for those — a `review-report-<n>.md` matching
the number in hand is that ticket's — and never to the bare name. Old reports
age out of the store as reviews overwrite them, and nothing migrates them.

The ticketed name is a ticketed run's **own** name, not its collision fallback:
a run that reaches for it and finds it free takes it. Only where that exact name
is another run's is there a choice, and then the run says on screen what it took
— which is now a note about filing rather than the only record of what the file
contains.
