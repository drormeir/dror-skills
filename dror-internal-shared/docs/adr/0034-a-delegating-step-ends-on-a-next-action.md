# A delegating step ends on a next action, not on a reading rule

A `dror-*` skill that invokes another skill as a step must end that step on a
named, concrete next action — a command, a file to read, the next invocation —
and never on an instruction about how to read the sub-skill's closing contract.
The shared form of the rule, and the reasons above, live in
[`DELEGATION.md`](../../DELEGATION.md); this file records why it is a rule and
why it sits on the shelf.

`dror-implement-adr` stopped after `dror-show-tickets` printed its table, having
worked no ticket. The skill predicted that failure in as many words — "read every
such 'stop' as 'this step is finished', and return in the same turn to the
numbered step that invoked it… that is the ordinary way this skill fails, not a
rare one" — and the prediction did not prevent it. The counter-instruction was
hundreds of lines earlier in context than the prohibition that overrode it, and
it was phrased as guidance while `dror-show-tickets`' "nothing else — no plan, no
next steps, no offer" was phrased as a rule. The step ended on "show it, and
continue at §3 in the same turn", which names no call — "continue at" is the
same judgement in different words — so the next move was a judgement about whose
contract governed rather than a tool call.

The same shape was then found in three more places: the review step of
`dror-review-repair` and of `dror-adr-review-repair`, both ending on "It finds
and stops" — a reading rule that contains the word *stops*, sitting where
`dror-review`'s own "STOPS" lands — and the delegating steps of
`dror-implement-ticket`, which carried the turn-boundary sentence for
`dror-internal-project-facts` alone and nothing for `dror-prove` or
`dror-review-repair`, at any of the four steps that invoke them. One shape, in every skill that delegates, is a rule's worth
of evidence.

## Considered options

**Softening the sub-skills' contracts** — having `dror-show-tickets` or
`dror-review` end more gently — was rejected, and this is the load-bearing
rejection. Every one of these skills is invoked directly by the user; the
contract is what makes a direct run end where the user wants it. Trading a caller
that overruns for a direct review that will not stop swaps a wasted turn for an
edited tree.

**A "you are a step" flag in the invocation**, so a sub-skill could suppress its
own contract, was rejected for the same reason plus a second: it makes every
sub-skill's ending conditional on a caller it cannot verify, and a prompt
claiming to be a chain is exactly what a confused run produces.

**Leaving the counter-instruction as prose and writing it more emphatically** was
rejected because it had already been written emphatically. The defect is not
insufficient conviction; it is that a reading rule leaves the next move
undetermined at the moment a competing rule is loudest.

**A paragraph in each calling skill and no shared document** was rejected under
ADR 0015's and ADR 0026's arrangement: the fix was applied four times in one
sitting and the four copies already differed in what they warned about. What each
caller keeps is its own **named action**, which genuinely differs per step; the
principle behind it is one text. A rule is shared, an action is owned.

## Consequences

Every delegating step now carries a concrete last move, and a step that cannot
name one is a step whose next move nobody has decided — worth finding before a
run finds it.

The rule is cheap to check by eye and by grep: a step that invokes a skill and
whose closing paragraph names no call is a candidate. There is no build here, so
that is the test.

`CLAUDE.md` carries the short form for anyone editing this repo, since the defect
is introduced while writing a skill rather than while running one.
