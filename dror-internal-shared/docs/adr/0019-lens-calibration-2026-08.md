# Lens calibration, August 2026

The first `dror-review-retrospective` read 199 findings over 19 runs (`clone` 75%
refuted, `state` 60%, `logic` 58%, `domain` 52%, `collateral` 48%, `tests` 18%)
and three wording changes were applied from it.

**`state`'s staleness bullet now demands the read.** Around ten kills were one
belief — a flag or memo that is genuinely stale, refuted because nothing reads it
before it is refreshed. The lens spotted the write and never looked for the read.

**`clone` no longer owns documents.** Six of its fifteen kills were docstring,
ADR or design-doc omissions, which are `collateral`'s bullet; `docs` came out of
`clone`'s site list, and `dror-code-review` now keeps `collateral` among the five
whenever `clone` runs.

**`REFUTING.md` says the two defaults are not comparable.** `tests`' 18% is an
artefact of the `cover` section, not evidence that the other lenses are loose,
and the next retrospective must not narrow them toward it.

## Consequences

Recall is what a wording change spends, and the log cannot measure recall — no
line in it records a bug nobody raised. `state`'s new sentence is the one with a
real cost: an observable stale read whose reader lies outside the lens's boundary
(changed files plus direct callers) will now go unproposed rather than be widened
by a refuter. If a later retrospective shows `state`'s survivor count falling
with its rate, that is the trade going the wrong way and the sentence comes out.

The claim counts pointed somewhere no lens edit reaches: one large module took 13
of the 54 claim comments ever written, and a second one 5. Checking the
tree afterwards, **every one of those invariants is in the code** — the refuters
wrote them at the time, and they survived. So a high claim count reads as the
mechanism working, not as a backlog: it says a file was hard to read *before*
these runs. A file whose count keeps climbing after its invariants are written
down is the one worth acting on, and that takes a second retrospective to see.
