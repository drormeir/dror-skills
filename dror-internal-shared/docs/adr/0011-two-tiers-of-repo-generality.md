# Two tiers of repo-generality, and each skill says which it is in

The set used to claim both things at once: `dror-internal-project-facts` promised "works
in any repo and any language" while `dror-prove`, `dror-code-repair` and
`dror-show-tickets` named one project's paths (`docs/adr/<NNNN>-*.md`,
`docs/agents/issue-tracker.md`). A skill that quietly assumes a convention fails
in a repo that does it differently, and a reader cannot tell which kind they are
holding.

So: **repo-agnostic** — `dror-internal-project-facts`, `dror-prove`, `dror-code-repair`,
`dror-code-review`, `dror-guide` — name no tracker and no path, and take what a repo
declares from the facts. **Convention-bound** — `dror-show-tickets` — states its
assumptions in its own text and stops when they do not hold.

## Considered options

Making all seven repo-agnostic was rejected for `dror-show-tickets` alone: its
whole output is a table of ADR-to-ticket relationships, and behind a layer of
indirection it would state nothing concrete enough to be useful.

## Consequences

The ticket convention has to reach the agnostic skills some other way, which is
what the fifth project fact is for (ADR 0012).

**The two lists above are this decision's roster at the moment it was made, and
they are not the current one.** Skills written since — `dror-implement-ticket`,
`dror-implement-adr`, `dror-adr-review`, `dror-adr-repair` — are each in one
tier or the other, and where every skill stands today is in
[`DROR-SKILLS.md`](../../DROR-SKILLS.md) §Which of them know your repo's
conventions. Read that for the roster and this for the rule. The rule is what
binds: **each skill says in its own text which tier it is in**, so a reader
holding one skill never has to consult a list at all.

**The rule reaches every skill that acts on a repo, and stops there.** A shelf of
documents (`dror-internal-shared`) and a skill whose whole subject is the logs
outside any repo (`dror-review-retrospective`) are in neither tier, because the
question the tiers answer — what does this assume about *your* project — does not
arise for them. Saying so is not a third tier; it is the rule declining to
apply. Every other skill in the set answers it, session-style ones included.

Two things the rule did not anticipate, both now stated where they apply.
Repo-agnostic means "names no tracker, no path and no runner **of its own**" —
it has never meant free of `git`, which `dror-code-review`'s scope and
`dror-implement-ticket`'s step 0 both require unconditionally; a skill that
needs git says so. And `gh issue view` appearing in an agnostic skill is a
worked example of what the fifth fact returned, not a tracker the skill names —
which is why every one of those sentences is phrased as "the way the issue
convention fact says this repo tracks work".
