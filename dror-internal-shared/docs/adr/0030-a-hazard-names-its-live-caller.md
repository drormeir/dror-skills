# A hazard names the live caller that reaches it

Every lens may report latent hazards. From now on a hazard also names the path a
running program takes into the fragile code *today*, as a caller and not as a
possibility, and dies in the lens where every path in is already clamped, guarded
upstream, or has no caller at all.

The measurement is what prompted it. Over nineteen days and 747 logged findings,
hazards were refuted at **79%** against 40% for bugs and 21% for gaps in cover,
and the share held in every lens that raises them: 90% in `logic`, 88% in
`state`, 16 of 16 in `clone`. Set hazards aside and the per-lens rates collapse
into one band — 22% to 44% — which says the imprecision was never a lens's.
`clone` in particular read as the worst code lens at 70% refuted, and is at 36%
with its hazards removed.

`dror-review-retrospective` had asked which *lens* is imprecise, so that is what
its earlier runs answered. Nothing asked which *kind* was, and the kind was the
answer.

**What is not measured is that a high kill rate is a fault**, and it may not be.
A hazard is code correct today and fragile tomorrow — a claim about a future that
a refuter, judging the present, will often and rightly kill. Kills are what
propose-then-refute is *for* (ADR 0003), no one has ever fixed the right rate,
and nothing in any of the three logs records a bug that no lens raised. So this
gate spends recall to buy precision, against 36 surviving hazards whose worth is
not in the numbers either.

It is therefore a **standing trial**, written into the lens file as one. Each run
of `dror-review-retrospective` now reports what became of hazards since — raised,
survived, survivors' rate — and says plainly whether the survivors fell with the
kills. A gate that cut both is a gate to argue for removing.

## Considered options

**Narrowing the lenses that kill most** — `state`, `logic`, `clone` — was the
reading the retrospective's own question invited, and it was wrong: those lenses
differ by their hazard *share*, not by their precision, so narrowing them would
have cost bugs and gaps in cover to fix something neither produced.

**Dropping the `clone` lens** was proposed on its numbers: nine survivors across
29 selections, 0.31 per run. Refuted by reading the nine — pattern-completeness
bugs that no other lens hunts, including one Browse-gate defect found in two
separate dialogs. Its noise was entirely hazards, which this gate takes instead.

**Leaving it alone and reporting the rate each retrospective** was the safe
option, and remains available: this gate can be removed by deleting one
paragraph. It was rejected only because the rate had already been reported twice
with nothing acting on it.

## Consequences

The `hazard` kind stays. What changes is what qualifies as one, and a hazard in
a seam written for a caller that lands next week — exactly the case the
provenance rule ("this diff created it or made it worse") is aimed at — is now
lost unless the same ticket names the caller, which the lens file says counts as
live.

`dror-review-retrospective` gains two obligations: split refuted-over-total by
`kind` before ranking any lens on it, since a lens ranked on a pooled rate is
ranked on its mix; and report this trial's outcome every run.

The measurement also exposed what the log cannot say. Its `summary` column holds
what a finding *claimed*, in under eighty characters; the ground it died on is in
the report's `## Refuted` section and nowhere else, and only about ten of 139
refuted hazards named their ground in the summary by chance. So the log gains a
`report` column carrying the path that run wrote its report to. It is a pointer
and not a history — reports are overwritten by the next run on the same ticket or
ADR (ADR 0002) — so it reaches the current report for each and nothing older,
which is still where a retrospective's freshest evidence sits.
