---
name: dror-internal-shared
description: Reference material the dror-* skills read - the test-writing rules, the glossary, the map and the decision record. A shelf, read by the skills that run.
disable-model-invocation: true
---

# dror-internal-shared

This directory is a shelf. It holds what more than one `dror-*` skill reads, so
that sharpening a rule sharpens every run that obeys it.

- [`WRITING-TESTS.md`](WRITING-TESTS.md) — how a test is written and how it is
  proved to bite. Read whole by `dror-prove` and `dror-repair`.
- [`CONTEXT.md`](CONTEXT.md) — the glossary. One entry per word these skills use.
- [`DROR-SKILLS.md`](DROR-SKILLS.md) — the map: what each skill is for and how
  they chain.
- [`docs/adr/`](docs/adr/) — one file per decision behind the skills, with the
  alternatives it was chosen over.

The other skills reach these files by path, as documents. This `SKILL.md` exists
so the directory is a legitimate skill directory in the tree, and its
`disable-model-invocation` keeps the shelf out of the always-loaded skill list,
so it costs context only when a file is actually read.
