# Every loop rides the step-agent carrier

ADR 0044 moved `dror-code-review-repair`'s steps off `Skill` forks and onto
spawned agents, and deferred two shapes — `dror-adr-review-repair`, and a
direct `dror-implement-ticket` run — "until this one has run". It has run: the
code loop has driven its steps by the shelf's carrier on every run since
2026-08-31, in this repo and in the drain's fold, with no bare arrival.

A third shape was never named either way. `dror-skill-review-repair` was
created at `1d09c74`, three hours after ADR 0044 landed at `44c6cc2` on the
same day, in the shape that ADR had just rejected, and the deferral list was
not revisited. Its silence is chronological, not an exemption.

## The defect

Both remaining loops fork their own steps from inside a forked run — the shape
ADR 0043 recorded losing its arguments at depths no level count predicts twice
the same way. Neither loop is protected by anything but luck, and the map said
one of them was not a candidate at all.

The two loops differ from the code loop in what a drop costs, and that is why
the deferral was reasonable while it lasted. The code loop's arguments name a
scope; a bare fork there reviewed the session's checkout in good faith and
reported a clean tree as convergence — a silent wrong answer. These two carry
the target itself, so a bare fork has nothing to resolve, stops, and is caught
by each loop's own broken-review branch. The cost is a lost round, not a false
one. That is a smaller harm, not an absent one, and it is a reason to have
gone second rather than a reason to stay behind.

## Considered options

**Leaving both deferred and naming the third in ADR 0044's list** was
rejected: the deferral was conditional on the first carrier being proved, and
proving it was the whole point of going in stages. A condition that has been
met is not a standing exemption, and rewriting an ADR's list to admit a shape
its author never saw would record the wrong reason.

**Migrating `dror-skill-review-repair` alone** was rejected: it and
`dror-adr-review-repair` are near-copies, down to the section headings. One
migration touching both is one piece of work and one review; splitting them
leaves two files that read the same and behave differently, which is the drift
this repo spends its reviews finding.

**Trusting the loud failure** — keeping the fork because these two stop rather
than lie — was rejected: it makes the carrier a per-loop judgement about blast
radius, which is exactly the depth arithmetic ADR 0044 refused. The carrier is
cheaper to reason about when it is the same everywhere.

## The decision

`dror-skill-review-repair` and `dror-adr-review-repair` drive step 1 and step 3
as **spawned agents given the step files**, by
[`STEP-AGENT.md`](../../STEP-AGENT.md), on the same terms as
`dror-code-review-repair`: the absolute file path, the frontmatter as text, the
dead facts injection re-run by the agent, the override's travel, and the
toplevel as the first returned line. Each loop's own file says so where its
steps are driven; the mechanics stay on the shelf in one copy.

A direct `/dror-skill-review`, `/dror-skill-repair`, `/dror-adr-review` or
`/dror-adr-repair` typed by the user stays a `Skill` fork, for ADR 0044's
reason: it is invoked from the session, not from inside a fork.

## Consequences

The depth arithmetic is the code loop's, unchanged — loop at 1, step agents at
2, lenses and refuters as leaves at 3 — so both fan-outs survive. All three
review-repair loops now carry one carrier, so a defect found in one is a
defect in the shape rather than in a single file's wording.

One deferred shape remains, and it is the last: a direct `dror-implement-ticket`
run still invokes `dror-code-review-repair` as a fork. It is untouched here
because it is a different question — a chain skill invoking a loop, not a loop
driving its own steps — and because the drain's folded path already drives the
carrier under a directory override.

The two migrated files are prose an agent executes, and this edit rewrote the
passages that name the carrier in each. Both owe a review round before they are
trusted; neither has had one.
