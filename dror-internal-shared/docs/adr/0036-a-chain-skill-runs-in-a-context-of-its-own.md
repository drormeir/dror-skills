# A chain skill runs in a context of its own

Every skill in the chain and above it — `dror-implement-ticket`,
`dror-implement-adr`, `dror-code-review-repair`, `dror-adr-review-repair`,
`dror-prove`, `dror-code-review`, `dror-code-repair`, `dror-adr-review`, `dror-adr-repair`
— carries `context: fork` and `background: false` in its frontmatter. Invoking
one, by hand or from another skill, runs it in an agent of its own: what
reaches it is its own file, the facts its first line injects (ADR 0037) and its
arguments; what comes back is its closing summary. `dror-show-tickets` and
`dror-internal-project-facts` are not forked — the first returns a table the
user reads, the second is a step whose result the caller carries.

## The defect

A skill invoked mid-session inherited the whole session: every earlier reply,
every file read, every other skill loaded, resent on every one of the run's
several hundred turns. The skills were written not to need any of it, and got
all of it anyway. ADR 0035 had already moved one boundary — the drain's ticket —
by having the caller spawn an agent and tell it to invoke the skill; that fixed
the drain and left a direct `/dror-implement-ticket` paying for whatever the
session held before it, which is the ordinary way these skills are run.

The forked skill's prompt is the rendered file, so its arguments arrive
appended as `ARGUMENTS:` and the injected facts arrive inside it. A probe
confirmed the two things the chain depends on: a forked skill can invoke
another forked skill and receive its result, and a fork starts in the session's
primary working directory — the fact §0a of the drain already guards.

## Considered options

**Leaving the spawn in the callers** (ADR 0035's shape) was rejected because it
protects only the callers. A user's direct run is the common one, and a caller
spawning an agent to invoke a skill that now forks itself would be two
boundaries where one does the work.

**`/clear` before every run** was kept as a habit and rejected as the fix: it
depends on the user remembering, and the drain's own sub-invocations cannot
`/clear` anything. STRUCTURE.md says where it still helps.

**A `claude -p` wrapper** was kept for unattended runs and rejected as the fix
for the same reason as `/clear`: it is outside the skills.

## Consequences

**A forked run cannot ask.** `dror-implement-ticket`'s two overridable stops —
the dirty tree and the open blocker — return the question as the result, and the
override arrives as an argument on the next invocation. ADR 0035 had moved those
two stops into the drain; now they behave the same way in a direct run, which
costs a re-invocation where a direct run used to continue. `dror-prove` and
`dror-implement-ticket` no longer "ask for" a missing ticket number; they say so
and stop.

**Nothing said in a conversation reaches a run.** `dror-code-repair` used to take
"bugs this conversation named"; it now takes a report path or a findings file
path, and a bug named aloud is written down before the skill is invoked.
`dror-code-review-repair`'s focus and scope, and every other thing a caller used to
rely on being in context, travel as arguments.

**The loops and the drain no longer spawn.** Their steps are plain invocations;
the isolation those files described is now the sub-skill's frontmatter, and
each file says so in place of its spawn section.

**Compaction is less likely and less damaging.** A fresh context fills far later
than one carrying a session, and the truncation compaction applies to loaded
skills — the first five thousand tokens of each — lands on a run that has
usually finished.
