# The shared test-writing rules live in dror-internal-shared

`WRITING-TESTS.md` is read whole by `dror-prove` (a criterion whose code already
works) and by `dror-code-repair` (a gap in cover) — one machine with two kinds of
input, and two copies of these rules would drift within a week. It used to live
in `dror-prove/` and be reached by `dror-code-repair` at an absolute home path, which
is a skill depending on another skill's internals and breaks the moment either
one moves or is packaged.

It now lives in `dror-internal-shared/`, which owns no procedure and belongs to neither
caller. Each skill names it relative to the skills directory.

## Consequences

`dror-internal-shared` needs a `SKILL.md` to be a legitimate skill directory rather than a
bare folder in the tree; `disable-model-invocation: true` keeps it out of the
always-loaded list, so the shelf costs no context. The same folder holds the
glossary, the map and these ADRs.
