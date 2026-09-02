# The lens fan-out: models, boundaries, what comes back, and merging

The rules every `dror-*` review obeys once it has chosen its lenses and is about
to launch them. They live here, owned by the shelf and belonging to none of the
three reviews: one copy, so sharpening a rule sharpens every run that obeys it.
Read this file whole before launching a batch; do not restate it in the calling
skill.

What is **not** here is anything about **which** lenses a review has, what each
one reads, or how its findings are keyed. The pool, the per-lens read
assignments, the grouping key a merge uses and the closed kind vocabulary all
belong to the review that owns them, and each states its own.

## The models

**Lenses run on the cheap model, refuters on the strong one.** Pass
`model: "sonnet"` to every lens agent and leave the refuters on the session's
own. Spend the tokens where the judgement is: a weak lens proposal costs one
refuter, a wrong refuter decision ships a false positive or buries a real
finding.

## The read boundary

**Cap what a lens reads, on its own axis.** Each review says what its own lenses
are given; what holds for all of them is the escape. A lens that cannot reach a
verdict inside its boundary **says so and returns the question rather than
widening** — reading a subsystem to settle one sentence is the refuter's budget
to spend, on one finding, not every lens's on all of them.

## What came back

**Check that every lens returned, before merging.** A merge opens on the
*returned* findings, and nothing before it counts them against what was
launched — so a lens whose result never arrives leaves no trace of itself, and
its area reads exactly like one that came back clean. Before merging, list the
agents the batch launched and confirm each of them returned. A lens that
launched and whose output did not arrive is an area nobody looked at: say so in
the report like any other that was not run, and say there that this run's
findings are that lens short. Keep its name for `runs.tsv`, which has a column
for exactly this and for neither of the other two states.

**A lens is asked once, and a result that did not arrive is lost.** Do not
message the agent again, do not launch the lens a second time, and do not re-run
the batch to fill the gap — a lens asked twice does its pass twice, and a run
that collects a second time assembles a second set of findings, numbered
independently, for one round. That is how one round comes to write two reports
and one repair comes to hold a worklist its report no longer matches. Reading
the missing agent's own transcript is not a second ask and is allowed; asking is
what costs.

`refutations.tsv` is no help here — a run writes it after the refuters, so at the
moment output goes missing it holds nothing of that run's.

## The merge

**Two lenses reading adjacent things report one defect twice.** Group the
returned findings before anything is refuted: findings that name the same defect
become one, keeping the clearest statement and noting every lens that raised it.
One defect, one finding, whatever found it.

**What counts as the same defect is the review's own question**, since the key
it groups by is the shape of what it reviews — a `file:line` and a failure
scenario, a document line and the claim about it. Each review states its key,
and each states which pairs of its own kinds are **not** duplicates: two
readings of one disagreement stay separate through the merge and let the
refutations decide, because collapsing them here would pick the winner before
anyone looked.
