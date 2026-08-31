# The step agent: driving a dror skill without a `Skill` fork

The shared carrier for a `dror-*` run that must invoke another dror skill and
cannot trust a `Skill` fork to deliver its arguments. It owns **how the agent
is spawned and what its prompt must open with** — the duties below, in one
copy, owned by the shelf and belonging to none of the driving skills. A skill
that drives a step this way points here and does not restate these duties.

What is **not** here: when the carrier applies — each driving skill's own file
says where and why, and ADR 0043 and ADR 0044 hold the reasons; what the step
is asked to do and what it must return past the first line — the driver's
prompt and return contract, written where the step is driven; the directory
override's duties ([`DIRECTORY-OVERRIDE.md`](DIRECTORY-OVERRIDE.md) owns
those).

## Why an agent and not a fork

A `context: fork` skill invoked from inside a forked context can arrive
without its `ARGUMENTS:` block — silently, and at depths no level count has
predicted twice the same way. A spawned agent given the skill's file and its
brief has never arrived bare. ADR 0043 carries the record, ADR 0044 the
decision; a run invoked from the session itself is not inside a fork, and a
direct `Skill` invocation there is untouched by any of this.

## The duties

- **Hand the file as an absolute path, never pasted** (ADR 0038). The step's
  `SKILL.md` is a sibling of the driver's own directory; resolve it to an
  absolute path and open the brief with: "Read `<absolute path>` and follow
  it exactly, as the run it describes."
- **The frontmatter is text to the agent.** Its `context: fork`,
  `background`, `allowed-tools` and description execute nothing when the file
  is read rather than invoked; tell the agent to skip past it and follow the
  body.
- **The facts injection is dead, so the agent runs the stamp itself.** The
  `!`-line under a skill's "The project facts" renders only for a `Skill`
  invocation. Tell the agent to run that script itself — from `<path>` where
  a directory override names one, from the session's checkout otherwise —
  and to treat what it prints, `MISS` included, as the injected facts.
- **A directory override travels verbatim**, at the top of the brief before
  anything else, and the agent carries it into every agent *it* spawns —
  DIRECTORY-OVERRIDE.md's duties, which the step's own file already points
  at.
- **The first line of the agent's return is its toplevel** — `git rev-parse
  --show-toplevel` from where its commands ran — and the driver reads that
  line before any other: a wrong toplevel means the step worked the wrong
  tree, and none of its other facts count.
- **The brief is everything.** The driver's task text and its return
  contract go into the prompt whole, each time — a prompt is all a fresh
  agent has, and nothing from the driver's context reaches it any other way.
