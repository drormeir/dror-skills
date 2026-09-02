---
name: dror-skill-review
description: Review one skill, or one shared document the skills read, against Anthropic's published rules for a skill, the harness contract, the tree it runs in, itself, the shelf and the agent that reads it - every finding refuted before it reaches you. Reports the survivors and edits no text. Use when the user names a skill or a shelf document and asks what is wrong with it, whether it still matches the repo, or wants it checked before it is edited.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh), Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/anthropic-stamp.sh), Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/skill-rules-check.sh:*), Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/claim-path.sh:*)
---

# dror-skill-review

This skill **finds**, in another skill's text. It produces a report and STOPS,
editing no line of the skill and no line of anything else.

**A skill is not reviewed against one thing.** It is a document an agent
executes mid-run, so it is judged the way `dror-adr-review` judges a decision —
on axes, each admitting a different kind of evidence — and the axes are its
own. The lens pool is organised on that: five axes, set out in
[`LENSES.md`](LENSES.md)'s preamble, with a sixth thing — Anthropic's published
rules — settled by a script before any of them runs.

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
- **Against the publisher** — Anthropic's own published rules for a skill,
  which this repo's conventions sit on top of and do not overrule. These are
  not a lens: every one of them is decided by a script, whose breaches skip the
  refuter the way `dror-code-review`'s lint pass does (ADR 0045, ADR 0049).

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

**This skill reviews two kinds of target, and the target itself says which.**
A name, or a path to a `SKILL.md`, is a **skill**, and the unit is its whole
directory. Any other path resolves by **who owns the file**, in this order:

- **A file the neighbouring `SKILL.md` names as part of its own procedure** — a
  lens pool, a refuting brief, a resume file — is a **companion**, and the
  target is that skill. Reviewing it alone would judge it with the skill that
  reads it outside the read boundary, and would file the findings under a
  second report family from its skill's own. Say on screen which skill the path
  resolved to.
- **An ADR** — a numbered decision file, resolved by
  `../dror-internal-shared/ADR-FILE.md`'s convention — belongs to
  `dror-adr-review`, which judges a decision against the code it governs. Name
  that skill and stop; do not review it here.
- **Anything else** is a **document**: a file an agent reads mid-run, drifting
  the same way and against the same tree. A shelf file like `REPORT-STORE.md`,
  a map, a glossary.

Nothing is asked and no mode is typed. Note that a shelf directory may hold a
`SKILL.md` of its own without its files being companions — `dror-internal-shared`
does, and says in it that the other skills reach its files by path, as
documents. That sentence is the test, not the directory listing. Everything
below that turns on the distinction says so where it applies.

**The unit of review is the skill's whole directory**: `SKILL.md` and every
companion file beside it (a lens pool, a refuting brief, a script). The
companions are part of the procedure and drift exactly as the main file does.
**A document's unit is the one file**, and nothing beside it: the files sharing
its directory are other documents with owners of their own, and sweeping them
in would review several things under one report.

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

## Whether Anthropic's rules are still the ones on file

!`bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/anthropic-stamp.sh`

`../dror-internal-shared/ANTHROPIC-SKILL-RULES.md` holds Anthropic's published
rules for writing a skill, stamped with the `ETag` of the upload they were read
off, and `skill-rules-check.sh` beside it enforces them. The rules, the stamp
values and the enforcement all live there; none is restated here.

The `VENDOR:` line above is that stamp compared against what the source serves
now, by `anthropic-stamp.sh` before this text reached you. It reads one of three
ways, and **all three run the review**:

- `current` — the baseline matches the published guide. Nothing more is owed.
- `moved` — Anthropic re-uploaded the guide, so the baseline may be stale. The
  mechanical pass still runs and its breaches still stand; the report carries
  the line verbatim in its front matter, and the presentation says in one
  sentence that the baseline wants re-distilling.
- `unknown` — no comparison was made, because the network, `curl` or the
  source's own headers did not allow one. Treat it exactly as `moved`: the
  review runs and the report says the baseline could not be checked. A run with
  no network still reviews.

Blocking a run on a stale baseline was rejected (ADR 0047): these rules are the
stable half of what a review checks, and a re-upload is likelier to be a typo
fix than a reversal.

## Read the target

Open the resolved `SKILL.md` and list the directory beside it. **For a
document, open the one file** and list nothing; `<dir>` below is the document
itself, and the grep is for its file name rather than a skill's.

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

A skill that is a stub — frontmatter and no procedure — ends the run here, on
the line **`EMPTY SKILL: <name> is frontmatter and no procedure`** and nothing
else. There is nothing to refute, so no lens runs, no report is written and no
log line is owed. **A document is never a stub by this test**, since it carries
no frontmatter to be all of; an empty document ends the run on the same line
with `is empty` in place of the reason.

**That line is the only reason this skill ends without a report**, so it is
what a caller reads to tell an empty skill from a run that broke. A run that
stops anywhere else has failed, and its silence must not be read as this.

## The mechanical pass

Before any lens is launched, run
`bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/skill-rules-check.sh <the resolved directory>`.
It decides every one of Anthropic's published rules that a tool can decide, and
prints one `BREACH:` line per rule broken, or `CLEAN`. It takes the directory as
an argument, which is why it runs here and not as an injection at the top.

**It runs for a skill and not for a document.** Every rule it enforces is a
rule about a `SKILL.md` — a frontmatter field, a directory's shape — and a
document has none of them, so its verdict on one would be an answer to a
question nobody asked. A document run says in its report that the pass does not
apply, which is not the same as `CLEAN`.

**Each `BREACH:` line is a finding that skips the refuter.** The script's own
output is its proof (ADR 0006), and a model asked to second-guess a string
comparison can only get it wrong. They carry the reserved lens name **`tool`**,
ADR 0045's, and their verdict is `survived` by construction. Their kind is
`text`: the frontmatter or the directory is wrong and the repair corrects it.

Redirect the output into a scratch file and give **every** lens its path, with
the instruction not to re-report what it holds. `LENSES.md`'s preamble says the
same thing from the lens's side; this is the input that makes it enforceable.

The pass is **not a lens**. It appears in none of `lenses_run`,
`lenses_dropped` or `lenses_lost`, and dropping a lens never drops it.

## Run the lenses

[`LENSES.md`](LENSES.md) is a **pool**, not a running order. Choose the ones
this skill raises and run each as one agent, all launched in parallel. Every
lens is given the skill's directory path, the path of the store's `facts.md`,
the grep capture from the read above, and the path of `LENSES.md` with the name
of its lens — it reads that file itself, and is told that the preamble and the
section headed with its name bind it while the other sections are other
agents'. Beyond those, the read above assigns the inputs per lens: the capture
of what moved since goes to `anchors` and `mirrors`, the mirror paths to
`mirrors`, and the mechanical pass's scratch file to all of them. Paths, never
contents.

Choosing is this skill's job, not the user's, and **the test is at bullet
granularity**: a fact that retires some of a lens's bullets retires those
bullets and not the lens, and a lens is dropped only when none of its bullets
applies. A skill that invokes no other skill and spawns nothing raises no
`sequence` bullet about delegation, but still raises the ones about a closing
contract, an undefined word, two passages that disagree — so the lens runs. A
repo with no index needs no `mirrors`, and that is the whole-lens case: every
one of its bullets presupposes a copy that is not there. Say in the report
which were dropped, so a reader knows what was not looked at.

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

**The models, the read boundary, what came back and the merge are the shelf's**:
`../dror-internal-shared/LENS-FANOUT.md` holds them in one copy for all three
reviews. Read it whole before launching the batch. It is not restated here.

**What this run gives each lens, inside that boundary.** Every lens gets the
skill's directory. Beyond it: `anchors` gets the files the skill points at,
`ownership` and `mirrors` get the shelf files and index rows the grep capture
names, `contract` and `execution` get the skill alone, `sequence` gets the skill
plus any ADR a spawn step's parameters rest on.

## Merge

**The key this review groups by** is the **skill line** a finding names and what
it claims is wrong. The rest of the merge is the shelf's.

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

Every survivor carries exactly one. The five values — `text`, `hole`, `sprawl`,
`echo`, `conflict` — and what each **means** are minted in
[`LENSES.md`](LENSES.md)'s preamble, the text pasted into every lens agent's
prompt, and what kills each is [`REFUTING.md`](REFUTING.md)'s, section by
section. Neither is restated here.

What this file adds is the part neither carries: the kind is what decides
**whose work it is next**.

- `text`, `hole`, `sprawl` and `echo` go to `dror-skill-repair`. A `hole` only
  where the missing sentence can be **grounded** in the tree or the skill's own
  reasoning — the shape a delegation `hole` is filled in is
  `../dror-internal-shared/DELEGATION.md`'s. A `sprawl` is collapsed to a
  pointer, never synchronised into two copies. An `echo` is repaired in
  **every** copy the finding names, at once, because the copy that gets read is
  the one that governs.
- `conflict`: **nobody repairs it without the user.** Two documents that both
  declare ownership, or two skills deciding one question two ways — picking a
  side is deciding.

A finding a refuter could not settle says so on its line and keeps its kind.

## Write the report down

`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill — holds
the naming, identity, finding-id and log rules every `dror-*` report obeys, in
one copy. Read it whole before writing anything, and take this run's name from
it. It is not restated here.

Number the survivors: `conflict` first — it is the kind that blocks somebody —
then `text` in the order of the damage a run acting on it does, then `hole`,
then `sprawl`, then `echo`. Save them under the name the reference gives —
claimed first where that name came from a caller, as the reference says, and
written to whatever path the claim printed. It is a separate file family from the code
review's and the ADR review's on purpose: no run should be able to erase
another kind of run's findings.

Front matter first: **what this report is for** — the identity line the
reference gives, `Skill: <name>` or `Document: <path>` — with its resolved
directory or file; the commit `HEAD` was at; the
commit and date the skill itself last moved; the time this report was written
(`date +%H%M`, the same call the log's date comes from); **this run's
tag**, minted by the store's recipe unless the caller gave one; and the
`VENDOR:` line this run was given, quoted verbatim, so a reader of the report
alone can tell which baseline the `tool` breaches rest on.

Then one section per finding, numbered as on screen, each with:

- its **id**, minted by the reference's rule from the front matter's commit,
  this run's tag, this run's round and the finding's number;
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
values: `path` is **the file the finding's own sentence sits in, repo-relative**
— the skill's `SKILL.md`, or the companion beside it the finding is about, since
the unit of review is the whole directory and a log that flattened every finding
onto `SKILL.md` could not say which file drifted; a finding whose *evidence*
sits elsewhere still takes the path of the sentence it is about; for a document
it is that one file, every time; `kind` is
`text / hole / sprawl / echo /
conflict`; `claim` is always `no` — this skill writes no claim comments, and
the column stays so the pools share one schema; `subject` is **the skill's
name**, or **the document's repo-relative path**; `round` is the round a
looping caller named, or `-`; and `run_tag` is this run's tag.

**The `lens` column is a closed vocabulary**: a section name from this skill's
[`LENSES.md`](LENSES.md), the reserved name `tool` for a mechanical-pass
breach (ADR 0045), or a name from another review's own pool. Nothing else
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

This run's own values: `lenses_run`, `lenses_dropped` and `lenses_lost` carry
the closed names from this skill's [`LENSES.md`](LENSES.md), and `lenses_lost`
is `-` where the check above found every launched lens returned — never
`unchecked`, since this skill runs that check; `concurrent` is
**`unchecked`**, or the tags a caller told this run it saw, joined by `+` —
this skill runs no neighbour check of its own, and `unchecked` is the honest
word for that, never `-`, which in `dror-code-review`'s rows means *looked and
saw nobody*; `round` and `subject` are the same values the finding log's
section above gives them; and `elapsed_s` is the difference between a
`date +%s` read immediately before the lenses are launched and one read as
this line is written, or `-` where the first reading was not taken.

One line per review that ran lenses, whether it found anything or not. An
`EMPTY SKILL:` run ends before this section is reached and writes no line —
there is no `lenses_run` value for a run that chose none, and the log exists to
give a lens its denominator.

## Present

Show the same numbered list, in that order, each line naming its kind. Under
it, say in one sentence which findings are this chain's next work and whose:
the `text`, `hole`, `sprawl` and `echo` ones go to `dror-skill-repair`, and a
`conflict` waits for the user, because somebody must choose.

Name the report file this run wrote, since a repair run has to be pointed at
it and only this run knows which name it took, and say this run's tag once.

Where the `VENDOR:` line read `moved` or `unknown`, add one sentence: which of
the two it was, and that `dror-skill-vendor-rules` in `refresh` mode is what
re-distils the baseline. It is a note to the user, not work for the repair, and
this run does not invoke it.

Then **one line saying whether a repair should follow**, and why in half a
sentence. Three answers — *yes*, naming which findings need the edit; *no*,
where every survivor is something to know rather than something to change;
*the user's call*, where a `conflict` is the whole list. It binds nobody; a
looping caller reads this line to decide whether to spend a repair at all.

Then stop and wait.

Done when every lens this batch launched has returned or is named in the report
as one whose output did not arrive, the findings have been merged, every merged
finding has faced a refuter, this run's report file holds the survivors and
the refuted with an id each, every merged finding has a line in
`~/.claude/dror-skills/refutations.tsv`, the run has its line in
`~/.claude/dror-skills/runs.tsv`, the repair-or-not line is on screen, and
that same list is on screen — with no line of the skill and no line of
anything else changed.
