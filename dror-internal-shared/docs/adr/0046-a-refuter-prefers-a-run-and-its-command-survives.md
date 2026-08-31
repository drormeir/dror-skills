# A refuter prefers a run, and its command survives into the report

Refuting said a refuter "may run code", and prescribed an executable route only
for the `cover` kind. Every other kind was in practice settled by reading — the
stronger evidence, a staged execution of the finding's own failure scenario,
was allowed but never asked for. And where a refuter did run something, the
command died with the agent: ADR 0017 keeps the refuter's route out of the
report, `dror-code-repair`'s step 1 rediscovered from scratch how to make each bug
red, and the rediscovery was of something one agent had already held.

Two decisions, one arc:

**A refuter stages what is stageable.** Where the failure scenario can be
staged — a snippet calling the code with the scenario's own input, a narrow
test invocation — the refuter stages it in a scratchpad copy and lets the
output decide, pasting it as the evidence (ADR 0006). Reading alone settles
only what no run can reach, and the return says which it was. The copy is the
`cover` route's own rule for the same reason: refuters run in parallel, and a
review changes no line of code.

**The deciding command is part of what a repair needs to act.** A refuter whose
verdict came from an execution returns the exact command, phrased to run from
the live repo's root — the copy it ran in is gone by repair time — and the
report writes it into the finding as a `repro:` line, verbatim. This amends ADR 0017's
boundary without moving it: the route — files traced, call sites checked,
reasoning retold — stays out, because a repair redoes that against the live
tree; the one command that shows the defect is not route, it is the finding's
failure scenario made runnable. `dror-code-repair` replays it before writing
anything: replay is cheaper than rediscovery, and a repro that no longer fails
is evidence the tree moved since the review. The test is still written — a
repro command is a proof, not a regression net.

## Considered options

Keeping the refuter's full transcript was rejected — that is exactly what ADR
0017 exists to keep out, and a stale account of a trace is worse than none.

Requiring execution for every finding was rejected: some scenarios cannot be
staged short of real GUI or thread timing, and a refuter forced to stage the
unstageable either burns its budget or fakes the attempt.

## Consequences

A finding is still about fifteen lines; `repro:` is one of them, and only where
an execution decided.

Refuter verdicts on `logic` and `domain` findings rest on runs instead of
readings wherever the scenario allows, which is the direction every measured
false positive in the log argues.
