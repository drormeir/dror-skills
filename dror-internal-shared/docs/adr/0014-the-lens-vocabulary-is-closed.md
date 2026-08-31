# The lens vocabulary is closed, plus a reserved `criterion`

A real log accumulated five findings under a lens named `spec` — a lens no
section of `LENSES.md` defines. A retrospective reading that log computes rates
for a lens that does not exist, and cannot tell whether those findings were a
seventh perspective or a mislabelled criterion check.

So the `lens` column may hold only a name from `LENSES.md`, plus the reserved
name `criterion` for ticket-mode `unmet criterion` findings, which are neither a
lens's nor a bug. A name outside that set is a bug in the run, not a new lens.
The header row is written only into a log that is absent or empty, so a second
header can never arrive as a data row.

## Considered options

Adding `spec` to `LENSES.md` as a seventh lens was rejected: the pool is already
capped at five lenses per run, and what those findings actually were is the
ticket-criteria check `dror-code-review` already performs.

## Consequences

`dror-review-retrospective` can group by lens without first deciding which names are
real, and an unknown name is a signal to fix the review rather than a lens to
report on.
