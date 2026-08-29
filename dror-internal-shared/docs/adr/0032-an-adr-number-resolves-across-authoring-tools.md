# An ADR number resolves across authoring tools, by name shape and not by tool

Turning a number into a file is one rule, owned by `ADR-FILE.md` on the shelf,
and it resolves the naming every published ADR-authoring tool writes by default
rather than the one this repo happens to use. `dror-show-tickets`,
`dror-adr-review` and `dror-adr-review-repair` point at it and restate nothing.

The rule was `docs/adr/<NNNN>-*.md`, four digits, zero padded — written out in
three skills and three map files. That is exactly one tool's default. A survey of
the five that write ADRs today found four different names for the same decision:
Matt Pocock's `domain-modeling` and zircote's plugin write
`docs/adr/0007-slug.md`, EvolveHQ's docflow writes `adr/0007-slug.md` at the repo
root, shinpr's workflows write `docs/adr/ADR-0007-title.md`, madappgang's skill
writes `ADR-0007-slug.md` and recommends `ai-docs/decisions/`. Three of the five
were unresolvable, and zircote's own `numbering.pattern` turns the fourth into
`007-slug.md` with one line of project config.

So the search is loose in the two places that carry no information about *which
decision the user meant* — the leading zeros, and an `ADR-` or `ADR_` prefix —
and it looks in the three directories those tools actually write to. What stays
strict is the rest: a hyphen after the digits, `.md`, and a name whose digits
start it.

**A directory the project declares in `CLAUDE.md` or `AGENTS.md` goes first, and
a hit there wins outright.** This is the answer to a tool configured off its own
default — the case the loosening above does not reach — and it beats a leftover
file under `docs/adr/` from the tool a repo moved off, which is the whole reason
a project would declare one.

## Considered options

**Leaving it strict** was the status quo, and its cost is not a stopped run but a
stopped run *per ADR forever*: a repo whose tool writes three digits fails every
time, and the failure reads as a missing decision rather than a naming mismatch.

**Reading each tool's own settings file** — zircote's `.claude/adr.local.md` says
`adr_paths` and `numbering.pattern` outright — was rejected as a parser per tool,
in a schema that tool may change, for a directory a human can state in one line.
The declaration channel gets the same answer at a fraction of the surface.

**A sixth project fact** carrying the decision directory was rejected as the
expensive shape of the same idea: it enlarges `dror-internal-project-facts`, its
store and its stamp, and pushes a line into every agent prompt of every run, to
serve a lookup one `find` already makes.

**A standing instruction in the project's `CLAUDE.md`, with no rule here to
receive it**, very nearly works — that file is in context on every run in the
repo. Rejected because it is prose competing with prose: the `find` is what
actually runs, and a rule the search itself honours cannot be crowded out on a
long run the way an instruction read a hundred turns ago can.

**Resolving date numbering and underscores too** was rejected as guessing.
`20260829-slug.md` is not reachable from `7` by any padding rule, no surveyed
tool writes `0007_slug.md`, and loosening the separator lets a bare number match
text that is not a slug boundary. Both are served by naming the path.

## Consequences

Ambiguity is a real outcome now, where the strict rule could not produce one:
`docs/adr/0007-x.md` beside `adr/ADR-007-y.md` is two decisions under one number.
More than one hit of equal standing is a stop that names every hit and says a
path settles it — never a pick.

The convention-bound tier of ADR 0011 is unchanged in substance; only its
description moved from a path shape to a pointer at the shelf. Every skill that
took an ADR by number now says "a conventional decision directory, resolved by
`ADR-FILE.md`", so the next widening is one file's edit rather than six.

`dror-implement-adr` gains nothing from this. It works from the tracker, and no
tool surveyed writes tickets at all — a resolved ADR file with no spec issue
behind it still reports nothing workable.
