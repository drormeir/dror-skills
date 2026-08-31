# An agent is given paths, never pasted text

Every agent a `dror-*` skill spawns — a lens, a refuter, a grounding agent, a
test-writing agent — is given the *paths* of what it must read: the store's
`facts.md`, `LENSES.md` with the name of its section, `REFUTING.md`,
`WRITING-TESTS.md`, the ADR under review, a slice of the diff cut by a command
into a scratch file. What is written into a prompt is only what exists nowhere
else: the finding, the criteria list, the lens's name.

## The defect

`dror-code-review` handed each lens the facts and its lens text "verbatim", each
refuter the facts, `REFUTING.md`'s sections and diff hunks "sliced from the
scratch file by you"; `dror-adr-review` handed every lens and every refuter the
ADR's full text. The controller composed those prompts, so every pasted byte was
paid for twice: as output tokens when the controller wrote it, and then as input
on every later turn of the controller's run, since a tool call's arguments stay
in context. Ten ADR lenses times a few hundred lines of ADR is the dominant cost
of a review, spent in the one context that lives for the whole run.

## Considered options

**Pasting less** — a trimmed preamble, a shorter facts file — was rejected as a
matter of degree: whatever is pasted is still paid for in the wrong place.

**Splitting `LENSES.md` into one file per lens** was rejected for now: a lens
told which heading is its own reads a 10–20 KB file once in a context that is
discarded on return, and a split would move every cross-reference in two review
skills for a saving the agent never notices.

**Pre-loading the shelf into custom agent definitions** (`~/.claude/agents/`)
was set aside rather than rejected: it would move the read from the agent's
first turn to its system prompt, and it puts files outside this repo. It can be
done later without undoing this.

## Consequences

**The diff slice is a command.** `dror-code-review` cuts each refuter's hunks with an
`awk` over the scratch capture, appended to a per-finding slice file; the hunks
never pass through the controller.

**An agent is told which part binds it.** A lens reads all of `LENSES.md` and is
told the preamble and its own section govern; a refuter is told the missing-test
section binds only a `cover` finding. That sentence is what the paste used to
enforce by omission.

**`dror-adr-review` still reads the ADR whole in its own context** — it chooses
the lenses and cannot do that unread — and no longer claims that this is
cheaper than the agents reading it; each agent reads it too, from the path.

**`dror-internal-project-facts`' cost argument changes wording, not force.** The
facts are read by every agent instead of pasted into every prompt; a bloated
`facts.md` is still paid for once per agent.
