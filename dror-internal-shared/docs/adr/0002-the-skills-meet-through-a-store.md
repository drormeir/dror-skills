# The skills meet through a store, not a call

What one `dror-*` run learns about a repo is written to `<repo>/.claude/dror-skills/` —
`facts.md`, and a review report named after what was reviewed
(`review-report-<ticket>.md`, `adr-review-report-<adr>.md`) — and the next run
reads it before it derives anything. The skills therefore do not have to run in one session, in one order,
or in one context window to benefit from each other.

`.claude/` is the project's own directory for agent material, which is why the
store lives there rather than in a temp directory.

## Consequences

Every store is **disposable**: every value in it is re-derivable, deleting it
costs one re-gather, and anything unreadable is a miss, never an error.

Because a repair commits nothing, an unchanged `HEAD` is not evidence that a
report is unhandled — so a repair marks each finding it handled in the report
file, and a later run reads the marks.
