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

There is no build here; grep is the test suite. After renaming anything, grep
the repo for the old name.
