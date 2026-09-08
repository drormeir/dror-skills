# Every hand-off rides the carrier, and the exemption list is empty

ADR 0044 moved a loop's steps off `Skill` forks. ADR 0055 finished the loops.
ADR 0056 took two chain steps and left two hand-offs standing, each with a
reason. This closes those two.

## The defect

The rule ADR 0043 ends on names no skill and no depth: *a `Skill` fork made from
inside a forked context can arrive without its arguments, and a spawned agent
given the skill file never has.* Two hand-offs still used the fork.

**The drain starting a ticket run.** `dror-implement-adr` step 4 invoked
`dror-implement-ticket`. Its arguments carry §0a's directory-override sentence,
the ticket number and the baseline — and the override is the only thing that puts
that run in the worktree at all, since a spawned or forked agent starts in the
session's primary directory whatever the drain did. Losing it means the whole
ticket — its reads, its edits, its suite runs — happens in the user's checkout.

**A hand-run ticket starting the review loop.** `dror-implement-ticket` step 3
invoked `dror-code-review-repair` where no override was present. Under a drain
the loop already folds (ADR 0043); only the direct path forked.

## Considered options

**Keeping both, as ADR 0056 recorded them**, was rejected. Each reason was a
reason to go *last*, not a reason to stay: the drain's edge is guarded by the
toplevel check, so its failure is loud rather than silent, and the ticket's edge
is the shallowest shape in the chain. Neither says the drop will not happen.

**Keeping the drain's edge alone**, on the strength of that guard, was rejected
for what the guard actually buys: it catches a ticket that already ran in the
wrong tree. The work is done and thrown away. Catching it is better than
believing it and worse than not doing it.

## The decision

Both hand-offs ride the carrier. `dror-implement-adr` spawns
`dror-implement-ticket`; `dror-implement-ticket` spawns
`dror-code-review-repair` where it does not fold it. `STEP-AGENT.md` owns the
mechanics, as everywhere else.

**`carrier-check.sh`'s exemption list is now empty**, and that is the state to
keep it in. An entry there is a deliberate exception and carries the decision
granting it beside it.

**For the drain this is a return, not a change.** ADR 0035 built step 4 as a
spawn. ADR 0036 replaced it with a `Skill` fork because the ticket skill's own
`context: fork` supplied the same boundary for nothing — a fair trade on what
was known then. ADRs 0043 and 0044 then found the fork carrier drops arguments.
The boundary was never the doubtful half; the delivery was, and an agent given
the file provides both.

## Consequences

Every skill-to-skill hand-off in this repo goes through one carrier. A defect
found in one is a defect in the shape, and `carrier-check.sh` fails any new
skill written the old way on its first review.

**The drain's toplevel check stays** and is not made redundant. It guards
against more than a lost override — a step agent that resolved the path wrongly
for any reason still reports where it stood, and §3a still stops on it.

ADR 0056's consequences paragraph named these two as knowingly left; it is
superseded here, and carries a note saying so.

Four files gained prose an agent executes — `dror-implement-adr`,
`dror-implement-ticket`, `carrier-check.sh`'s header and this record — and none
has been reviewed. They join the debt ADR 0055 and ADR 0056 already owe.
