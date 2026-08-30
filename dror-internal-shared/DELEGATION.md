# A delegated skill is a step, and a step ends on a next action

The shared rule for one `dror-*` skill invoking another. It owns **what a
sub-skill's closing contract means to its caller**, and **the shape a delegating
step must have** so that meaning survives the invocation. One copy, owned by the
shelf and belonging to none of the callers. Read it whole at **authoring
time**, before writing or editing a step that invokes one — and never at run
time. A running skill already holds the fix this file prescribes, the named
action written into its step; reading the reasons behind it mid-run is a reading
rule, which is the shape this file says does not hold, and it cost every
context five kilobytes (ADR 0039). Do not restate it in the calling skill.

What is **not** here is *which* action any particular step ends on. That is the
caller's, and it is the whole point: the action has to be a real one, named in
the step that owns it. Nor is the sub-skill's own contract here — each skill
writes its own, and this file never edits it.

Why it is a shared document rather than a paragraph in each caller is ADR 0034.

## The failure this prevents

A sub-skill ends on a reply contract of its own — `dror-show-tickets` "nothing
else — no plan, no next steps", `dror-review` "STOPS", `dror-prove` and
`dror-implement-ticket` their summaries. Those contracts are correct: **invoked
on their own, those skills are right to end the turn there.**

Invoked as a step, the same text lands in the caller's context *after* the
caller's own instructions and reads as the nearest, hardest rule in force. So the
run stops at the sub-skill's boundary with the caller's work undone — a drain
that has worked no ticket, a loop that has repaired nothing, a ticket implemented
and never committed. This is the ordinary way these skills fail, not a rare one,
and three things make a given step likelier to be where it happens:

- **A deliverable's shape.** The sub-skill's last output is a table, a written
  report, a list of freshly ticked boxes. A finished artifact is a natural place
  to hand back.
- **A prohibition against guidance.** The sub-skill's closing text is phrased as
  a rule, while the caller's counter-instruction is phrased as advice and sits
  hundreds of lines earlier in context.
- **A hand-back command.** The sub-skill returns something addressed to the user
  — the `/dror-review` a loop returns on **owed** — which reads as a hand-off
  even where it is only a line for the caller's summary.

A step showing any of the three is named as such where it appears, by those
words, so the caller knows the place is a trap before it is standing in it.

**Both ways of invoking are covered, and one is worse.** Since ADR 0036 every
chain skill is forked by its own frontmatter, so the second way below is the
ordinary one and the first survives only in skills that fork nothing. Where the
sub-skill runs **in the caller's own context** — a `Skill` invocation — its contract is the
nearest instruction in force and the failure is at its strongest. Where the step
is **spawned as a subagent** and returns a result, the contract landed in the
subagent's context instead, but its closing sentences come back inside the result
and the caller's next turn can still take them for its own. Same rule, both ways:
the step ends on the caller's named action, not on the returned text.

Trying harder does not fix this. A reading rule — "read every such stop as 'this
step is finished'" — is still a judgement about whose contract governs, made at
exactly the moment the competing contract is loudest.

## The shape

**Every step that invokes another skill ends on a named next action**, so that
the next move is a tool call rather than a judgement. Write it into the step, in
this shape:

> Immediately after `<what the sub-skill returns>`, and in the same turn,
> `<the concrete call>`. That call is this step's last move.

The named action must be something the caller can *do*: a command to run, a file
to read, the next skill to invoke, a state file to write. "Continue at step 5" is
not one — it is the same judgement in different words. Where the step's next
action is genuinely conditional, name every branch and keep each concrete.

Two sentences earn their place beside it. Say **that the sub-skill's stop is its
own and not this run's**, so the contract is answered rather than ignored. And
where the step is one of the likely ones above, **say so** — name what makes it
look finished, since a caller that knows a place is a trap watches for it there.

## The sub-skill is never edited for this

The fix lives entirely in the caller. A sub-skill's stop is exactly right for the
user who invokes it directly, and every one of these skills is invoked directly —
that is what they are for. Weakening a contract to suit a caller trades a caller
that overruns for a direct run that will not stop, which is the worse failure:
the user asked for findings and gets an edited tree.

So the exemption is scoped to the caller and stated there. A caller may say "this
loop is what makes it a step"; no skill may say "ignore your contract when
someone calls you".

## The one thing a sub-skill owes its caller

Its closing summary has to carry what the caller's own summary must relay — the
verdict, the counts, the boxes that moved, the command it would have handed the
user. The caller relays that unchanged, so a chain's reader can tell which layer
said what. A sub-skill that ends on a bare "done" leaves the caller nothing to
carry, and that is a defect in the sub-skill.
