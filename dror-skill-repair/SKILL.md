---
name: dror-skill-repair
description: Repair a skill's text from findings already made - every corrected sentence grounded in the file or command it points at, restatements collapsed to pointers, every drifted copy synchronised, and no behaviour redesigned. Use when asked to fix a skill review's findings, or to bring a named skill back in line with the repo it runs in.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-skill-repair

Repair the skill text a review has already found fault with. Runs start to
finish without stopping.

**It writes prose and nothing else — and here the prose is the machine.** A
skill file is read by an agent mid-run, so every edit is a behaviour change;
this run's licence is exactly the findings it was handed, and nothing else
moves. Prose wherever a finding names it counts: the skill's own files, its
index row, its map entry, a glossary line, a sibling's routing sentence.

**Every finding is on the list.** The default is the whole report, or
everything the findings file names. The user subtracts from it — "skip 3",
"leave the sprawl" — and may add a finding of their own; naming a few is not a
way of choosing only those. Work that list and only that list; discovering
further faults is `dror-skill-review`'s run.

This skill is **repo-agnostic** (ADR 0011): it names no path of its own,
because it is handed the report rather than asked to find a skill.
`dror-skill-review` resolves a name to a directory and is convention-bound for
that reason; nothing of its resolution rule reaches this file. Everything
about the repo in hand arrives through the facts below.

## The one thing this skill may not do

**It may not redesign the skill.** A repair makes a sentence true, collapses a
copy to a pointer, names the next action a step already implies, and brings a
drifted mirror back to what the skill says. What it never does is change what
the skill *does*: a new step, a removed step, a different cap value, a changed
fan-out, a reordered procedure. That is a decision about how the machinery
works, and a repair that takes it has rewritten a skill nobody approved.

So the line is drawn at the sentence's job:

- A sentence that **describes or points** — a path, a name, a command, a
  schema, an owner — is repaired freely, to whatever the tree says now.
- A sentence that **designs** — what the skill does, in what order, with what
  budget — is corrected only to what the finding grounds, and where making it
  true would change the design, the item is left as `Needs a decision`.
- A **conflict** between two owners is not repaired at all. It goes back to
  the user with both passages quoted.

An item recorded as `Needs a decision` is a finished outcome of this run, not
a failure of it.

## Start from the written report if there is one

The last skill review's report holds its findings with their quoted sentence,
kind and evidence. Read it and work from it.

**Which file it is, and whether it is yours, the reference answers.**
`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill —
holds the naming, identity, staleness, finding-id and log rules every `dror-*`
report obeys, in one copy. Read it whole before working from a file. It is not
restated here.

One thing it says is worth reading twice here: where the report's recorded
`HEAD` — or the skill's own last commit — has moved, the evidence as well as
the line numbers came from another state of the tree, so locate each finding
by the sentence it quotes rather than by the number.

Its `## Refuted` section is **not** the list. Those findings were raised and
then disproved, and repairing one is editing a true sentence to satisfy a
mistake. The user has to name it explicitly before it counts.

**This run has a context of its own.** The frontmatter forks it (ADR 0036):
what reaches it is this file, the facts the line below injects, and the
arguments it was invoked with — never the conversation that invoked it.
Everything the run needs from that conversation arrives as an argument or not
at all; a question only the user can answer is returned as the result, and the
caller puts it; and what goes back to the caller is the closing summary.

## The project facts

!`bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh`

The block above is the store's `facts.md`, printed by
`dror-internal-project-facts/facts.sh` before this text reached you, when its
stamp matched the tree (ADR 0037). The **domain vocabulary** matters most here
— a repaired sentence is written in the repo's own words, and a repair that
introduces a synonym for a term the glossary fixes has made the skill worse
while making it true. A block that begins `MISS:` means the store could not
answer: invoke the `dror-internal-project-facts` skill — it gathers in a
subagent, rewrites the store and returns the five facts — and hold what it
returns as the facts from then on. That skill is a **step of this one**, not a
hand-off; `../dror-internal-shared/DELEGATION.md` owns what that means, at
authoring time. Either way, the moment the facts are in hand, **spawn step 1's
grounding agents, one per item, in the same turn** — step 1 is read-only and
runs fanned out, so the first call after the facts is the fan-out itself.

## The evidence a skill repair stands on

A code repair proves itself by watching a test go **red** and then **green**.
There is no such thing for a sentence, and pretending otherwise is how a
plausible correction ships. So this skill's evidence is `dror-adr-repair`'s
two words, unchanged in meaning:

- **grounded** — the corrected sentence was read out of the tree as it stands
  now, and the run can quote the `file:line`, the command output or the
  listing that says it. Every sentence this run writes is grounded.
- **ungrounded** — nothing in the tree settles it. The sentence is **not
  written**. What the run produces instead is the question, put to the user.

The report's own evidence is not enough on its own: it was gathered by a
refuter against a tree that may have moved, and written down in fifteen lines.
Step 1 re-reads it. That re-reading is the whole of this skill's rigour — and
this repo's own rule supplies the second half: **grep is the test suite**, so
every rename this run performs is proved by a grep that comes back empty.

## Step 1 — Ground

For every item, go to the tree and settle what the sentence should say.
Produce, per item: the quoted sentence, the `file:line` or command output that
settles it, and the corrected **fact** — still not the prose. For a `sprawl`
item, the fact is **which file owns the rule**, read from its header or the
repo's conventions; for an `echo`, the surviving copy list, each re-read.

An item that comes back **ungrounded** is carried to step 2 and written into
nothing. An item whose finding turns out to be **wrong** — the tree says what
the skill already said — is carried the same way and reported as not
reproduced, with the evidence quoted. Neither is an error; both are the
ordinary outcome of checking.

A `conflict` item is grounded like the others and then **stops here**: confirm
the two passages still disagree, quote both, and carry it as a question for
the user. Nothing is written for it.

### Fan out, one agent per item

This step is read-only, so it parallelizes cleanly: spawn one subagent per
item, all at once. Each is told: the finding with its quoted sentence and
kind, the path of the store's `facts.md`, the skill's directory path — paths,
never their contents (ADR 0038) — and that it **writes nothing**. It returns
the corrected fact with its evidence, or `ungrounded` with what could not be
settled, or `not reproduced` with the passage of the tree that agrees with the
skill.

Grouping is by item and not by file because most edits land in one skill
directory, which is precisely why the *writing* below is not parallelized.

Done when every item is grounded, ungrounded, not reproduced, or carried as a
`conflict`, with the evidence on screen for each.

## Step 2 — Write

**This step is serial and stays in this context**, and that is a decision
rather than an omission. The edits cluster in one directory, two corrections
meeting in one paragraph is the ordinary case, and prose consistency is a
judgement about the whole document, which an agent holding one sentence cannot
make.

- **Edit the sentence, not the section.** The smallest change that makes it
  true. A rewritten paragraph hides the correction inside a diff nobody can
  read, and it costs the skill its author's voice.
- **Match the skill's voice** — its tense, its terminology, its level of
  detail — and **use the repo's words**: the glossary's term, not a synonym.
- A **`hole`** is filled with the grounded sentence and no more. A delegation
  hole is filled in `DELEGATION.md`'s shape — the step ends on the named next
  action, and the sub-skill it invokes is never edited for it.
- A **`sprawl`** is collapsed to a pointer: the owner's copy stays, the
  restatement becomes the pointing clause this repo prescribes, and a numeral
  leaves every file that does not enforce it. Never collapse the owner —
  where step 1 could not say which copy owns, the item is `Needs a decision`.
- An **`echo` is repaired in every copy it names**, in one pass, before the
  next item starts. Each copy is corrected in *its own* register: the skill
  keeps its detail, an index row stays one line, a map entry stays a map
  entry. Making them identical is not the goal; making none of them say
  something different is. Where the finding says a copy is **missing**, write
  it where the finding says it belongs, in that document's own form.
- **Fix what the fix makes untrue, by the repo's own duties.** A corrected
  `description:` updates the index row that quotes it, in this same run. A
  rename is followed by a grep for the old spelling across the repo, and
  every hit a finding named is repaired under its item. Repair no hit **no
  finding named**: that is the review's miss, not this run's licence — name
  it in the report and leave it, because an edit nobody refuted is exactly
  what this chain's two-run split exists to prevent.

The skill's frontmatter is edited only where a finding named it — and a
`description:` edit is exactly the case the duty above exists for.

Done when every grounded item has an edit behind it and every other item has a
recorded reason it has none.

## Step 3 — Check

A skill has no suite, so the check is a reading and two searches:

1. **Read the repaired files whole, top to bottom, after the edits.** A
   document repaired sentence by sentence acquires contradictions between the
   repaired sentences. This is the one step that catches them, and it cannot
   be delegated to an agent that saw only its own item.
2. **Resolve every pointer** the repaired files carry — relative paths to the
   shelf, to companions, to other skills — and every `${CLAUDE_SKILL_DIR}`
   line, resolved to the skill's directory.
3. **Grep the repo for the old spelling** of anything renamed. An empty
   result is the pass; a hit no finding named is reported and left, as step 2
   says. Where there are several, say so plainly — it is the signal that the
   next `dror-skill-review` should run `mirrors`.

Where the repo declares a docs check of its own — a link checker, a formatter
— run it and paste its output.

The run ends here, with the changes uncommitted. Committing is the user's.

## Report

Two things per item, answered separately, because what the review named and
what this run did about it are different facts. The finding is a neutral
observation; the outcome carries the verdict.

- **What was found** — the kind of thing, in a word. An open vocabulary; the
  usual ones:
  - `stale` — the skill described a tree that has moved.
  - `wrong` — the skill was never right.
  - `unclear` — true but executed two ways.
  - `hole` — a question the procedure forces and left unanswered.
  - `sprawl` — a rule, tunable or vocabulary living beyond its owner.
  - `echo` — right here, drifted in a copy elsewhere.
  - `conflict` — two owners, or two skills deciding one question two ways.
- **Repair's outcome** — what this run did. Also open; the usual ones:
  - `Corrected (grounded)` — the strong claim: the fact was read out of the
    tree this run, and the sentence now says it. The note carries the
    `file:line` or command.
  - `Filled (grounded)` — a `hole` closed with a sentence the tree supports.
  - `Pointed` — a `sprawl` collapsed: the restatement is now a pointer and
    the owner's copy stands alone. The note names the owner.
  - `Synchronised` — an `echo`: every copy the finding named now says the
    same thing. The note lists them, and a copy left alone says why.
  - `Left — needs a decision` — repairing it would redesign the skill or
    pick an owner, or it is a `conflict`. Names the question the user has to
    answer.
  - `Left — ungrounded` — nothing in the tree settles it. Names what is
    missing.
  - `Not reproduced` — the tree agrees with the skill. Nothing changed, and
    the evidence is quoted.
  - `Duplicate of N` — it and item N are one fault; N carries the repair.
  - `Deferred` — real, and left on the **user's** instruction.

Never pair a finding with an outcome that contradicts it:

- `conflict` ends in `Left — needs a decision`, never in a `Corrected` —
  somebody must choose.
- `sprawl` ends in `Pointed` or `Left — needs a decision`, never in a
  `Corrected` that leaves both copies standing — two synchronised copies are
  the next drift, not a repair.
- `echo` ends in `Synchronised`, never in a bare `Corrected (grounded)` — the
  outcome has to say that every copy was reached.
- A `Corrected (grounded)` with no `file:line` or command in its note is not
  grounded, and the row is wrong.

Run `printenv CLAUDE_CODE_ENTRYPOINT`. If it is `claude-vscode`, report one
row per item: **Item | Sentence | What was found | Repair's outcome | Evidence
| Note**. `Sentence` is the quoted fragment, shortened. `Evidence` is the
`file:line`, the command, or `—`.

Otherwise report the same rows as one line each, in the same order, reading
`<item> — found: <kind> — outcome: <outcome> — evidence: <file:line or none>
— <note>`.

Below the rows: the unclaimed grep hits from step 3 and the docs-check output,
if any. Then mark the report — **the file this run read**, never the store's
default name where they differ. Add to every finding this run handled a line
saying what became of it, and leave the rest of the file as it stands, so a
later run skips what is already done.

## Say what became of each finding

A review scores a finding as *survived* the moment a refuter fails to kill it,
and nothing revisits that. This run is where a survivor meets the tree: one
turns out not to be reproduced, another cannot be grounded at all. Until that
is written where a later run can read it, every one of them stays on the
record as a success.

So for every finding that carried an **id** in the report, append one line to
`~/.claude/dror-skills/repairs.tsv` — the same log the other repairs write, on
the store reference's terms for every log.

The columns and their order are the store reference's (`REPORT-STORE.md`, "The
logs"), stated there once, including the rule that the same `files_edited` and
`production` go on every row this run appends. This run's own values:
`outcome` is the word from this run's report — `Corrected (grounded)`,
`Pointed`, `Not reproduced`, … — and `production` is **`yes` whenever
`files_edited` names any file**: a skill file is read by an agent mid-run, so
in this pool an edited file *is* the production path. A run that edited
nothing writes `-` and `no`.

A report whose findings carry no id — an older one, or one this skill was not
given — records nothing here, and that is not a failure: the join has no key,
and a line keyed on a guess is worse than an absent one.

## Say whether another review is owed

The last line of the run, and the one a **looping caller** reads: does the
skill this run leaves behind need reviewing again? Answer in a word with the
grounds in half a sentence, and name what was edited.

- **yes** — prose was written, so there are now sentences no review has read
  and an agent will execute. Strongest where an edit reached a file the
  findings never named, or where an `echo` was synchronised across several
  copies.
- **no** — nothing was written at all: every item was `Not reproduced`,
  `Left — ungrounded`, or `Left — needs a decision`. A run that changed no
  file leaves nothing for a further pass to read.
- **the user's call** — the skill moved only in the narrow way each finding
  described, and the run has nothing further to suggest.

It is a **report, not a decision**: this skill neither reviews nor loops, and
whether the next round is worth its cost belongs to whoever called. Answer it
even when nobody asked — a caller that does not want it ignores one line.
