# The refutation log lives outside any repo, and records survivors too

Every merged finding — survivor and kill alike — is appended as one line to
`~/.claude/dror-skills/refutations.tsv`. It sits outside any repo because the question
it answers is about the lenses, not about a project, and one repo's runs are too
few to read anything into.

Survivors go in because a lens's kill count says nothing on its own: what matters
is the *share* of its findings that died, and a share needs its denominator.

## Consequences

A review report is overwritten by the next review of the same thing and cannot carry this history; the
report's `## Refuted` section is that run's record of its own precision, and the
log is the accumulation `dror-review-retrospective` reads.

The log is append-only and never rewritten. Nothing about it blocks a review: a
log that cannot be written is one sentence to the user, and it is disposable —
deleting it costs `dror-review-retrospective` its history and nothing else.
