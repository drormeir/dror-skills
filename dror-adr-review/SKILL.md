---
name: dror-adr-review
description: Review one ADR document against itself, its tickets and the code it governs - every finding refuted before it reaches you. Reports the survivors and edits no text. Use when the user names an ADR and asks whether it is still true, still coherent, or still obeyed - most often as a preliminary pass, sharpening the decision before its tickets are implemented.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-adr-review

This skill **finds**, in a written decision. It produces a report and STOPS,
editing neither the ADR nor a line of code.

**An ADR is not reviewed against one thing.** Sometimes it is checked against
itself, sometimes against its own tickets, sometimes against the code it was
written to govern — and usually some combination, because one read of the
document settles several of them at once. The lens pool is organised on that:
five **axes**, each admitting a different kind of evidence, set out in
[`LENSES.md`](LENSES.md)'s preamble.

- **Against the code**, in both directions, which are not the same question: a
  sentence describing a tree that has moved on (the document is wrong), and a
  site that breaks a rule the ADR states (the document is right and the code
  is).
- **Against itself** — a decision never taken sharply enough to write down, two
  passages that disagree, a consequence the decision forces and the document
  leaves unanswered.
- **Against other documents** — a sibling ADR deciding the same question
  differently, or a copy of this rule in the conventions doc or the glossary
  that has drifted from it.
- **Against its tickets** — a criterion that no longer matches the rule, which
  is a rule about to be broken by somebody following instructions correctly.
- **Against the reader** — a sentence that is true and gets acted on wrongly,
  which nothing downstream ever catches.

Only three of the ten lenses read code, so **a `file:line` is not what a finding
owes** — it is what one axis's findings owe. They are told apart by their
**kind**, because they are repaired by different hands: the document's fault
goes to `dror-adr-repair`, the code's to `dror-code-repair`, which fixes code and
this skill's companion never does.

## What this skill assumes

Like `dror-show-tickets`, this one is **convention-bound**: it assumes ADRs in
one of the conventional decision directories. How the number given becomes a
file there — and how a repo that keeps its decisions elsewhere is answered — is
`../dror-internal-shared/ADR-FILE.md`, the shelf beside this skill, which owns
that rule for every skill taking an ADR by number.

Everything else about the project arrives through the facts below.

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
to them: the domain vocabulary is what the `neighbours` lens reads drift
against, and the declared scope marks which findings are noise — an ADR
describing a retired directory is describing something nobody will fix. A block that begins `MISS:` means
the store could not answer: invoke the `dror-internal-project-facts` skill — it
gathers in a subagent, rewrites the store and returns the five facts — and hold
what it returns as the facts from then on. That skill is a **step of this
one**, not a hand-off; `../dror-internal-shared/DELEGATION.md` owns what that
means, at authoring time. Either way, the moment the facts are in hand,
**resolve the ADR number to its file, in the same turn**, by the next
section's rule.

## Read the ADR

Resolve the number given, or open the path given, by `ADR-FILE.md`'s rule. No
match ends the run: say so and stop, and do not guess which decision was meant.

**Read it whole, here, before anything is spawned.** Choosing the lenses is
this skill's job and it cannot be done unread. Every agent needs all of it too,
and each reads it for itself from the path it is given: text this run writes
into a prompt is output tokens, paid once per agent and then held in this
context for the whole run, while a path costs one read in an agent that is gone
when it returns (ADR 0038). Then find, in this order:

- **Its date and its commit.** `git log -1 --format='%h %ad' -- <path>` — when
  the document last moved. A claim in an ADR nobody has touched in a year is not
  wrong for being old, but the age is what a reader weighs a survivor against,
  so it goes in the report.
- **What the code has done since.** `git log --oneline <commit>..HEAD` over the
  paths the ADR names. This is the review's best lead: the drift is where the
  code moved after the decision was written down. Redirect it into a scratch
  file — the code-axis lenses are given its path below, so the lead is spent
  once and read by everyone it steers.
- **Its neighbours.** The other files in the directory the ADR resolved in — not
  a fixed path, and not the whole repo — by title alone; the
  `neighbours` lens reads the ones that touch the same subject, and nothing else
  needs them.
- **Its tickets.** The spec issue naming this ADR and its children, bodies and
  all, found the way `dror-show-tickets` step 2 finds them. One `gh` call here,
  once, its output redirected into a scratch file whose path the `tickets` lens
  is given — a lens that shelled out for them itself would pay for the same
  listing again, and bodies written into its prompt would be paid for here. The
  lens's prompt names the spec and child **numbers**: the listing holds the
  whole tracker, and which rows are the set is this read's finding to hand on,
  not the lens's to re-derive. A repo with no reachable
  tracker, or an ADR with no ticket set, drops the lens and says so in the
  report; an **inferred** set is passed with that word attached, so the lens
  weighs it accordingly.

An ADR that is a stub — a title and no decision — ends the run with that one
sentence. There is nothing to refute, and a lens pool run over it would invent
six findings that all say the same thing.

An ADR whose own status line marks it superseded or deprecated ends the run
almost as fast: say so, name the superseding document where the line names one,
and stop. Its drift from the tree is the record working, and the live decision
is the one a review sharpens.

## Run the lenses

[`LENSES.md`](LENSES.md) is a **pool**, not a running order. Choose the ones
this ADR raises and run each as one agent, all launched in parallel, each given
the ADR's path, the path of the store's `facts.md`, the paths the ADR names,
and the path of `LENSES.md` with the name of its lens — it reads that file
itself, and is told that the preamble and the section headed with its name bind
it while the other sections are other agents'. Paths, never contents. A
code-axis lens — `claims`, `breach`, `outcome` — is also given the path of the
drift log the read above saved: where the tree moved since the decision is
where its findings live, and a lens that starts there reads less to find them.
An empty log is a prior, not a verdict; the lens still works its bullets.

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

**Cap what a lens reads, on its own axis.** A code-axis lens gets the ADR, the
files it names and their direct callers. A lens on any other axis gets the ADR
plus the thing it is judged against and nothing more — the sibling ADRs and the
copies for `neighbours` and `echoes`, the named rows of the listing it was handed for
`tickets`, and for the three that read the document against itself, the document
alone. A lens that cannot reach a verdict inside its own boundary says so and
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
is given: its finding; the path of the store's `facts.md`; the ADR's path; and
the path of [`REFUTING.md`](REFUTING.md), to read whole. Paths, never contents.

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
  reading a document, and it goes to `dror-code-repair` untouched — naming it here
  and fixing it there is the same split as everywhere else in this chain.
- **`conflict`** — two decisions disagree: this ADR against another, or against
  itself. **Nobody repairs this without the user.** Which side is right is a
  decision, and a skill that picks one has written an ADR nobody approved.
- **`echo`** — the rule is right here and a copy of it elsewhere has drifted:
  the conventions doc, the glossary, a docstring at the site, a README index.
  The copy that gets read is the one that governs, so the finding names
  **every** copy with its `file:line`, and `dror-adr-repair` synchronises all
  of them at once. The `echoes` lens is what raises it.
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
`text`, then `hole`, then `echo`, then `revisit` last, which is the only kind that asks for
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

**Mint a run tag** by the store's recipe — unless the caller gave one, in which
case that is the tag. It does not change the report's name, which the reference
derives from the ADR; it identifies the *run*, so two reviews of one ADR at one
commit inside one minute cannot mint one id twice.

Then one section per finding, numbered as on screen, each with:

- its **id**, minted by the reference's rule from the front matter's commit, this
  run's tag, the report's own time and the finding's number;
- the **ADR line or quoted sentence** it is about, and **what it was judged
  against**, in the form its axis takes: a `file:line` in the code, the other
  passage of this document with its line number, the other document's own
  `file:line`, the ticket by number, or the wrong action a reader takes. A
  finding with no `file:line` is the ordinary case here, not an incomplete one;
- its **kind**;
- what is wrong, in one or two sentences;
- for a `text`, `hole` or `echo` — the three the repair writes prose for —
  **what would make it true**: the corrected fact, with the evidence the refuter
  stood on, and for an `echo` the `file:line` of **every** copy it names. Not the
  replacement prose; that is the repair's writing, and a review that drafts it
  has done the repair badly and in the wrong run.

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
— the same log `dror-code-review` writes, on the reference's terms for every log. The
`lens` column keeps the pools apart; nothing else has to.

One tab-separated line per finding — the columns and their order are the store
reference's (`REPORT-STORE.md`, "The logs"), stated there once. This run's own
values: `path` is **the ADR's repo-relative path**, which is what this run
reviewed, even for a `breach` whose evidence sits in code; `kind` is `text /
hole / breach / conflict / revisit / echo`; `claim` is always `no` — this skill
writes no claim comments, and the column stays so the pools share one
schema; `subject` is **the ADR's number**, the same one the identity line
carries; `round` is the round a looping caller named, or `-`; and `run_tag` is
this run's tag — the caller's where one was given, the minted one otherwise.

**`subject` holds an ADR number here and a ticket number in `dror-code-review`'s
rows**, which is safe only because the pools are never read against each
other — the rule for keeping them apart is
`dror-review-retrospective`'s, and it turns on the disjoint lens names rather
than on this column. A reader that groups by `subject` alone across pools
is comparing an ADR with a ticket that happens to share its number.

**The `id` column is what lets a `breach` be followed.** A breach goes to
`dror-code-repair`, which writes a `repairs.tsv` row only for a finding that carried
an id — so an ADR review that minted none put its findings beyond every question
the logs exist to answer, while sharing their schema. Where the header does not
name `id`, it arrives on the header line, as any added column does.

**The `lens` column is a closed vocabulary**: a section name from this skill's
[`LENSES.md`](LENSES.md), or one from `dror-code-review`'s. Nothing else may be
written there — a name outside that set silently corrupts every rate
`dror-review-retrospective` computes. The pools' vocabularies are disjoint, which
is what lets one log hold them all and a reader tell them apart. Where the merge
joined several, join their names with `+`.

## Record the run itself

A lens that ran and found nothing writes no line above, so the log alone cannot
tell an ADR that came back clean from one nobody looked at, and every rate
computed from it is missing its denominator. The report says which lenses were
dropped; that fact dies with the report unless it is written where later runs can
read it.

So append one line to `~/.claude/dror-skills/runs.tsv`, on the same terms as the
log above — the same file `dror-code-review` writes, whose rows the disjoint lens
names keep readable apart. The columns and their order are the store reference's
(`REPORT-STORE.md`, "The logs"), stated there once.

This run's own values: `lenses_run` and `lenses_dropped` carry the closed names
from this skill's [`LENSES.md`](LENSES.md); `concurrent` is **`unchecked`**, or
the tags a caller told this run it saw, joined by `+`; `round` and `subject` are
the same values the finding log's section above gives them; and `elapsed_s` is
the difference between a `date +%s` read immediately before the lenses are
launched and one read as this line is written, or `-` where the first reading
was not taken.

**Never `-` here.** In `dror-code-review`'s rows that value means *a check ran and saw
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
`text`, `hole` and `echo` ones go to `dror-adr-repair`, the `breach` ones to
`dror-code-repair`, and a `conflict` or a `revisit` waits for the user — the first
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
