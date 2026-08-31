# A loop's step rides an agent, not a fork

`dror-review-repair` used to invoke `dror-review` and `dror-repair` as the
`context: fork` skills they are, and unfork them only under a directory
override (ADR 0043's fold). The fork carrier failed outside the drain too:
on 2026-08-31, in this repo's own tree, a directly-invoked loop's `Skill
dror-review` arrived without its arguments, and a drain-free run earlier the
same day dropped the same way — ADR 0043's "no level count is trusted here".

## The defect

When the drop hits, the fork reviews the session's checkout in good faith and
reports its clean tree as convergence; when a run recovers by following the
step files inline, every lens return and refuter verdict lands in one window.
Both costs are hidden: the wrong-tree review looks like a finished round, and
the flooded context is token spend re-sent on every later turn of a fork the
user never sees.

## Considered options

**Trusting the depth arithmetic** — fork when shallow, agent when deep — was
rejected: the sessions on record disagree about the depth at which a fork
loses its arguments, so the condition cannot be computed.

**Detecting a bare fork and retrying** was rejected: the drop is silent by
nature, detection is a probe per round, and a retried fork can drop again.

**Demoting `dror-review` and `dror-repair` to sub-files of the loop** was
rejected: the carrier does not care where a file lives, so the move buys
nothing — and it costs the direct runs both skills' descriptions promise,
including the owed-at-cap hand-back, which is literally `/dror-review` typed
by the user.

## The decision

`dror-review-repair` drives step 1 and step 3 as **spawned agents given the
step files, always** — override or none — and never as `Skill` invocations.
The carrier's mechanics live once on the shelf, in
[`STEP-AGENT.md`](../../STEP-AGENT.md): the absolute file path, the dead
facts injection and its re-run, the override's travel, and the toplevel as
the first returned line. The drain's fold (ADR 0043) drives its steps by the
same shelf file.

## Consequences

The depth arithmetic is unchanged — loop at 1, step agents at 2, lenses and
refuters as leaves at 3 — so both fan-outs survive in manual and drain runs
alike, and the two invocation paths are now one carrier instead of a forked
path that works and a manual one that fails unpredictably. A direct
`/dror-review` or `/dror-repair` typed by the user stays a `Skill` fork: it
is invoked from the session, not from inside a fork, and every session on
record delivered that shape intact. Two fork-from-fork shapes remain and are
deliberately deferred until this one has run: `dror-adr-review-repair` still
invokes its steps as forks, and a direct `dror-implement-ticket` run still
invokes this loop as one — both carry the same hazard, and each drop so far
has been one level deeper than the shape that was just trusted.
