# Which skills the model may invoke

`dror-review-retrospective` and `dror-implement-adr` set
`disable-model-invocation: true`: they are expensive, they are started
deliberately, and being user-invoked costs no always-loaded description.
`dror-internal-shared` sets it for a different reason — it is a shelf and not a
procedure, and the flag is what keeps a legitimate skill directory out of the
always-loaded list (ADR 0015). The rest stay model-invocable, so the user can
ask for them in plain words.

**The flag ends where the chain begins.** A skill that another skill's run
invokes must be model-invocable to be reachable at all (ADR 0010), so being
expensive is not on its own enough to earn the flag:

- `dror-implement-ticket` used to set it and no longer does: it is what
  `dror-implement-adr` runs per ticket.
- `dror-review`, `dror-repair` and `dror-prove` may not set it either, whatever
  they cost: `dror-implement-ticket` invokes all three, in that order, up to
  three times each. `dror-review` is the expensive one and the temptation, and
  the flag on it would break the loop rather than make it cheaper.
- `dror-internal-project-facts` may not set it for the same reason, and it is the case
  that makes the rule obvious: every skill in the chain invokes it first.

So the flag marks a skill **nothing else invokes**, and that is the test to
apply before adding it. Checking is one command:
`grep -l disable-model-invocation ~/.claude/skills/*/SKILL.md` against the
skills each `SKILL.md` names.

## Consequences

A skill with `disable-model-invocation` does not appear in the model's skill
list, so nothing can reach it by inference — which is why the flag cannot be
used to make a chained skill cheaper, and why the roster above is short.

It is therefore **not** what keeps `dror-review` from starting `dror-repair`:
both are model-invocable and each could name the other. What keeps them apart is
that the review's own file names no other skill (ADR 0001), and that is where
the two-runs shape is enforced.

For `dror-repair` the read-out is the reverse of a cost: a typed skill command
is expanded into the transcript while a model-invoked one shows a single line,
so a user who wants the expansion types it. That is a preference about
transcripts, not a reason for the flag.
