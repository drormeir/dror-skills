# Resolving an ADR number to its file

The shared rule for turning what the caller said — a number, or a path — into
the one file a run then reads. It lives here, owned by the shelf and belonging
to none of the callers: one copy, so widening what resolves widens every skill
that takes an ADR by number. Read this section before the first command that
needs a path; do not restate the pattern in the calling skill.

Why the rule is loose where it is loose, and strict where it is strict, is
ADR 0032.

What is **not** here is what the file is *for*. Whether the document is then
reviewed, repaired, or only checked for existence before the tracker is read
belongs to the skill that asked.

## A path always wins

A caller who names a path has already answered the question. Open it, whatever
the layout, and run no search — this is the escape hatch for every repo whose
decisions live somewhere this file does not describe, and it is never overridden
by a failed search.

## A directory the project declares comes next

A project whose ADR tool was pointed somewhere unusual says so in one of two
places, and both are read:

- **Its own rule file** — `CLAUDE.md` or `AGENTS.md`, already in context
  wherever these skills run.
- **`.adr-dir` at the repository root**, whose entire content is one line
  holding the path. `adr-tools` writes it on `adr init <dir>`, and several
  reimplementations write it always, so it is the declaration most repos have
  without having written one by hand.

A directory named in either is **added to the front of the search below**,
before the defaults, and the run says which directory it used and where the
declaration came from. Where both exist and disagree, the rule file wins: a
human wrote it more recently than the tool wrote its scaffolding.

This is the durable form of a standing instruction: the search is what actually
runs, so a declared directory is honoured on a long run exactly as on a short
one. What it is still not is a config format — `.adr-dir` is one line holding
one path, and reading it commits to no schema. Nothing here parses an ADR tool's
own settings file, in that tool's own schema, on the chance one exists.

## Then one search over the conventional homes

Write the number **bare**, with its leading zeros stripped — `7`, never `0007` —
and search the declared directory, if there is one, ahead of the defaults where
the tools that write ADRs put them:

```
find <declared> docs/adr doc/adr adr docs/decisions ai-docs/decisions \
  src/*/docs/adr -maxdepth 1 -type f -name '*.md' \
  2>/dev/null | grep -Ei '/(adr[-_])?0*7-'
```

Two things are deliberately loose there, because neither is a fact about which
decision the user meant:

- **The padding.** `7-`, `07-`, `007-` and `0007-` all resolve alike. A project
  counting in three digits is not a project whose tickets cannot be read.
- **An `ADR-` or `ADR_` prefix before the digits**, in any case. It is the most
  common naming in the wild and carries no information the number does not.

**A hit in the declared directory wins outright**, however many the defaults
also return. The project said where its decisions live, and a leftover under
`docs/adr/` from the tool it moved off is exactly what that declaration is for.

Among hits of equal standing: **one is the answer, zero or more than one is a
sentence and a stop, not a guess.** A repo picks one tool to author its
decisions, so more than one hit is uncommon — but it is what a half-finished migration looks like, and
`docs/adr/0007-x.md` beside `adr/ADR-007-y.md` is two decisions under one
number. A multi-context repo is the case where it is *ordinary* rather than a
mistake: each context numbers from one, so `src/billing/docs/adr/0007-*.md` and
`src/catalog/docs/adr/0007-*.md` are both real, and neither is the one meant.
Picking either would run a whole loop against a document nobody named,
so name every hit and say that a path settles it.

## What this deliberately does not resolve

**A date-numbered file.** `20260829-use-postgresql.md` is a date wearing a
number's place, and no padding rule reaches it from `7`. A repo numbering its
decisions by date is served by the path escape hatch above, and gets one
sentence saying the number could not be resolved — never a scan of every file's
contents hunting for a title that looks right.

**A decision directory that is neither declared nor on the list.** The default
list is the convention (ADR 0011) and it is closed on purpose: each entry is a
directory some published ADR tool actually writes to by default, and a longer
list would be guessing at repos nobody has seen. A repo that keeps decisions
elsewhere declares it, or uses the path escape hatch, and until it does either
one it gets the same sentence — the guessing does not move here.

**Anything deeper than the list reaches.** `-maxdepth 1` is per entry, and the
one nested layout on the list is spelled out as `src/*/docs/adr` because a
published tool documents it. A recursive search from the root was rejected: it
walks `node_modules`, vendored checkouts and test fixtures, and it turns a
missing declaration into hits from directories nobody offered as an ADR home.

**A separator that is not a hyphen.** `0007_use_postgresql.md` does not resolve.
No tool surveyed writes it, and loosening the separator would let a bare number
match text that is not a slug boundary at all.
