# Anthropic's published rules for a skill

This file owns **what Anthropic publishes about how a skill is written**, in
one copy, reduced to the rules a tool can decide by reading a skill's directory.
`skill-rules-check.sh` beside it enforces them and is the only place their
numerals are spelled; this file states them in prose and points there
(ADR 0049).

It does **not** own how this repo writes skills. Where the two differ, the repo
wins and the last section records the divergence, so nothing raises a house
convention as a breach.

It deliberately carries **no advice about writing well** — be specific, put the
important thing first, state your error handling. Anthropic publishes all of
that, and `dror-skill-review`'s `execution` and `sequence` lenses already judge
it, with this repo's own reasoning behind them and a refuter under every
finding. A second copy here would raise the same defect twice for the merge to
collapse. ADR 0049 is the argument.

## The source and its stamp

- Source: `https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf`
- The document carries no version and no publication date. Its identity is the
  file the URL serves.
- `etag: "fab163c4c9467659f98602f9e55ef437"`
- `last-modified: Thu, 29 Jan 2026 22:09:27 GMT`
- Distilled into this file on 2026-09-01.

The stamp is not the rules. It is the receipt saying which upload the rules
below were read off, so a run can tell whether what it enforces still matches
what Anthropic publishes. `anthropic-stamp.sh` beside this file makes that
comparison; it owns the check and this file owns the values it reads.
`dror-skill-vendor-rules` in `refresh` mode is the only thing that rewrites what
is below, and ADR 0048 says why that half is never scheduled.

The `ETag` is the whole signal. The guide states no version of its own, so
there is nothing else to compare — a changed `ETag` means the file was
re-uploaded and this distillation may be stale. The docs page covering the same
ground serves `cache-control: private, no-store` with no `ETag` and no
`Last-Modified`, which is why the PDF and not the page is the anchor here.

## The rules

Each one is decided by `skill-rules-check.sh`, which prints one `BREACH:` line
naming the file and the rule it broke.

- The **folder name** is kebab-case: no capitals, no underscores, no spaces.
- The **instruction file** is named exactly `SKILL.md`, case-sensitive.
- **`name:`** matches the directory name, and contains neither `claude` nor
  `anthropic` — both are reserved.
- **`description:`** exists, stays inside the published character bound, and
  carries **both halves**: what the skill does *and* the conditions that should
  trigger it. A description with only the capability is the guide's commonest
  defect. The trigger half is not owed by a skill carrying
  `disable-model-invocation: true` — it never enters the model's list, so it is
  chosen by name and a trigger clause would steer nobody.
- **No angle brackets** anywhere in the frontmatter. Frontmatter reaches the
  system prompt, so a bracket is an injection surface.
- **No `README.md`** inside a skill's own folder. A repo-level `README.md` for
  human visitors is explicitly fine and is not this rule's business.
- **`compatibility:`**, where present at all, stays inside the published
  character bounds.

## Where this repo deliberately differs

Nothing raises these.

- **The word ceiling.** The guide advises keeping a `SKILL.md` under five
  thousand words. Three of this repo's skills are past it —
  `dror-implement-adr`, `dror-implement-ticket` and `dror-code-review-repair` —
  and each is a long procedure rather than padding: the drain works a whole
  ticket list, and shortening it would push steps into companion files every run
  has to open anyway. The advice is not a harness limit, the check does not test
  it, and this repo accepts the divergence (ADR 0049).
- **The template.** The guide offers a recommended `SKILL.md` skeleton and calls
  it a template to adapt. A missing section of that skeleton is not a finding
  here; `dror-skill-review/LENSES.md` says so in its preamble.
- **Voice.** The guide's examples are neutral and generic. This repo's skills
  are terse and opinionated by decision, and a style note is not a finding.
- **Pointing over restating.** The guide's advice to keep instructions concise
  and this repo's ownership rule agree, but the repo goes further: a shared rule
  lives once on the shelf and every other file points. The repo rule governs.
