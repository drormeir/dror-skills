---
name: dror-internal-shared
description: Reference material the dror-* skills read - the test-writing rules, the report store's rules, the ADR worktree's rules, what a delegated skill's stop means to its caller, how an ADR number resolves to a file, the glossary, the map and the decision record. A shelf, read by the skills that run.
disable-model-invocation: true
---

# dror-internal-shared

This directory is a shelf. It holds what more than one `dror-*` skill reads, so
that sharpening a rule sharpens every run that obeys it.

- [`WRITING-TESTS.md`](WRITING-TESTS.md) — how a test is written and how it is
  proved to bite. Read whole by `dror-prove` and `dror-code-repair`.
- [`REPORT-STORE.md`](REPORT-STORE.md) — which name a report takes, the identity
  line that makes the name checkable, the finding id, and the columns and
  discipline of all three logs. Read whole by the reviews that write a report,
  the repairs that read one, the loops that name the path both ends use, and
  `dror-review-retrospective`, which joins the logs by finding id.
- [`WORKTREE.md`](WORKTREE.md) — where an ADR's worktree goes and what it is
  called, the three guards a project must satisfy before one may sit inside it,
  what is symlinked in, the preflight that proves the environment, and how a
  later run adopts what it finds. Read whole by the drains that create or resume
  one.
- [`DELEGATION.md`](DELEGATION.md) — what a sub-skill's closing contract means to
  its caller, and the shape a delegating step must have: it ends on a named next
  action, and the sub-skill's own stop is never edited to suit it. Read whole at
  authoring time by whoever writes a step that invokes another skill; never at
  run time.
- [`ADR-FILE.md`](ADR-FILE.md) — how an ADR number becomes the one file a run
  reads: the directories it searches and how a project declares another, the
  padding and prefix it tolerates, the path escape hatch, and the stop on a
  number that resolves to none or two. Read by every skill taking an ADR by
  number.
- [`CONTEXT.md`](CONTEXT.md) — the glossary. One entry per word these skills use.
- [`DROR-SKILLS.md`](DROR-SKILLS.md) — the map: what each skill is for and how
  they chain.
- [`docs/adr/`](docs/adr/) — one file per decision behind the skills, with the
  alternatives it was chosen over.

The other skills reach these files by path, as documents. This `SKILL.md` exists
so the directory is a legitimate skill directory in the tree, and its
`disable-model-invocation` keeps the shelf out of the always-loaded skill list,
so it costs context only when a file is actually read.
