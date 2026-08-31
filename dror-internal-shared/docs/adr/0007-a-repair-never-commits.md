# A repair never commits

`dror-code-repair` runs start to finish without stopping and hands back uncommitted
changes. Committing is the user's, and it is the point at which they read what a
run that made no stops actually did.

## Consequences

The commits cannot be used to tell what a repair handled, so the run marks each
finding it handled in the review's own report instead (ADR 0002). An unchanged `HEAD`
is the ordinary case after a repair, not evidence that the report is fresh.
