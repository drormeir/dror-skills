# Finding and fixing are two runs

> **Superseded in part by [ADR 0018](0018-which-skills-the-model-may-invoke.md)
> and [ADR 0023](0023-two-rounds-are-one-review.md).** The decision stands —
> finding and fixing are still two runs, and the review still edits nothing —
> but the absolutes below are gone: `dror-code-review-repair` and
> `dror-implement-ticket` chain the two runs automatically, and `dror-code-review`'s
> file now names `dror-code-repair` in prose. What survives is that the *review's
> report* hands off to no skill on its own; the consent to repair moved into
> invoking a loop that says it will repair.

`dror-code-review` produces a report and stops; `dror-code-repair` is started separately by
the user. A review that handed its findings straight to a repair would put a full
test-writing pass and a full-suite run inside what is meant to be a read-only
review, in the same context window, and the user would lose the moment at which
they accept or subtract from the findings.

## Consequences

The review's own file names no other skill, so nothing chains automatically. The
approval that `dror-code-repair` runs without is the one that already happened — at
the review, when the findings were accepted.
