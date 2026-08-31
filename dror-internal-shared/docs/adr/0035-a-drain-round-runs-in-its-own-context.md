# A drain round runs in its own context

> **Seven facts are eight since ADR 0040**, which added the counted run.
>
> **Mechanism superseded by ADR 0036.** The boundary this ADR argues for is
> now provided by `dror-implement-ticket`'s own `context: fork` frontmatter, and
> the drain no longer spawns anything; every reason below still stands.

`dror-implement-adr` step 4 **spawns** `dror-implement-ticket` as a subagent
rather than invoking it in the drain's own context, and reads a listed set of
facts out of what that agent returns. Steps 5, 6 and 7 of the round stay in the
drain's context, because they are git and tracker questions the drain asks for
itself.

## The defect

A drain of any length consumed most of a session's context before it had worked
its list. Every `Skill` invocation injects that skill's file into the caller's
context, and the drain invoked, per ticket, `dror-implement-ticket`,
`dror-internal-project-facts`, `dror-prove` two or three times and
`dror-code-review-repair` once or twice — before a line of the ticket's own work,
its source reads, its edits and its several full-suite runs. None of it is ever
dropped, and every subsequent request re-sends all of it, so the cost of the
run grows with the square of the ticket count while the drain's actual state —
the work list, what remains of it, the round lines — stays small enough to fit
in a JSON file, which is where §3 already writes it.

`dror-code-review-repair` had already made this move for its own two steps, in
"Each step runs in its own context", giving the same reason at one layer down.
This ADR is that reason applied where the multiplier is the ticket count.

## What the drain actually needs from a ticket

Seven facts, all of which fit in a returned summary: the toplevel the run
happened in, the commit and whether it was pushed, the criteria proven of total
with the open boxes named, the loop's word with its grounds and any hand-back
command, the report tag where a settling loop ran, whether the ticket closed and
which condition held it open, and — where it stopped early — which stop and what
it wrote to the tree first. The drain needs none of the working context that
produced them. That asymmetry is the whole argument.

## Considered options

**Shrinking the skill files by cutting their rationale** was rejected. The drain's
own file loads once per run; halving it saves a low single-digit fraction of what
a multi-ticket run spends, and the prose proposed for cutting is the part that
makes a rule hold against a nearer competing rule — which is ADR 0034's entire
finding. Trading defect-prevention for a rounding error is the wrong side of that
trade. What *was* taken is a split rather than a cut: `dror-implement-ticket`'s
settling step moved whole to `SETTLING.md`, read only on the word **owed**, on
the pattern `dror-implement-adr`/`RESUME.md` already set. No sentence was lost,
and the beneficiary is the spawned ticket agent rather than the drain.

**Spawning `dror-show-tickets` at §2** was rejected. It runs once, and its table
is the sole input to the work list — "the only scan of the run", with nothing
later to correct it. Instructing the agent to return the table verbatim removes
the fidelity risk and with it the entire saving, which was one scan's `gh`
output. A boundary that buys nothing is a boundary that can only cost.

**A context budget the drain enforces on itself** was rejected: a run cannot read
how much context it has left, so the rule would be a judgement made exactly as
judgement degrades — the shape ADR 0034 already rejects in "leaving the
counter-instruction as prose". A deterministic round count was rejected as
arbitrary. What replaced both is a paragraph saying that stopping and re-invoking
is cheap, addressed to the user, who *can* see the window. The state file and
`RESUME.md` already made it true; nothing had said so.

**Leaving the arrangement alone and relying on compaction** was rejected because
compaction is what §3's state file was written to survive, not a mechanism to
plan around: it costs a re-attempted ticket each time, and it arrives without
warning in the middle of a round.

## Consequences

**The isolation prose in §0a became load-bearing where it was merely important.**
A spawned agent starts in the session's primary working directory — the user's
checkout — whatever the drain did, and now an entire ticket runs on the far side
of that. The mitigation is that the agent must return `git rev-parse
--show-toplevel` as the **first line** of its summary, and the drain reads that
line before anything else; a wrong answer is a §3a stop with nothing committed.
It is not proof, and the file says so: it converts a silent default into a claim
on the record, made by the only party that could see, and it fails at the first
ticket instead of at the merge. Step 5's git checks, still in the drain's own
context, are the second reading.

**Two stops moved from the ticket to the drain.** `dror-implement-ticket` offers
the user an override on a dirty tree and on an open blocker. A spawned agent
cannot ask, so it returns the question and §3a puts it. The cost is that an
override answered there resumes through a fresh run of the ticket rather than
continuing where the stopped one stood. Inside a drain this is close to free:
those two stops are the two a drain does not produce, since the tree is clean by
construction after each round's push and the topological sort works every blocker
before its dependents. A direct `dror-implement-ticket` run is untouched and
still asks for itself — DELEGATION.md forbids editing a sub-skill for its
caller's convenience, and this is that rule holding.

**§Present's fidelity now depends on a listed contract rather than on having
watched.** The drain used to be able to reconstruct a per-ticket line from the
run it had just seen; it cannot now. So the prompt enumerates the facts instead
of trusting the summary to carry them, and a narrative reply has to be asked
again. DELEGATION.md's "a sub-skill that ends on a bare done is defective" is
true and no help mid-drain, which is why the list exists.
