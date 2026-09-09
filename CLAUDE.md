# Editing this repo

Every file here is read by an agent mid-run, so an edit is a behaviour change.
[`STRUCTURE.md`](STRUCTURE.md) is the human tour,
[`dror-internal-shared/DROR-SKILLS.md`](dror-internal-shared/DROR-SKILLS.md) the
agent-facing map, [`dror-internal-shared/CONTEXT.md`](dror-internal-shared/CONTEXT.md)
the glossary, and [`dror-internal-shared/docs/adr/`](dror-internal-shared/docs/adr/)
the reasons. When two documents disagree, the one that declares ownership of the
meaning wins and the other copy is the bug.

Rules — each exists because its violation already produced a defect here:

- A skill's `description:` frontmatter is the single source of its description.
  STRUCTURE.md quotes it verbatim minus the trigger clause, so a description
  edit updates that row in the same commit.
- A tunable — a cap, a floor, a count — is a numeral only in the file that
  enforces it. Everywhere else writes "the cap", or points.
- A closed vocabulary is defined inside the text that is pasted into the prompt
  of the agent that mints its values (a lens preamble, a refuter brief). The
  orchestrating file points at it and never restates it.
- A step that invokes another skill ends on a named next action — a command, a
  file to read, the next invocation — never on a rule about how to read the
  sub-skill's closing contract. The sub-skill's own stop stays untouched, so a
  direct run still ends there. The shape is
  [`DELEGATION.md`](dror-internal-shared/DELEGATION.md); the reasons are ADR 0034.
- A shared rule lives once, on the shelf (`dror-internal-shared/`), under a
  header saying what the file owns and what it deliberately does not; a calling
  skill points and never restates.
- A skill the user runs to work the chain carries `context: fork` and
  `background: false`, opens with the facts injection line, and takes
  everything it needs as arguments — nothing from the conversation reaches it
  (ADR 0036, ADR 0037). An agent it spawns is given paths, never pasted text
  (ADR 0038).
- A skill starts another skill by **spawning an agent given that skill's file**,
  never with a `Skill` invocation: a fork made from inside a fork can arrive
  with no arguments at all, silently, at no depth that can be predicted. The
  carrier is [`STEP-AGENT.md`](dror-internal-shared/STEP-AGENT.md); the reasons
  are ADR 0043 and ADR 0044, and ADR 0059 is where the last exception closed. A
  direct invocation typed by the user is not inside a fork and is untouched by
  this.

There is no build here; grep is the test suite. After renaming anything, grep
the repo for the old name.

Three of the rules above are decided by script rather than by reading, and a
skill review runs all three before its lenses:
`dror-internal-shared/skill-rules-check.sh` for Anthropic's published rules,
`dror-internal-shared/carrier-check.sh` for the carrier, and
`dror-internal-shared/stamp-check.sh` for the run stamp — a loop mints its tag
before its first round, and a store it writes names that tag. Each takes one
skill directory and prints `BREACH:` lines or `CLEAN`. Run them on a skill you
have edited — they are seconds, and they decide what no lens should be asked to.
