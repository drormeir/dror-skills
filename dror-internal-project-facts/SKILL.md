---
name: dror-internal-project-facts
description: Return this repo's domain vocabulary, verification commands, test layout, declared scope and issue convention. Use when another dror skill needs the project facts, or the user asks what rules this repo declares.
---

# dror-internal-project-facts

Return five facts about the repo in hand, and leave them in the store for the
next run. Gathering happens only when the store cannot answer.

This skill is usually a **step inside another one** — its instructions are
loaded into the run that asked for them, not run apart from it. So "return the
facts" means carry them into the rest of that run and keep going; only a run
that was started for the facts themselves ends here. Nothing below stops a
caller's remaining work.

Works in any repo and any language: everything comes from the project itself,
and this skill carries knowledge of none.

## The store

`<repo>/.claude/dror-skills/` is where `dror-*` skills keep what they learn about the
repo. `.claude/` is the project's own directory for agent material, so nothing
is written outside it. The store is disposable — every value in it is
re-derivable, and deleting it costs one re-gather.

`facts.md` holds the five facts and ends with a **stamp**: every file the facts
were read from, each with its size and its `cksum` checksum, then `facts.md`'s
own size in bytes. The checksum is what makes a branch switch free — it rewrites
modification times without touching content, and a stamp on mtime would
re-gather for nothing.

## Step 1 — Ask the store

Read `<repo>/.claude/dror-skills/facts.md`. Take one `cksum` over the files its stamp
names, plus any file on the **check list** the stamp omits. The check list is
exactly: `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md`, `README*`, `CONTRIBUTING*`,
`*.md` under `docs/` in a directory or file whose name contains `adr`,
`*.md` under `docs/` in a directory or file whose name contains `agent`, and the
repo-root build and runner files the verification commands come from —
`package.json`, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`,
`pytest.ini`, `tox.ini` — closed
on purpose, so the hit/miss decision comes out the same on every run; step 2's
gather stays open to whatever else the repo uses.

The build files are on the list for the case the stamp cannot cover. A stamped
file that *changes* is a miss already; a file that **appears** is not, and the
verification commands are the fact that arrives that way — a repo gains a
`Makefile`, or moves its test config into `pyproject.toml`, and the cached
command goes on naming the old runner with nothing to invalidate it. Every skill
in the chain runs that command; a stale one fails in a way that reads as the
project being broken.

**Stamp matches** — every stamped file present with the same size and checksum,
and no check-list file has appeared since — then the facts stand. Take them as they
are and go straight on to whatever asked for them; steps 2 and 3 are skipped.
This is the common path: no rule file is opened, and nothing is written.

**Anything else** — a file changed, gone, or new; a `facts.md` that is absent,
truncated or hand-edited — is a **miss**. Go to step 2. A miss is never an
error; nothing here raises whatever it is handed.

## Step 2 — Gather

Read whatever the repo uses to state its own rules: `CLAUDE.md`, `AGENTS.md`,
`CONTEXT.md`, `README`, `CONTRIBUTING`, ADRs under `docs/`. From them:

- **Domain vocabulary and invariants** — the units, frames, identifiers and
  states this codebase is careful about.
- **Verification commands** — the lint, type-check, format and test commands,
  from the conventions doc, `package.json` scripts, `Makefile`,
  `pyproject.toml`, `Cargo.toml`, or the CI workflow.
- **Test layout** — where tests live, how they are named, how a test that needs
  a harness (a GUI, a server, a fixture) is written here.
- **Declared scope** — the areas the project rules out: retired directories,
  vendored code, generated files. Findings there are noise.
- **Issue convention** — how work is tracked here: the tracker and the command
  that reads an issue — one that returns the title, the body and the open/closed
  state, since the criteria live in the body and blocker checks read the state
  (on a GitHub repo, `gh issue view <n> --json title,body,state`) — where a
  ticket's acceptance criteria live in its body, how a child ticket names its
  parent, and the file that documents all this. A repo
  that tracks nothing records this as unstated, and the skills that take a ticket
  number say so instead of guessing a tracker.

A fact the repo states nowhere is recorded as unstated. An invented one is worse
than an absent one.

**Do the gather in a subagent.** A miss reads every rule file in the repo, and
only the five facts and the stamp need to come back — read into the caller's
own context, a large `CLAUDE.md` is paid for again by every later agent prompt.
The subagent does steps 2 and 3 whole: it gathers, writes `facts.md` with its
stamp, and returns the five facts. The caller takes them as held and goes on;
it does not read the rule files or the store again. A hit never needs this —
step 1 opens no rule file.

## What earns a line

These facts are pasted into every agent prompt of every run that asks for them,
so a `facts.md` that restates the conventions doc paragraph by paragraph is that
document's whole token cost paid again per agent. The whole file stays under
about **12 KB** — bytes, not lines, because bytes are what a prompt pays for and
a line here can run to three hundred characters.

The test for each line is whether it is a **cache** worth holding: does it save
a lookup the agent could not cheaply make itself?

**Write down what cannot be looked up.** The unwritten convention, the reason
behind a choice, the gotcha no config confesses, the two things that look
interchangeable and are not. A `pytest.ini` an agent can open in one call is not
worth a line; "picks are stored in the statics-free frame" is, because nothing
in the tree says it where the code lives.

**Point, don't transcribe.** Where the detail genuinely matters and runs long,
give the file and the heading and stop — `ADR 0005 §working set` costs six
tokens and the agent that needs the paragraph opens it. A fact reproduced here
also goes stale here, silently, while the pointer never does.

**One line per rule, in the words that bind it**: the unit, the frame, the name
of the thing, the command. A rule that takes a paragraph to state is a pointer.

## Step 3 — Store and return

Write `<repo>/.claude/dror-skills/facts.md`: the five facts under five headings, then
the stamp — every file read in step 2 with the size and checksum from one
`cksum` over them. Create the directory when it is absent. Where `cksum` is
absent, stamp size and mtime and note that in the file, so the next run knows
which rule it is comparing under.

**Then measure it.** Run `wc -c` on the file you just wrote. Over the 12 KB cap,
cut and rewrite: the longest entries become pointers (`ADR 0005 §working set`),
and a rule the agent could open for itself in one call comes out altogether.
Repeat until it is under. Record the final byte count as the stamp's last line,
so the next run can see the budget was met rather than assume it.

Hold the five facts as the result of this step, whether they came from the store
or from a gather, and say which. Whatever asked for them uses what is held here;
it does not read the file again.

Done when all five facts are in hand and `facts.md` either matched its stamp or
has just been rewritten with a fresh one, measured and under the cap.
