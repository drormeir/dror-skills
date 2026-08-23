# A shared working tree is declared, not prevented

Two `dror-*` runs in one checkout review the same unpushed work and repair it at
the same time. Each run **looks for the other and says what it found**; nothing
locks, nothing blocks, and nothing narrows its own scope on the strength of it.

The tag `dror-review-repair` mints keeps two runs' *reports* apart and was never
more than that. The tree itself has no such protection, and the evidence that it
matters is in the log: `~/.claude/dror-skills/refutations.tsv` holds five finding
ids minted twice at commit `22a7d02` inside one minute, one set about drag-and-
drop and the other about the Top View panel — two concurrent reviews, not two
rounds. Three of those ids now carry two different outcomes in `repairs.tsv`
under one key. The same thing happened again while this decision was being
written: the log grew by eleven rows from a review no one in that session ran.

The harm is two-sided. A repair may fix another run's in-flight code under this
run's name, which is precisely what `dror-implement-ticket`'s step 0 exists to
prevent one level up and which nothing detected one level down. And every rate
`dror-review-retrospective` computes silently pools runs that saw each other's edits
with runs that had the tree to themselves.

## Why not prevent it

Isolation is the obvious answer and it is refused here. This repo is worked
concurrently on purpose: the standing conventions rule out `git worktree` and
rule out `git stash` for the same reason — other sessions are editing this
checkout, and a run that isolated itself would be hiding from the work rather
than reviewing it. A lock file would block a run somebody wants, at a moment
nobody is watching for it.

What is left is that neither run is surprised.

## What it costs to be a heuristic

The check reads what is already on disk — the report files in
`<repo>/.claude/dror-skills/`, whose front matter already carries the ticket, the
base, the `HEAD` and the time. No new store, no lifecycle, no stale-entry sweep.

It cannot see everything, and the wording says so. A run between its start and
its first report write is invisible; a report left by a run that finished an hour
ago is indistinguishable from a live one. So a neighbour found is a fact worth
saying and a neighbour **not** found proves nothing, which is why the front
matter records `Concurrent: none seen` rather than `Concurrent: none`.

## Consequences

`dror-review` mints a run tag whether or not a caller gave it one, and writes it
with the concurrency finding into the report's front matter and into two new
`runs.tsv` columns, `run_tag` and `concurrent`. The tag does **not** change the
report's name, which ADR 0021 still derives from the ticket. Older `runs.tsv`
rows keep six fields under eight columns, on the same terms as the `id` column
before them: a row cannot be corrected afterwards, because the only moment anyone
knows who else was in the tree is while they are.

`dror-repair` gains a third reading of a failing test — neither the fix nor a
test that pinned the old behaviour, but another run's edit arriving mid-run. It
is ruled out first where a neighbour was declared, reported as a
`pre-existing failure`, and **not** repaired.

Keeping two runs genuinely apart stays the caller's job and has one instrument:
**disjoint scopes**, which `dror-review` already takes. This decision does not
automate that choice, because a run that quietly reviewed less on a guess would
leave changed files unlooked-at with nobody told.
