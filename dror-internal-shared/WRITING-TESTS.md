# Writing a test that proves something

The shared rules for every `dror-*` skill that writes a test — `dror-prove` from a
ticket's criteria, `dror-repair` from a bug or a gap in cover. It lives here, in
`dror-internal-shared/`, owned by the shelf and shared by both callers: one copy,
so sharpening a rule sharpens both runs (ADR 0015). Read this file whole before writing a
test; do not restate it in the calling skill.

## Vocabulary

- **red** — the test was run, and its failing assertion pasted with the run's
  summary line. An item is red only when that output is on screen.
- **green** — the test was run after the code exists, and its passing summary
  line pasted.
- **red by mutation** — how an item whose code already works earns the same
  evidence: the test is run against a **copy of the repo in the scratchpad**
  with the named behaviour broken, and its failing assertion pasted. It is
  **evidence, not a verdict** — the item that earned it is *green*, and the
  mutation is what a report names beside that word.
- **unproven** — the mutation cannot be staged (a real race, real GUI timing,
  the other platform). The test is kept and named; what is missing is the
  evidence, not the test.
- **untestable** — no reasonable test can catch it at all: a wrong comment, a
  stale document. No test is written, and the reason is recorded.

A test believed to fail is worth nothing; a test seen to fail is the whole
point. Never write red or green for a run you did not make.

## Every test obeys three rules

- **Drives the public interface.** The assertions read what a caller reads,
  never an internal.
- **Compares against an independent expected value** — the literal the spec or
  the criterion names (the 84 characters, the 143 bytes, the worked example), a
  value computed a different way, or one written out by hand. A test that
  recomputes its expectation the way the code does passes by construction and
  can never disagree with it. Never import the module's own constant and assert
  the module equals it.
- **Checks one behaviour**, so its failure names what broke.

## A test that reads the tree scopes its own walk

Some things are proved by reading the source rather than calling it — "this name
appears in exactly three places", "nothing under this package imports Qt". The
test walks the files itself, and that walk sits outside every guard the project
has: `.gitignore`, pytest's `norecursedirs` and mypy's `exclude` keep the
*tools* out of a directory, and not one of them reaches a test doing its own
`rglob`. A second copy of the repository under the checkout — an ADR worktree at
`.claude/adr-wip/adr-<N>` is the ordinary one — is walked like any other
directory, so a test asserting *three* call sites finds six: true about the files
on disk, false about the program, and green everywhere the second copy is absent.

So a test that walks:

- **Roots the walk at the code it is asserting about**, derived from that
  package's own `__file__` — never the current directory, and never a repository
  root found by walking upward. The narrow root is most of the fix, and it is the
  half that does not depend on remembering a list of names.
- **Prunes dot-directories by name** wherever the root is still above one:
  `.claude`, `.git`, `.venv`, `.tox`, the caches. Excluding `.venv` and `tests`
  alone is not this rule — each of those names was excluded for a reason of its
  own, and the copies are what this one is about.
- **Names the paths it found in the failure message**, so the run that does fail
  says *which* files it counted. A bare `assert len(hits) == 3` reports a number
  and leaves the reader to guess whether the program changed or the walk did.

## Where a test goes

Take the first route that fits:

1. **Enrich an existing test** that already exercises this code.
2. **Enrich a test added in the work in hand** — the unpushed commits as well as
   the working tree — if one is there.
3. **Create a file**, preferring one file that covers several items over one
   file per item.

Follow the project's own layout and runner (`dror-internal-project-facts` holds both); do
not invent a new test tree. A test that needs a GUI, a server or the app
singletons goes through the project's isolation helper like every other.

## Proving a test bites when the code already works

This is the same machine whatever fed it — a gap in cover a review named, or a
criterion whose module is already written. The test passes on its first run, so
that run proves nothing:

1. Copy the repo, or the package the behaviour lives in, into the scratchpad.
2. Break **that item's own behaviour** there, in the one way it forbids. The
   mutation is the item's own negation, never a weaker one: an item fixing 84
   characters is mutated to 85, not to a syntax error. A review that already
   named the edit ("delete this line and the suite stays green") gets *that*
   edit.
3. Run the test in the copy and paste its failing assertion.
4. Delete the copy.

The mutation is made in the copy, **never** in the working tree — a run that
broke the code to prove a test works has left a repo that may not be put back.
Where no copy can stage it, record the item as **unproven**.

## Share the expensive setup

Tests that pay the same cost should pay it once, where that is a reasonable
change and not a contortion:

- **Group by what they set up**, not by item order. Three items needing one
  built object means one fixture and three tests, not three builds.
- **Widen a fixture's scope** (`module`, `session`) when what it makes is read
  and not mutated — a decoded file, a Qt application, a temporary tree of
  synthetic data, a loaded model. A fixture the tests write to stays per-test.
- **Reuse the fixtures already in the file or its `conftest.py`** rather than
  building a second copy under a new name.
- **One parametrized test** where several items are the same assertion over
  different inputs. The parameter's `id` carries the item's number so the
  mapping survives.

The limits: never merge tests whose failures would then be indistinguishable —
one item must still be able to go red on its own, and its number must still name
it in the output. Never share state a test mutates. Never restructure a test file
that is not part of the work in hand to make a saving. And do not trade
readability for a saving too small to measure.
