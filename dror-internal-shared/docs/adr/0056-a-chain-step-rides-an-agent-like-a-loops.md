# A chain step rides an agent, like a loop's

> **The two deferrals below are closed by ADR 0059.** Both hand-offs this
> record left standing — the drain's ticket run and a hand-run ticket's review
> loop — now ride the carrier, and `carrier-check.sh` exempts nothing. Every
> reason below still stands; only the Consequences section's "left knowingly"
> is superseded.

ADR 0044 moved a loop's steps off `Skill` forks; ADR 0055 finished that for the
two loops it had deferred. Both were scoped to loops. A sweep of every
skill-to-skill invocation in the repo found the same shape in two places that
are not loops, and neither had been named by any decision.

## The defect

The rule ADR 0043 ends on is not about loops: *"a `Skill` fork made from inside
a forked context can arrive without its arguments, and a spawned agent given
the skill file and the sentence never has."* Two chain sites break it.

**The drain's ADR check.** `dror-implement-adr` invokes `dror-adr-review` before
its first ticket (ADR 0051), forked from forked, and justified the fork in its
own text: *"The nesting is under the cap. `dror-implement-adr` (0) →
`dror-adr-review` (1) → its lenses and refuters (2), which is a level shallower
than the ticket's own chain and needs no fold (ADR 0043)."* That is the depth
arithmetic ADR 0043 refuses — *"no level count is trusted here"* — and the first
option ADR 0044 lists as rejected, *"the condition cannot be computed."* The
passage cites 0043 for a conclusion 0043 forbids, and it is newer than both.

**The ticket's prove step.** `dror-implement-ticket` invokes `dror-prove`, forked
from forked. Its arguments carry the ticket number and, under a drain, §0a's
sentence. A fork that loses everything stops for want of a ticket; a fork that
keeps the ticket and loses the sentence writes tests into the session's
checkout. Nothing was watching for that: `dror-implement-ticket` contained no
`rev-parse` at all, so unlike the drain it had no way to learn that a step ran
in the wrong tree.

Underneath both, a third fault. Neither `dror-adr-review` nor `dror-prove`
mentioned the directory override anywhere, though `dror-implement-adr` already
said it passed the review "§0a's sentence". A sentence handed to a file that has
never heard of it obliges nothing.

## Considered options

**Folding either step** — the caller following the step's file in its own
context, as ADR 0043 did for the loop — was rejected: a fold buys a level, and
neither site is short of levels. `dror-adr-review` fans out one below the agent
to leaves; `dror-prove` spawns nothing at all. Paying a fold's cost (the step's
whole file in the caller's window) for a level nobody needs is the wrong trade.

**Keeping the forks and adding only the toplevel check** was rejected: the
check turns a silent wrong answer into a loud one, which is worth having, but
it treats the symptom while leaving the carrier that causes it.

**Closing `dror-implement-ticket`'s remaining fork of `dror-code-review-repair`
in the same edit** was rejected as out of scope. ADR 0044 deferred it
deliberately, it already folds under an override, and it deserves its own look
rather than being swept in behind two unrelated sites.

## The decision

`dror-implement-adr` drives its ADR check, and `dror-implement-ticket` drives
its prove step, as **spawned agents given the step files**, by
[`STEP-AGENT.md`](../../STEP-AGENT.md) — the same carrier the three loops use.
The override sentence takes the top of each brief where the run holds one.

Each driver **reads the agent's returned toplevel before anything else it
says.** For the drain this joins the condition it already had for a ticket run,
in §3a's stop list, now widened to cover the check. For
`dror-implement-ticket` it is new: a prove agent returning a toplevel that is
not this run's tree ends the run, with nothing ticked.

`dror-adr-review` and `dror-prove` each state their own half of the override
contract and point at `DIRECTORY-OVERRIDE.md` for the rest, as
`dror-code-review` and `dror-code-repair` already do.

## Consequences

Two `Skill` forks made from inside a fork remain, and both are left knowingly.

`dror-implement-adr` still invokes `dror-implement-ticket` as a fork. It is the
one such edge with a guard already in place: the drain requires the ticket's
first returned line to be its toplevel and stops on a tree that is not the
worktree (§3a), so a lost override is caught rather than believed. Its
arguments are also the smallest of any edge here — a sentence, a number, a
baseline. Moving it to the carrier is the obvious next step and is not taken
today only because it is the drain's own spawn shape, settled by ADR 0035, and
that decision deserves reading before it is changed.

A direct `dror-implement-ticket` run still invokes `dror-code-review-repair` as
a fork, as ADR 0044 deferred and ADR 0055 restated. Under a drain it folds;
only the direct path forks, and that path is the shallowest shape in the chain.

The depth arithmetic in this repo is now cited in one direction only — as a
check that a chain has room, never as a reason to keep a fork. Where a level
count appears in a skill's text it should be read that way, and the passage
removed from `dror-implement-adr` is the example of the other reading.

Five files gained prose an agent executes — `dror-implement-adr`,
`dror-implement-ticket` and its `SETTLING.md`, `dror-adr-review`, `dror-prove` —
and none has been reviewed since. All five owe a round.

`SETTLING.md` was found by the check ADR 0057 adds, not by reading: its
invocation of `dror-prove` survived the edit to `dror-implement-ticket`'s own
step 2, because a companion file is executed prose that nobody had thought to
grep.
