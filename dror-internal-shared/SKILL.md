---
name: dror-internal-shared
description: Reference material the dror-* skills read - the test-writing rules, the glossary, the map and the decision record. Not a procedure; nothing runs it on its own.
disable-model-invocation: true
---

# dror-internal-shared

This directory is a shelf, not a procedure. It holds what more than one `dror-*`
skill reads, so that sharpening a rule sharpens every run that obeys it.

- [`WRITING-TESTS.md`](WRITING-TESTS.md) — how a test is written and how it is
  proved to bite. Read whole by `dror-prove` and `dror-repair`.
- [`CONTEXT.md`](CONTEXT.md) — the glossary. The words these skills use, and
  nothing else.
- [`DROR-SKILLS.md`](DROR-SKILLS.md) — the map: what each skill is for and how
  they chain.
- [`docs/adr/`](docs/adr/) — one file per decision behind the skills, with the
  alternatives it was chosen over.

Nothing invokes this skill. It exists so the directory is a legitimate skill
directory rather than a bare folder in the skills tree; its
`disable-model-invocation` keeps it out of the always-loaded skill list, so the
shelf costs no context.
