---
name: dror-internal-shared
description: Reference material the dror-* skills read - the test-writing rules, the report store's rules, the lens fan-out's rules, the ADR worktree's rules, the directory-override contract, the step-agent carrier, what a delegated skill's stop means to its caller, how an ADR number resolves to a file, Anthropic's published rules for a skill and their stamp, the glossary, the map and the decision record. A shelf, read by the skills that run.
disable-model-invocation: true
---

# dror-internal-shared

This directory is a shelf. It holds what more than one `dror-*` skill reads, so
that sharpening a rule sharpens every run that obeys it.

- [`WRITING-TESTS.md`](WRITING-TESTS.md) — how a test is written and how it is
  proved to bite. Read whole by `dror-prove` and `dror-code-repair`.
- [`REPORT-STORE.md`](REPORT-STORE.md) — which name a report takes, the identity
  line that makes the name checkable, the finding id, and the columns and
  discipline of all four logs. Read whole by the reviews that write a report,
  the repairs that read one, the loops that name the path both ends use, and
  `dror-review-retrospective`, which joins the logs by finding id. It shares a
  script with WORKTREE.md below: [`claim-path.sh`](claim-path.sh) takes a
  caller-named path and claims it exclusively, so of two writers reaching for one
  path exactly one gets it. Its mode says what the loser does — `next-free`
  steps aside to a name beside it, which is what a report wants; `exclusive`
  refuses and names the holder, which is what a lock wants. It enforces the
  claim, so it is where its bound lives. The two references own when each mode is
  reached for.
- [`LENS-FANOUT.md`](LENS-FANOUT.md) — which model a lens and a refuter run on,
  the escape a lens takes when its read boundary cannot settle the question,
  what a run does about a lens whose output never arrived and why it never asks
  twice, and the merge. Read whole by the three reviews before they launch a
  batch. Which lenses a review has, what each is given and what its merge groups
  by stay in the review that owns them.
- [`WORKTREE.md`](WORKTREE.md) — where an ADR's worktree goes and what it is
  called, the lock that keeps one ADR to one session, the three guards a project
  must satisfy before one may sit inside it, what is symlinked in, the preflight
  that proves the environment, and how a later run adopts what it finds. Read
  whole by the drains that create or resume one.
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
- [`ANTHROPIC-SKILL-RULES.md`](ANTHROPIC-SKILL-RULES.md) — Anthropic's published
  rules for writing a skill, distilled to what can be checked by reading one,
  stamped with the `ETag` of the upload they were read off, and closing with the
  places this repo diverges on purpose. It is prose for a person deciding what
  the rules are; nothing at run time reads it, and only
  `dror-skill-vendor-rules` in `refresh` mode rewrites it. Two scripts sit beside it, each owning one half of the work:
  [`skill-rules-check.sh`](skill-rules-check.sh) takes a skill directory and
  prints one `BREACH:` line per rule broken — it enforces them, so it is where
  their numerals live (ADR 0049) — and
  [`anthropic-stamp.sh`](anthropic-stamp.sh) compares the stamp against what the
  source serves now and prints one `VENDOR:` line. The rules file owns the URL,
  the `ETag` and the rules in prose.
- [`CONTEXT.md`](CONTEXT.md) — the glossary. One entry per word these skills use.
- [`DROR-SKILLS.md`](DROR-SKILLS.md) — the map: what each skill is for and how
  they chain.
- [`docs/adr/`](docs/adr/) — one file per decision behind the skills, with the
  alternatives it was chosen over.

The other skills reach these files by path, as documents. This `SKILL.md` exists
so the directory is a legitimate skill directory in the tree, and its
`disable-model-invocation` keeps the shelf out of the always-loaded skill list,
so it costs context only when a file is actually read.
