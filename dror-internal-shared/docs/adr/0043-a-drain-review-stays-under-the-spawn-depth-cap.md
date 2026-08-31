# A drain's review stays under the spawn-depth cap

The harness caps subagent nesting at **three** levels. The cap is the
harness's, fixed and not configurable (Claude Code lowered it from five in
v2.1.219), and this file is the only place in this repo that writes the
numeral. Two things happen at the cap: an agent there receives no spawn tool,
which is documented; and — undocumented — a `context: fork` skill invoked
*from* an agent one level below the cap is delivered **without its
`ARGUMENTS:` block**. The caller's Skill call carries the arguments; the
fork's first message is the bare rendered skill file. Nothing errors. The
nearest public report is claude-code#82240.

## The defect

Under the drain the chain nests `dror-implement-adr` (depth 0) →
`dror-implement-ticket` (1) → `dror-code-review-repair` (2) → `dror-code-review` (3) —
exactly at the cap. Session `fa0c6093` (geo_sense, 2026-08-30, the second such
run) has the whole failure on the record: the review-repair fork called `Skill
dror-code-review` three times, each with 1.7–2.8 KB of arguments carrying §0a's
worktree override; all three forks received the rendered file and nothing
else, ran their git commands where they stood — the user's checkout — and
reported its clean tree as an empty diff. The run recovered by driving review
and repair through plain agents given the skill files and `git -C`, which
honoured the override but ran each review's lens fan-out and refutations
inside one context, since an agent at the cap cannot spawn.

Depths 1 and 2 received their arguments intact in the same session, which is
why ADR 0036's probe passed and its shape is not the bug: a direct ticket run
puts the review at depth 2, and every manual invocation works as that ADR
says. Only the drain adds the level that crosses the cap.

The depth arithmetic did not hold. On 2026-08-31, in this repo's own tree, a
`dror-code-review-repair` invoked directly with the override in its arguments —
the shape whose forks `fa0c6093` saw arrive intact — called `Skill
dror-code-review` and the fork arrived bare, one level shallower than the drop
described above; a drain-free run earlier the same day dropped the same way.
The sessions disagree about the depth at which a fork loses its arguments, so
no level count is trusted here. What every run agrees on is narrower: a
`Skill` fork made from inside a forked context can arrive without its
arguments, and a spawned agent given the skill file and the sentence never
has.

## Considered options

**Unforking `dror-code-review-repair` outright** — dropping its `context: fork` —
was rejected: the loop lands at depth 2 only under the drain, and removing the
fork would spend ADR 0036's isolation on every direct run to fix a case
direct runs do not have.

**Flattening the drain** — `dror-implement-adr` running tickets in its own
context — was rejected as ADR 0035's rejected shape returning: a drain of any
length would carry every ticket's run in one window.

**Inlining the review into the loop** — a drain-marked `dror-code-review-repair`
following `dror-code-review`'s file in its own context and spawning the lenses and
refuters itself — was implemented first and rejected on review: it keeps the
review's fan-out but loses `dror-code-repair`'s (the repair agent sits at the cap),
it puts a second copy of the review's procedure in play, and it pours every
lens return and refuter verdict into the loop's context when a far smaller
thing can move instead.

**Waiting on the upstream fix** was rejected as the fix: the argument drop may
be a bug, but the cap itself is by design, and an agent at the cap still could
not fan out.

## The decision

Move the fold one level up, to the smallest thing that can be folded: **under
a directory override, `dror-implement-ticket` follows `dror-code-review-repair`'s
file in its own context instead of invoking it.** The override — §0a's
sentence, present in a drain-run ticket's arguments and nowhere else — is the
key; a direct ticket run has none and invokes the loop as the fork ADR 0036
made it.

Folded, the chain under the drain is `dror-implement-adr` (0) →
`dror-implement-ticket` (1, now carrying the loop) → `dror-code-review` /
`dror-code-repair` (2) → lenses, refuters, test-writers (3, leaves). Each step
carries its brief whole, and both fan-outs survive. The loop's file is still
followed whole — it owns the rounds, the tag, the floor and the judgement;
what changes is only whose window its few kept lines sit in.

The sub-skills take the override as an argument of their own:
`dror-code-review` and `dror-code-repair` each accept the §0a sentence, run every git
command with `-C` that path and keep every read and write under it. §0a's
sentence carries a forwarding clause, so the override reaches them by
instruction rather than by a run's initiative — which is how it travelled in
`fa0c6093`.

The shallower drop widens the rule by one clause: **wherever the loop holds
the override — folded under the drain, or invoked directly with the sentence
in its arguments — its steps are driven as spawned agents given
`dror-code-review`'s and `dror-code-repair`'s files and the sentence, not as `Skill`
forks.** The agent is the one carrier that has never dropped the sentence,
and an agent one level down still spawns its leaves, so both fan-outs keep
theirs. A run without the override kept the forks ADR 0036 made — until
ADR 0044 dropped that last clause: the loop's steps ride agents always, and
the carrier's mechanics moved to the shelf's `STEP-AGENT.md`.

## Consequences

**The ticket run's context grows by the loop, only under a drain.** The
loop's kept state is deliberately tiny — per-round lines, report paths, one
word — so the cost is its file once plus a few lines per round, bounded by the
chain's three-round cap and the settling continuation. The loop-fork's
isolation is spent only where the ticket run is itself a disposable fork.

**`dror-code-review` and `dror-code-repair` gain a directory override and nothing
else.** No folded procedure inside them, no second copy of any file; a direct
run of either is unchanged.

**`dror-adr-review-repair` is untouched.** It has the same nesting shape but
no drain above it puts it at depth 2, so its forks keep their arguments.

**The chain gains no depth.** Any future skill that would fork from depth 2
inherits this problem, and the fold here — move the smallest context one
level up, keyed on the override — is the pattern to copy.
