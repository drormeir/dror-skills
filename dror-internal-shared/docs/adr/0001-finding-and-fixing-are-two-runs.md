# Finding and fixing are two runs

`dror-review` produces a report and stops; `dror-repair` is started separately by
the user. A review that handed its findings straight to a repair would put a full
test-writing pass and a full-suite run inside what is meant to be a read-only
review, in the same context window, and the user would lose the moment at which
they accept or subtract from the findings.

## Consequences

The review's own file names no other skill, so nothing chains automatically. The
approval that `dror-repair` runs without is the one that already happened — at
the review, when the findings were accepted.
