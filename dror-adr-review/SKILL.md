---
name: dror-adr-review
description: Review one ADR document against the code it decides about - every finding refuted before it reaches you. Reports the survivors and edits no text. Use when the user names an ADR and asks whether it is still true, still coherent, or still obeyed.
---

# dror-adr-review

This skill **finds**, in a written decision. It produces a report and STOPS,
editing neither the ADR nor a line of code.

An ADR is reviewed in two directions at once, and they are not the same
question:

- **The document about the code** — a sentence that describes a tree that has
  moved on. The document is wrong.
- **The code about the document** — a site that breaks a rule the ADR states.
  The document is right and the code is wrong.

Both are findings here because one read settles both, and they are told apart by
their **kind**, because they are repaired by different hands: the first by
`dror-adr-repair`, the second by `dror-repair`, which fixes code and this
skill's companion never does.

## What this skill assumes

Like `dror-show-tickets`, this one is **convention-bound**: it assumes ADRs at
`docs/adr/<NNNN>-*.md`, four digits, zero padded. A repo that keeps its
decisions somewhere else gets one sentence saying so, and the user may name a
path instead — a path given explicitly is always honoured, whatever the layout.

Everything else about the project arrives through the facts below.

## Learn the project first

Invoke the `dror-internal-project-facts` skill and carry what it returns into every agent
prompt: the domain vocabulary is what the `neighbours` lens reads drift
against, and the declared scope marks which findings are noise — an ADR
describing a retired directory is describing something nobody will fix.

That skill is a **step of this one**, not a hand-off: the moment the facts are
in hand, continue at **Read the ADR** in the same turn.

## Read the ADR

Find `docs/adr/<NNNN>-*.md` for the number given, or open the path given. No
match ends the run: say so and stop, and do not guess which decision was meant.

**Read it whole, here, before anything is spawned.** It is one document of a few
hundred lines, every lens needs all of it, and reading it once in this context
costs less than each agent reading it for itself. Then find, in this order:

- **Its date and its commit.** `git log -1 --format='%h %ad' -- <path>` — when
  the document last moved. A claim in an ADR nobody has touched in a year is not
  wrong for being old, but the age is what a reader weighs a survivor against,
  so it goes in the report.
- **What the code has done since.** `git log --oneline <commit>..HEAD` over the
  paths the ADR names. This is the review's best lead: the drift is where the
  code moved after the decision was written down.
- **Its neighbours.** The other files in `docs/adr/`, by title alone — the
  `neighbours` lens reads the ones that touch the same subject, and nothing else
  needs them.
- **Its tickets.** The spec issue naming this ADR and its children, bodies and
  all, found the way `dror-show-tickets` step 2 finds them. One `gh` call here,
  once, and the bodies are handed to the `tickets` lens — a lens that shelled out
  for them itself would pay for the same listing again. A repo with no reachable
  tracker, or an ADR with no ticket set, drops the lens and says so in the
  report; an **inferred** set is passed with that word attached, so the lens
  weighs it accordingly.

An ADR that is a stub — a title and no decision — ends the run with that one
sentence. There is nothing to refute, and a lens pool run over it would invent
six findings that all say the same thing.

## Run the lenses

[`LENSES.md`](LENSES.md) is a **pool**, not a running order. Choose the ones
this ADR raises and run each as one agent, all launched in parallel, each given
the ADR's path and its full text, the project facts, the paths the ADR names,
and `LENSES.md`'s preamble plus its own lens section, verbatim.

Choosing is this skill's job, not the user's. Skip a lens whose concerns the
document never raises — an ADR that states no rule anything could break needs no
`breach` agent; one with no sibling on its subject needs no `neighbours`.
**Five at most**, whatever the ADR's length. Where more than five qualify, keep
the ones the document most obviously raises and say in the report which were
dropped, so a reader knows what was not looked at.

**`tickets` runs whenever tickets were found, as a sixth agent beside the five,
launched in the same parallel batch.** It reads issue bodies rather than the
tree, so it competes for none of the read budget the cap exists to protect and
costs no wall-clock beyond the batch, and it is the one lens whose subject
is work not yet done — dropping it lets a stale criterion be implemented
correctly, which no later run of any lens catches. No tickets, no lens: say so
in the report like any other that was not run.

`claims` and `breach` are the two that earn their place on nearly every run:
between them they are the whole question of whether the document and the tree
still agree. `misreading` is the third, wherever the ADR states rules somebody
will act on — every other lens asks whether the document is true, and that one
asks whether it will be obeyed as meant, which nothing downstream ever catches.

**Lenses run on the cheap model, refuters on the strong one.** Pass
`model: "sonnet"` to every lens agent and leave the refuters on the session's
own. Spend the tokens where the judgement is.

**Cap what a lens reads.** The ADR, and the files it names plus their direct
callers. A lens that cannot reach a verdict inside that boundary says so and
returns the question rather than widening — reading a subsystem to settle one
sentence is the refuter's budget to spend, on one finding.

## Merge

Two lenses reading adjacent paragraphs report one defect twice. Group the
returned findings by the **ADR line** they name and by what they claim is wrong,
before anything is refuted: findings that name the same defect become one,
keeping the clearest statement, and noting every lens that raised it. One
defect, one finding, whatever found it.

A `text` and a `breach` finding about the same rule are **not** a duplicate —
they are the two readings of one disagreement, and which of them is right is the
refuter's job to settle. Keep them separate through the merge and let the
refutations decide; collapsing them here would pick the winner before anyone
looked.

## Refute

Hand each merged finding to one independent agent, all launched in parallel —
one refuter per finding, however many survived the merge, with **no cap**. Each
is given: its finding; the project facts; the ADR's full text; and
[`REFUTING.md`](REFUTING.md) verbatim.

Every suspect is checked. Cutting the list here would put unchecked suspicions
in the report, and a reader cannot tell an unchecked finding from a confirmed
one. The cost is controlled before this point — fewer lenses, a tighter read
boundary, and lenses that kill their own weak findings rather than passing them
on.

Survivors are the report.

## The kinds

Every survivor carries exactly one, and the kind is what decides whose work it
is next:

- **`text`** — the document says something about the code that is not true, or
  is no longer true, or is unreadable enough that two readers act differently on
  it. Repaired by `dror-adr-repair`.
- **`hole`** — the document is missing something a decision record has to carry:
  the alternative it was chosen over, a consequence that followed, the scope of
  what it supersedes, the migration it implies. Repaired by `dror-adr-repair`,
  and only where the missing sentence can be **grounded** — an alternative
  nobody recorded is not one this skill invents.
- **`breach`** — the code breaks a rule the ADR states, at a named `file:line`.
  The document is fine. This is a bug report that happens to have been found by
  reading a document, and it goes to `dror-repair` untouched — naming it here
  and fixing it there is the same split as everywhere else in this chain.
- **`conflict`** — two decisions disagree: this ADR against another, or against
  itself. **Nobody repairs this without the user.** Which side is right is a
  decision, and a skill that picks one has written an ADR nobody approved.
- **`revisit`** — nothing is wrong. The document is true, coherent and obeyed,
  and what it **predicted** has not held: the measurement it stood on now reads
  differently, the consequence it promised did not arrive, the cost it accepted
  has outgrown the acceptance, or the reason its rejected alternative lost no
  longer applies. It is a finding because it is the strongest reason to reopen a
  decision and the one nobody checks — the document is not wrong about anything.
  **Nobody repairs it either**: there is no wrong sentence to correct, and
  whether to reopen is the user's. It carries both numbers, the predicted and
  the measured, or it is an opinion about somebody else's decision.

A finding a refuter could not settle says so on its line and keeps its kind.

## Write the report down

`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill — holds
the naming, identity, finding-id and log rules every `dror-*` report obeys, in
one copy. Read it whole before writing anything, and take this run's name from
it. It is not restated here.

Number the survivors: `conflict` first — it is the kind that blocks
somebody — then `breach` in the order of the damage a violation does, then
`text`, then `hole`, then `revisit` last, which is the only kind that asks for
nothing to be fixed. Save them under the name the reference gives, overwriting
the previous one. It is a separate file from the code review's on purpose: a code
review and an ADR review are started for different reasons and neither should be
able to erase the other's findings.

Front matter first: **the ADR this report is for** — `ADR: <n>`, the identity
line — with its title and path; the commit `HEAD` was at; the commit and date the
ADR itself last moved; **the time this report was written** (`date +%H%M`, the
same call the log's date comes from); and **this run's tag**. Both commits are
recorded because either one moving is what makes a finding stale — a repair run
reads them to say so; the time and the tag are what the finding id below is built
from.

**Mint a run tag** — four hex characters from `openssl rand -hex 2`, or the last
four of `date +%s` where that is not there — unless the caller gave one, in which
case that is the tag. It does not change the report's name, which the reference
derives from the ADR; it identifies the *run*, so two reviews of one ADR at one
commit inside one minute cannot mint one id twice.

Then one section per finding, numbered as on screen, each with:

- its **id**, minted by the reference's rule from the front matter's commit, this
  run's tag, the report's own time and the finding's number;
- the **ADR line or quoted sentence** it is about, and the `file:line` in the
  code it was judged against;
- its **kind**;
- what is wrong, in one or two sentences;
- for a `text` or `hole`, **what would make it true** — the corrected fact, with
  the evidence the refuter stood on. Not the replacement prose; that is the
  repair's writing, and a review that drafts it has done the repair badly and in
  the wrong run.

**A finding is about fifteen lines.** This file is read start to finish by a
repair run and by you tomorrow, so it carries what is needed to act and not the
refuter's route. Also name the lenses that were **not** run, since a reader
cannot tell an area that came back clean from one nobody looked at.

**Then record the kills.** A last section, `## Refuted`, holding every finding
that did *not* survive: its id, the sentence it was about, the lens that raised
it, what it claimed, and why the refuter killed it. Number the kills on from the
survivors, so every merged finding has an id and the two sections never mint the
same one twice. One short paragraph each, no
scenarios — nothing downstream acts on these. It is the run's only record of its
own precision.

## Append to the log

The report is overwritten every run, so every **merged finding**, survivor and
kill alike, is also appended as one line to `~/.claude/dror-skills/refutations.tsv`
— the same log `dror-review` writes, on the reference's terms for every log. The
`lens` column keeps the two pools apart; nothing else has to.

One tab-separated line per finding, the columns `dror-review` owns, in its
order: `date` (from `date -I`) · `repo` (the directory name) · `head` (short
commit) · `lens` · `path` — **the ADR's repo-relative path**, which is what this
run reviewed, even for a `breach` whose evidence sits in code · `kind` (text /
hole / breach / conflict / revisit) · `verdict` (survived / refuted / unverified) ·
`claim` (always `no`: this skill writes no claim comments, and the column stays
so the two pools share one schema) · `summary` (under 80 characters, no tabs) ·
`id` (the report's `<head>-<tag>-<hhmm>-<n>`, copied whole).

**The `id` column is what lets a `breach` be followed.** A breach goes to
`dror-repair`, which writes a `repairs.tsv` row only for a finding that carried
an id — so an ADR review that minted none put its findings beyond every question
the logs exist to answer, while sharing their schema. Where the header does not
name `id`, it arrives on the header line, as any added column does.

**The `lens` column is a closed vocabulary**: a section name from this skill's
[`LENSES.md`](LENSES.md), or one from `dror-review`'s. Nothing else may be
written there — a name outside that set silently corrupts every rate
`dror-review-retrospective` computes. The two vocabularies are disjoint, which is
what lets one log hold both pools and a reader tell them apart. Where the merge
joined several, join their names with `+`.

## Record the run itself

A lens that ran and found nothing writes no line above, so the log alone cannot
tell an ADR that came back clean from one nobody looked at, and every rate
computed from it is missing its denominator. The report says which lenses were
dropped; that fact dies with the report unless it is written where later runs can
read it.

So append one line to `~/.claude/dror-skills/runs.tsv`, on the same terms as the
log above — the same file `dror-review` writes, whose rows the disjoint lens
names keep readable apart:

`date` · `repo` · `head` · `lenses_run` (the closed names, joined by `+`) ·
`lenses_dropped` (the same, or `-`) · `findings` (how many merged findings this
run produced, kills included) · `run_tag` (this run's tag) · `concurrent`
(**`unchecked`**, or the tags a caller told this run it saw, joined by `+`).

**Never `-` here.** In `dror-review`'s rows that value means *a check ran and saw
nobody*; this skill runs no check of its own, and writing `-` would put "looked
and found none" and "never looked" under one value in one column. `unchecked` is
the honest word, and a caller that did look — `dror-adr-review-repair` does, once
before its first round — passes what it saw, which is then written instead.

One line per review, whether it found anything or not — a run that produced no
findings is exactly the run the log cannot see, and the only one this file exists
to record.

## Present

Show the same numbered list, in that order, each line naming its kind. Under it,
say in one sentence which findings are this chain's next work and whose: the
`text` and `hole` ones go to `dror-adr-repair`, the `breach` ones to
`dror-repair`, and a `conflict` or a `revisit` waits for the user — the first
because somebody must choose, the second because nothing is broken. Then stop and wait.

Name the report file this run wrote, since a repair run has to be pointed at it
and only this run knows which name it took, and say this run's tag once.

Then **one line saying whether a repair should follow**, and why in half a
sentence. It is a judgement the count cannot make: a stale sentence and a
decision nobody may repair are one survivor each, and only this run has met them.
Three answers — *yes*, naming which findings need the edit; *no*, where every
survivor is something to know rather than something to change; *the user's call*,
where a `conflict` or a `revisit` is the whole list and choosing is theirs. It
binds nobody; a looping caller reads this line to decide whether to spend a
repair at all.

Done when every lens has returned, the findings have been merged, every merged
finding has faced a refuter, this run's report file holds the survivors and the
refuted with an id each, every merged finding has a line in
`~/.claude/dror-skills/refutations.tsv`, the run has its line in
`~/.claude/dror-skills/runs.tsv`, the repair-or-not line is on screen, and
that same list is on screen — with no line of the ADR and no line of code
changed.
