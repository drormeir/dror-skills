---
name: dror-skill-review
description: Review one skill against the harness contract, the tree it runs in, itself, the shelf and the agent that reads it - every finding refuted before it reaches you. Reports the survivors and edits no text. Use when the user names a skill and asks what is wrong with it, whether it still matches the repo, or wants it checked before it is edited.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-skill-review

This skill **finds**, in another skill's text. It produces a report and STOPS,
editing no line of the skill and no line of anything else.

**A skill is not reviewed against one thing.** It is a document an agent
executes mid-run, so it is judged the way `dror-adr-review` judges a decision —
on axes, each admitting a different kind of evidence — and the axes are its
own. The lens pool is organised on that: five axes, set out in
[`LENSES.md`](LENSES.md)'s preamble.

- **Against the harness** — the frontmatter and the promises it makes: the
  description against the body, the fork flags, the injected commands.
- **Against the tree** — every path, command, skill name and file the text
  points at, checked against what is actually there. Grep is the test suite
  here; a dead pointer is a step that fails mid-run.
- **Against itself** — a procedure that contradicts itself, a vocabulary used
  and never defined, a delegating step that ends on no named action.
- **Against the shelf and its siblings** — a shared rule restated where a
  pointer belongs, a tunable numeral living twice, a mirror row that has
  drifted, two skills deciding one question differently.
- **Against the agent that reads it** — a sentence that is true and gets
  executed wrongly, which no later run ever catches, because the reader is not
  a person who asks.

Only one axis reads code-as-such, so **a `file:line` outside the skill's own
directory is not what a finding owes** — it is what some axes' findings owe.
Findings are told apart by their **kind**; every kind but `conflict` is
repaired by `dror-skill-repair`, and a `conflict` waits for the user.

## What this skill assumes

It is **convention-bound**: it assumes skills as directories holding a
`SKILL.md`. The argument is a skill's name or a path. A path given is opened as
given. A name resolves in this order — `<repo>/<name>/SKILL.md` (a skills repo,
like the one these files live in), `<repo>/.claude/skills/<name>/SKILL.md`,
`~/.claude/skills/<name>/SKILL.md` — and the first hit wins. No match ends the
run: say so and stop, and do not guess which skill was meant.

**The unit of review is the skill's whole directory**: `SKILL.md` and every
companion file beside it (a lens pool, a refuting brief, a script). The
companions are part of the procedure and drift exactly as the main file does.

Everything else about the repo in hand arrives through the facts below.

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
stamp matched the tree (ADR 0037). Every agent below is given the store's path
to them: the domain vocabulary is what a term is checked against, and the
declared scope marks which findings are noise. A block that begins `MISS:`
means the store could not answer: invoke the `dror-internal-project-facts`
skill — it gathers in a subagent, rewrites the store and returns the five facts
— and hold what it returns as the facts from then on. That skill is a **step of
this one**, not a hand-off; `../dror-internal-shared/DELEGATION.md` owns what
that means, at authoring time. Either way, the moment the facts are in hand,
**resolve the skill's name to its directory, in the same turn**, by the rule
above.

## Read the skill

Open the resolved `SKILL.md` and list the directory beside it.

**Read it whole, here, before anything is spawned.** Choosing the lenses is
this skill's job and it cannot be done unread. Every agent needs it too, and
each reads it for itself from the path it is given: text this run writes into a
prompt is output tokens, paid once per agent and then held in this context for
the whole run, while a path costs one read in an agent that is gone when it
returns (ADR 0038). Then find, in this order:

- **Its date and its commit.** `git log -1 --format='%h %ad' -- <dir>` — when
  the skill last moved. Age is what a reader weighs a survivor against, so it
  goes in the report.
- **What moved around it since.** `git log --oneline <commit>..HEAD` over the
  repo — a skill drifts when its neighbours move, not when it does. Redirect it
  into a scratch file; the `anchors` and `mirrors` lenses are given its path.
- **What points at it, and what it points at.** Grep the repo for the skill's
  name, into a second scratch file — its callers, its mirror rows, the shelf
  files that name it. Every lens is given this path too; it is the caller
  boundary, found once instead of once per lens.
- **Its mirrors.** Where the repo keeps an index quoting descriptions or
  mapping skills — in this repo, `STRUCTURE.md`, `DROR-SKILLS.md` and the
  glossary — note their paths for the `mirrors` lens. A repo with no such index
  drops that lens and says so in the report.

A skill that is a stub — frontmatter and no procedure — ends the run with that
one sentence. There is nothing to refute.

## Run the lenses

[`LENSES.md`](LENSES.md) is a **pool**, not a running order. Choose the ones
this skill raises and run each as one agent, all launched in parallel, each
given the skill's directory path, the path of the store's `facts.md`, the two
scratch paths from the read above, the mirror paths, and the path of
`LENSES.md` with the name of its lens — it reads that file itself, and is told
that the preamble and the section headed with its name bind it while the other
sections are other agents'. Paths, never contents.

Choosing is this skill's job, not the user's. Skip a lens whose concerns the
skill never raises — a skill that invokes no other skill and spawns nothing
needs no `sequence` bullets about delegation, though its other bullets may
still earn it a place; a repo with no index needs no `mirrors`. Say in the
report which were dropped, so a reader knows what was not looked at.

**There is no count cap here, and that is a decision.** Every lens the skill
raises runs, up to the whole pool. A numeric cap below the pool's size drops a
lens on every run whatever the skill is, and the log says what it dropped: over
this pool's first four runs it took out `ownership` — the most precise lens on
record — twice, while the least precise ran every time. The cap also bound the
wrong half: a lens is one cheap agent (ADR 0003) and the refuters under its
findings are on the strong model with no cap at all, so a lens refused entry
saves the cheapest thing in the run and buys a blind spot with it. The budget
is held instead by the read boundary below and by lenses that kill their own
weak findings. Neither `dror-code-review` nor `dror-adr-review` is changed by
this: a diff spread over many files, and a pool much larger than this one, are
different arguments, and each states its own.

`anchors` and `execution` are the two that earn their place on nearly every
run: between them they are the whole question of whether the skill still runs
and whether it runs as meant.

**Lenses run on the cheap model, refuters on the strong one.** Pass
`model: "sonnet"` to every lens agent and leave the refuters on the session's
own. Spend the tokens where the judgement is.

**Cap what a lens reads, on its own axis.** Every lens gets the skill's
directory. Beyond it: `anchors` gets the files the skill points at, `ownership`
and `mirrors` get the shelf files and index rows the grep capture names,
`contract` and `execution` get the skill alone, and `sequence` gets the skill
plus any ADR a spawn step's parameters rest on. A lens that cannot
reach a verdict inside its boundary says so and returns the question rather
than widening — reading a subsystem to settle one sentence is the refuter's
budget to spend, on one finding.

## Merge

Two lenses reading adjacent concerns report one defect twice. Group the
returned findings by the **skill line** they name and by what they claim is
wrong, before anything is refuted: findings that name the same defect become
one, keeping the clearest statement, and noting every lens that raised it. One
defect, one finding, whatever found it.

An `ownership` and a `mirrors` finding about the same rule are **not** a
duplicate — one says the rule lives in too many places, the other that a copy
has drifted — and which reading is right is the refuter's job to settle. Keep
them separate through the merge.

## Refute

Hand each merged finding to one independent agent, all launched in parallel —
one refuter per finding, however many survived the merge, with **no cap**. Each
is given: its finding; the path of the store's `facts.md`; the skill's
directory path; and the path of [`REFUTING.md`](REFUTING.md), to read whole.
Paths, never contents.

Every suspect is checked. Cutting the list here would put unchecked suspicions
in the report, and a reader cannot tell an unchecked finding from a confirmed
one. The cost is controlled before this point — a tighter read boundary, and
lenses that kill their own weak findings rather than passing them on.

Survivors are the report.

## The kinds

Every survivor carries exactly one, and the kind is what decides whose work it
is next:

- **`text`** — the skill says something that is not true, or no longer true —
  a dead path, a renamed name, a wrong command, a promise the body breaks — or
  says something true that its executing agent acts wrongly on. Repaired by
  `dror-skill-repair`.
- **`hole`** — the skill's own procedure forces a question it leaves
  unanswered: a word used and never defined, a return contract never stated, a
  delegating step that ends on no named next action (the shape is
  `../dror-internal-shared/DELEGATION.md`'s). Repaired by `dror-skill-repair`,
  and only where the missing sentence can be **grounded** in the tree or the
  skill's own reasoning.
- **`sprawl`** — a rule, tunable or vocabulary living in more places than its
  owner: a shelf rule restated where a pointer belongs, a cap spelled as a
  numeral in two files, a closed vocabulary defined outside the text that mints
  its values. Nothing need have drifted yet — the duplication is the defect,
  because it is how the next `echo` is made. Repaired by `dror-skill-repair`,
  which collapses the copy to a pointer.
- **`echo`** — the skill is right and a copy of it elsewhere has drifted: its
  index row, its map entry, a glossary line, a sibling's paraphrase. The copy
  that gets read is the one that governs, so the finding names **every** copy
  with its `file:line`, and `dror-skill-repair` synchronises all of them at
  once. The `mirrors` lens is what mints it.
- **`conflict`** — two documents claim the same rule differently and both
  declare ownership, or two skills decide one question two ways. **Nobody
  repairs this without the user**: picking a side is deciding.

A finding a refuter could not settle says so on its line and keeps its kind.

## Write the report down

`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill — holds
the naming, identity, finding-id and log rules every `dror-*` report obeys, in
one copy. Read it whole before writing anything, and take this run's name from
it. It is not restated here.

Number the survivors: `conflict` first — it is the kind that blocks somebody —
then `text` in the order of the damage a run acting on it does, then `hole`,
then `sprawl`, then `echo`. Save them under the name the reference gives,
overwriting the previous one. It is a separate file family from the code
review's and the ADR review's on purpose: no run should be able to erase
another kind of run's findings.

Front matter first: **the skill this report is for** — `Skill: <name>`, the
identity line — with its resolved directory; the commit `HEAD` was at; the
commit and date the skill itself last moved; the time this report was written
(`date +%H%M`, the same call the log's date comes from); and **this run's
tag**, minted by the store's recipe unless the caller gave one.

Then one section per finding, numbered as on screen, each with:

- its **id**, minted by the reference's rule from the front matter's commit,
  this run's tag, the report's own time and the finding's number;
- the **skill line or quoted sentence** it is about, and **what it was judged
  against**, in the form its axis takes: the file or command that contradicts
  it, the other passage of the same skill, the shelf file or index row with its
  `file:line`, or the wrong action the executing agent takes;
- its **kind**;
- what is wrong, in one or two sentences;
- for a `text`, `hole`, `sprawl` or `echo` — the four the repair writes prose
  for — **what would make it true**: the corrected fact or the owning file to
  point at, with the evidence the refuter stood on, and for an `echo` the
  `file:line` of **every** copy. Not the replacement prose; that is the
  repair's writing.

**A finding is about fifteen lines.** Also name the lenses that were **not**
run, since a reader cannot tell an area that came back clean from one nobody
looked at.

**Then record the kills.** A last section, `## Refuted`, holding every finding
that did *not* survive: its id, the sentence it was about, the lens that raised
it, what it claimed, and why the refuter killed it. Number the kills on from
the survivors, so every merged finding has an id and the two sections never
mint the same one twice. One short paragraph each — nothing downstream acts on
these. It is the run's only record of its own precision.

## Append to the log

The report is overwritten every run, so every **merged finding**, survivor and
kill alike, is also appended as one line to
`~/.claude/dror-skills/refutations.tsv` — the same log the other reviews
write, on the reference's terms for every log. The `lens` column keeps the
pools apart; nothing else has to.

One tab-separated line per finding — the columns and their order are the store
reference's (`REPORT-STORE.md`, "The logs"), stated there once. This run's own
values: `path` is **the skill's `SKILL.md`, repo-relative**, even for a finding
whose evidence sits elsewhere; `kind` is `text / hole / sprawl / echo /
conflict`; `claim` is always `no` — this skill writes no claim comments, and
the column stays so the pools share one schema; `subject` is **the skill's
name**; `round` is the round a looping caller named, or `-`; and `run_tag` is
this run's tag.

**The `lens` column is a closed vocabulary**: a section name from this skill's
[`LENSES.md`](LENSES.md), or one from another review's own pool. Nothing else
may be written there — a name outside that set silently corrupts every rate
`dror-review-retrospective` computes. The three pools' names are disjoint,
which is what lets one log hold them and a reader tell them apart. Where the
merge joined several, join their names with `+`.

## Record the run itself

A lens that ran and found nothing writes no line above, so the log alone
cannot tell a skill that came back clean from one nobody looked at. So append
one line to `~/.claude/dror-skills/runs.tsv`, on the same terms — the columns
and their order are the store reference's (`REPORT-STORE.md`, "The logs"),
stated there once.

This run's own values: `lenses_run` and `lenses_dropped` carry the closed
names from this skill's [`LENSES.md`](LENSES.md); `concurrent` is
**`unchecked`**, or the tags a caller told this run it saw, joined by `+` —
this skill runs no neighbour check of its own, and `unchecked` is the honest
word for that, never `-`, which in `dror-code-review`'s rows means *looked and
saw nobody*; `round` and `subject` are the same values the finding log's
section above gives them; and `elapsed_s` is the difference between a
`date +%s` read immediately before the lenses are launched and one read as
this line is written, or `-` where the first reading was not taken.

One line per review, whether it found anything or not.

## Present

Show the same numbered list, in that order, each line naming its kind. Under
it, say in one sentence which findings are this chain's next work and whose:
the `text`, `hole`, `sprawl` and `echo` ones go to `dror-skill-repair`, and a
`conflict` waits for the user, because somebody must choose. Then stop and
wait.

Name the report file this run wrote, since a repair run has to be pointed at
it and only this run knows which name it took, and say this run's tag once.

Then **one line saying whether a repair should follow**, and why in half a
sentence. Three answers — *yes*, naming which findings need the edit; *no*,
where every survivor is something to know rather than something to change;
*the user's call*, where a `conflict` is the whole list. It binds nobody; a
looping caller reads this line to decide whether to spend a repair at all.

Done when every lens has returned, the findings have been merged, every merged
finding has faced a refuter, this run's report file holds the survivors and
the refuted with an id each, every merged finding has a line in
`~/.claude/dror-skills/refutations.tsv`, the run has its line in
`~/.claude/dror-skills/runs.tsv`, the repair-or-not line is on screen, and
that same list is on screen — with no line of the skill and no line of
anything else changed.
