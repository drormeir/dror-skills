# The issue convention is a fifth project fact

`dror-internal-project-facts` returned four facts: domain vocabulary, verification
commands, test layout, declared scope. With the skills that take a ticket no
longer naming a tracker themselves (ADR 0011), something has to answer "how are
tickets tracked here" — so that is a fact like the others, cached once and read
by every skill that needs it.

## Considered options

Folding it into *declared scope* was rejected: that section would then hold two
unrelated kinds of fact. Letting each skill discover it was rejected as four
places to change per repo.

## Consequences

The stamp's check list gains `*.md` under `docs/` in a directory or file whose
name contains `agent`, or the fact would be cached from a file whose edits never
invalidate it. The list stays closed and decidable, so the hit/miss decision
comes out the same on every run.

**Later extension.** The same reasoning was applied a second time, to the
*verification commands* fact rather than this one: the check list now also names
the repo-root build and runner files (`package.json`, `Makefile`,
`pyproject.toml`, `Cargo.toml`, `go.mod`, `pytest.ini`, `tox.ini`). A stamped
file that changes is already a miss; a file that **appears** is not, and a repo
that gains a `Makefile` or moves its test config into `pyproject.toml` would
otherwise keep a cached command naming the old runner with nothing to invalidate
it. The decision above is unchanged — the list is still closed and still
decidable — and this records what was added to it.
