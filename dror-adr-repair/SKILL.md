---
name: dror-adr-repair
description: Repair an ADR's text from findings already made - every corrected sentence grounded in the code it describes, and no decision rewritten. Use when asked to fix an ADR review's findings, or to bring a named decision document back in line with the tree.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-adr-repair

Repair the ADR text a review has already found fault with. Works the whole list
in one run.

**It writes prose and nothing else.** No production code, no tests. A finding
that says the *code* is wrong is not this run's to fix — it is named and handed
on. Prose wherever it lives counts: the ADR, the conventions doc, the glossary,
a README index, a module docstring, and the body of a ticket. A docstring is
edited only when a finding names it and only as text; the line below it is not
this run's. A ticket body is the same writing with a different destination — it
says what to build and builds none of it, and the code that answers it is
somebody else's run. That is the same split as everywhere in this chain, and it
is what keeps a document repair from quietly changing behaviour to make a
sentence true.

**Every finding is on the list.** The default is the whole report, or everything
the findings file names. The user subtracts from it — "skip 3", "leave the
holes" — and may add a finding of their own; naming a few is not a way of
choosing only those. Work that list and only that list; discovering further
faults is `dror-adr-review`'s run.

This skill is **repo-agnostic** (ADR 0011), unlike the two it sits between: it
names no tracker, no path and no decision directory of its own, because it is
handed the document rather than asked to find one. `dror-adr-review` and
`dror-adr-review-repair` take an ADR by number and are convention-bound for that
reason; nothing of theirs reaches this file. Everything about the project in hand
arrives through the facts below.

## The one thing this skill may not do

**It may not change what was decided.** An ADR is a record of a decision taken
at a moment, and rewriting the decision to match today is not a repair — it is a
new decision with no author and no date, written into a file that claims
somebody approved it.

So the line is drawn at the sentence's job:

- A sentence that **describes** — the code, the layout, a number, a mechanism, a
  name — is repaired freely, to whatever the tree says now.
- A sentence that **decides** — what was chosen, over what, and what follows — is
  left alone. Where it has become wrong, what is added is a note saying so, in
  the document's own voice, naming what changed and when. The decision stays
  legible; the record grows a line.
- A **conflict** between two decisions is not repaired at all. It goes back to
  the user with both passages quoted.

Where a finding cannot be repaired without crossing that line, say so and leave
it: an item recorded as `Needs a decision` is a finished outcome of this run,
not a failure of it.

## Start from the written report if there is one

The last ADR review's report holds its findings with their quoted sentence, kind
and evidence. Read it and work from it.

**Which file it is, and whether it is yours, the reference answers.**
`../dror-internal-shared/REPORT-STORE.md` — the shelf beside this skill — holds
the naming, identity, staleness, finding-id and log rules every `dror-*` report
obeys, in one copy. Read it whole before working from a file. It is not restated
here.

Its `## Refuted` section is **not** the list. Those findings were raised and then
disproved, and repairing one is editing a true sentence to satisfy a mistake.
The user has to name it explicitly before it counts.

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
stamp matched the tree (ADR 0037). The **domain vocabulary** is the one that
matters most here — a repaired sentence is written in the project's own words,
and a repair that introduces a synonym for a term the glossary already fixes
has made the document worse while making it true. The declared scope matters
too: a sentence describing a retired directory is repaired to say it is
retired, not updated to track it. A block that begins `MISS:` means
the store could not answer: invoke the `dror-internal-project-facts` skill — it
gathers in a subagent, rewrites the store and returns the five facts — and hold
what it returns as the facts from then on. That skill is a **step of this
one**, not a hand-off; `../dror-internal-shared/DELEGATION.md` owns what that
means, at authoring time. Either way, the moment the facts are in hand,
**spawn step 1's grounding agents, one per item, in the same turn** —
step 1 is read-only and runs fanned out, so the first call after the facts is
the fan-out itself.

## The evidence a document repair stands on

A code repair proves itself by watching a test go **red** and then **green**.
There is no such thing for a sentence, and pretending otherwise is how a
plausible correction ships. So this skill's evidence is different in kind, and
it has its own two words:

- **grounded** — the corrected sentence was read out of the tree as it stands
  now, and the run can quote the `file:line` or command output that says it.
  Every sentence this run writes is grounded.
- **ungrounded** — nothing in the tree settles it. The sentence is **not
  written**. What the run produces instead is the question, put to the user.

The report's own evidence is not enough on its own. It was gathered by a refuter
in an earlier run against a tree that may have moved, and it was compressed to
the finding length `../dror-adr-review/SKILL.md` sets. Step 1 re-reads it. That
re-reading is the whole of this skill's rigour: a document repair has no suite
to catch it.

## Step 1 — Ground

For every item, go to the code and settle what the sentence should say. Produce,
per item: the quoted sentence, the `file:line` (or command output) that settles
it, and the corrected **fact** — still not the prose.

An item that comes back **ungrounded** is carried to step 2 and written into
nothing. An item whose finding turns out to be **wrong** — the tree says what
the document already said — is carried the same way and reported as not
reproduced, with the evidence quoted. Neither is an error; both are the ordinary
outcome of checking.

An `unticketed` item is grounded **three ways, not two**. The ordinary two still
hold: the decision is in the ADR, quoted, and the code does not do it. The third
is what stops this run filing a duplicate — **search the tracker, open rows and
closed alike, for a ticket that already carries the work**. A hit ends the item
as not reproduced, with the number quoted. Which tracker, and the command that
reads an issue, are the facts block's issue convention; a facts block that names
none cannot answer, and the item carries that word to step 2.

A `breach` item is grounded like the others and then **stops here**: confirm the
site still violates the rule, quote it, and carry it as work for `dror-code-repair`.
Nothing is written for it. A `revisit` item stops here too, and for the opposite
reason: nothing is wrong, so there is no sentence to correct — re-read the two
numbers it carries, confirm they still read that way, and carry it to the report
as a question for the user.

### Fan out, one agent per item

This step is read-only, so it parallelizes cleanly: spawn one subagent per item,
all at once. Each is told: the finding with its quoted sentence and kind, the
path of the store's `facts.md`, the ADR's path — paths, never their contents
(ADR 0038) — and that it **writes nothing** — not the ADR, not
source, not a scratch note in the tree. It returns the corrected fact with its
evidence, or `ungrounded` with what could not be settled, or `not reproduced`
with the passage of code that agrees with the document — or, for an
`unticketed`, the number of the ticket that already carries the work. Filing
one is nobody's here: an agent that writes nothing writes no issue either.

Grouping is by item and not by file because every edit lands in one document,
which is precisely why the *writing* below is not parallelized.

Done when every item is grounded, ungrounded, not reproduced, or carried as a
`breach` or a `revisit`, with the evidence on screen for each.

## Step 2 — Write

**This step is serial and stays in this context**, and that is a decision rather
than an omission. Every edit lands in one file, and a document's edits are not
separable the way test files are: two corrections meeting in one paragraph is
the ordinary case, and the second writer would be editing text the first has
already moved. Prose consistency is also a judgement about the whole document,
which an agent holding one sentence cannot make.

- **Edit the sentence, not the section.** The smallest change that makes it
  true. A rewritten paragraph hides the correction inside a diff nobody can
  read, and it costs the document its author's voice.
- **Match the document's voice.** Its tense, its terminology, its level of
  detail. An ADR that speaks in short declaratives does not acquire a bulleted
  list because this run prefers one.
- **Use the project's words** — the glossary's term, not a synonym.
- A **`hole`** is filled with the grounded sentence and no more. Where filling
  it means recording an alternative or a consequence, it is written as what it
  is: a fact recovered now, not a claim about what the authors weighed then.
- **Fix what the fix makes untrue, inside the document and outside it.** A
  corrected name that appears three times in the document is corrected three
  times; a link that the correction breaks is repaired. Grep the document for the
  old spelling before moving on.

  **Then grep the copies**, for every rule this run stated for the first time or
  restated differently — the conventions doc, the glossary, the module docstring
  at the site, the README index, the developer documents the ADR names. A rule
  written here for the first time has no copy that carries it, and a rule
  restated here leaves every copy saying the old thing. **No `echo` finding can
  have named these**: the copies agreed with the document when the review ran,
  and this run is what made them disagree. Synchronise them in their own
  registers, by the `echo` bullet's rules, and name each one in the report.

  **Then the tickets, on the same terms.** A ticket's acceptance criteria are the
  copy of the decision that gets *implemented* — whoever builds the thing reads
  the criteria and not the ADR behind them — so a rule this run rewrote leaves
  every criterion resting on the old wording about to be built wrong. Read the
  ADR's ticket set, and where **this run's own writing** made a criterion or a
  body stale, correct it: the smallest edit that makes it match, in the ticket's
  own voice, quoting the ADR's words where the rule is exact. A ticked criterion
  is corrected the same way and the tick is left alone — it records what was
  built, and this run does not know whether the build still satisfies it; say so
  beside the edit.

  **This one edit needs no yes**, and it is the single exception to §A ticket is
  written here and filed only on a yes. Filing creates an issue; this changes an
  issue that already exists, to say what the document it was cut from now says.
  Leaving it stale is not the safe half of the choice — it is the one that ends
  in wrong code.

  Which tracker, and the command that edits an issue, come from the facts block's
  issue convention. **A facts block naming no tracker cannot do this**: name the
  criteria that went stale, in the report, and edit nothing.

  This is not a licence to sweep, in the documents or the tracker. It reaches
  **only what this run's own writing made untrue** — step 3's third search still
  governs every other document, and a ticket that disagreed with the ADR
  *before* this run touched it is a `conflict` for the user, exactly as the
  review's `tickets` lens minted it.
- **Never delete a decision.** Superseded text is marked as superseded, with
  what replaced it. Deleting it destroys the only record that the question was
  ever settled the other way.
- **An `echo` item is repaired in every copy it names**, in one pass, before
  the next item starts. Repairing three of four leaves the fourth to be found
  again next quarter, and the ADR is rarely the copy that governs behaviour —
  the conventions doc is, because that is what gets read on every run. Each copy
  is corrected in *its own* register: the ADR keeps its detail, a one-line
  paraphrase stays one line, a docstring stays at the site's level. Making them
  identical is not the goal; making none of them say something different is.
  Where the finding says a copy is **missing**, write it where the finding says
  it should be echoed, in that document's own form.

- An **`unticketed`** item is written as a **ticket**, and the ADR is not
  touched for it. The document already decides the thing; a line added to it
  saying so would make missing work read as done. The draft carries four
  things — a **title**, the **parent** it hangs from, **what to build**, and
  **acceptance criteria** a later run can tick, each one checkable. Its wording
  is the ADR's own, quoted where the rule is exact.

  **A criterion states a property of the tree, where one can be written.** "The
  three keys are gone and nothing writes them" is a property of the tree; "no
  test was deleted to make the bar green" is a property of the diff and of the
  author's conduct, which no test in that tree can hold and which therefore ends
  as a hand check somebody has to judge. That guard is real and worth keeping —
  put it in `## What to build`, where the review reads it, rather than in a box
  that can only ever be ticked by hand. Where the property genuinely is about a
  transition — a value moved once, an old key read and never written again — the
  criterion says so and stays; the rule is a preference for the testable
  wording, not a ban on the others.

The ADR's own metadata — its title, number and any status line the project keeps
— is left alone unless a finding named it.

### A ticket is written here and filed only on a yes

Filing creates an issue other people see and other runs pick up. That is an
outward action, and no report is a yes to it. So the tracker's create command
runs **only when this run was handed a yes** — the invocation said to file, or
named the parent to file under. Absent that, the draft is written and nothing
is filed.

**This governs creating, not correcting.** Step 2's sweep edits an existing
ticket whose criteria this run's own writing made stale, and it needs no yes: the
issue is already there and already read, and the choice is not whether to add
something to the tracker but whether to leave a criterion saying what the ADR no
longer says. Nothing else about an existing ticket is this run's to touch.

**This run cannot ask mid-way and must not pretend to.** It is forked, so its
text reaches nobody until it returns (ADR 0042); §Start from the written report
holds what becomes of a question here — it goes back as the result and whoever
invoked this puts it. So an unfiled draft goes into the report **whole**, with
the question under it, and the yes reaches a later run as an argument.

**Which tracker, and whether there is one, come from the facts block and from
nowhere in this file** — its issue convention names the tracker, the command
that reads an issue and how a child names its parent, which is what keeps this
skill repo-agnostic. A facts block naming none has nothing to ask about: leave
the draft in the report and say so.

Done when every grounded item has an edit behind it — a drafted ticket for an
`unticketed` one — and every other item has a recorded reason it has none.

## Step 3 — Check

The document has no suite, so the check is a reading and two searches:

1. **Read the ADR whole, top to bottom, after the edits.** A document repaired
   sentence by sentence acquires contradictions between the repaired sentences.
   This is the one step that catches them, and it cannot be delegated to an
   agent that saw only its own item.
2. **Resolve every link** the document carries — relative paths to other ADRs
   and to source files. A repair that renames a path in prose and leaves the
   link is the defect this run was called to fix.
3. **Search the tree for the old spelling** of anything renamed, in `CLAUDE.md`,
   `CONTEXT.md`, the README index and the other ADRs. A hit a finding named is
   already repaired by then, under its `echo` item, and so is one this run's own
   writing made stale — step 2's "Fix what the fix makes untrue" reached that one.
   A hit **no finding named and this run did not cause** is
   the review's miss, not this run's licence: name it in the report and leave it,
   because an edit nobody refuted is exactly what this chain's two-run split
   exists to prevent. Where there are several, say so plainly — it is the signal
   that the next `dror-adr-review` should run `echoes`.

Where the project declares a docs check of its own — a link checker, a
formatter, a spell pass — run it and paste its output.

The editing ends here, leaving the edited files for the user to read and commit.
Three things are still owed before the run ends: the report below, the
`repairs.tsv` append after it, and the review-owed line last.

## Report

Two things per item, answered separately, because what the review named and what
this run did about it are different facts. The finding is a neutral observation;
the outcome carries the verdict.

- **What was found** — the kind of thing, in a word. An open vocabulary; the
  usual ones:
  - `stale` — the document described a tree that has moved.
  - `wrong` — the document was never right.
  - `unclear` — true but readable two ways.
  - `hole` — something a decision record must carry was missing.
  - `unticketed` — the ADR decides something no ticket asks for. Not a `hole`:
    the document is whole and the *work* is missing.
  - `echo` — the rule is right here and wrong in a copy of it elsewhere.
  - `breach` — the code violates the document's rule. The document is fine.
  - `conflict` — two decisions disagree.
  - `revisit` — nothing is wrong and what the decision predicted has not held.
- **Repair's outcome** — what this run did. Also open; the usual ones:
  - `Corrected (grounded)` — the strong claim: the fact was read out of the tree
    this run, and the sentence now says it. The note carries the `file:line`.
  - `Filled (grounded)` — a `hole` closed with a sentence the tree supports.
  - `Marked superseded` — a decision that has been overtaken; the text stays and
    a line records what replaced it.
  - `Synchronised` — an `echo`: every copy the finding named now says the same
    thing. The note lists them, and a copy left alone says why.
  - `Ticket drafted` — an `unticketed` written up. The note carries the **issue
    number** where this run was told to file, and the **draft itself** — title,
    parent, what to build, acceptance criteria — where it was not. The draft is
    the work either way; the number only says it landed.
  - `Left — needs a decision` — repairing it would rewrite what was decided; or
    it is a `revisit` and nothing is broken; or it is an `unticketed` and
    whether the work is wanted at all is the user's. Names the question the user
    has to answer, and for a `revisit` both numbers.
  - `Left — ungrounded` — nothing in the tree settles it. Names what is missing.
  - `Not reproduced` — the tree agrees with the document. Nothing changed, and
    the evidence is quoted.
  - `For dror-code-repair` — a `breach`, confirmed and handed on, with its
    `file:line`.
  - `Duplicate of N` — it and item N are one fault; N carries the repair.
  - `Deferred` — real, and left on the **user's** instruction.

Never pair a finding with an outcome that contradicts it:

- `breach` ends in `For dror-code-repair` or `Not reproduced`, never in a
  `Corrected` — editing the document to match code that breaks its rule is how a
  rule is lost.
- `conflict` and `revisit` end in `Left — needs a decision`, never in a
  `Corrected` — the first because somebody must choose, the second because there
  was never a wrong sentence to correct.
- `unticketed` ends in `Ticket drafted`, `Not reproduced` or
  `Left — needs a decision`, never in a `Corrected` — no sentence of the
  document is wrong, so an edit to it is prose written to cover missing work,
  and it makes the work look done to the next reader.
- `echo` ends in `Synchronised`, never in a bare `Corrected (grounded)` — the
  outcome has to say that every copy was reached, since reaching one is the
  failure this finding exists to prevent.
- A `Corrected (grounded)` with no `file:line` in its note is not grounded, and
  the row is wrong.

Run `printenv CLAUDE_CODE_ENTRYPOINT`. If it is `claude-vscode`, report one row
per item: **Item | Sentence | What was found | Repair's outcome | Evidence |
Note**. `Sentence` is the quoted fragment, shortened. `Evidence` is the
`file:line` or `—`.

Otherwise report the same rows as one line each, in the same order, reading
`<item> — found: <kind> — outcome: <outcome> — evidence: <file:line or none> —
<note>`.

Below the rows: every copy this run's own writing made stale and then
synchronised, each named with what it now says, and every **ticket** it corrected
for the same reason, **by number**, with the criterion quoted before and after —
they belong to no item, so a row cannot carry them, and a corrected criterion
nobody names is an outward edit that left no trace. A ticket named here and *not*
edited says why: a ticked criterion whose build this run cannot vouch for, or a
facts block with no tracker. Then the other-document hits from step 3, the docs-check output, and
every unfiled ticket draft in full — title, parent, what to build, acceptance
criteria — with the question under it. A draft abbreviated to a row is lost:
this report is the only place it exists. Then mark the report — **the file this run read**, never the store's
default name where they differ. Add to every finding this run handled a line
saying what became of it, and leave the rest of the file as it stands, so a
later run skips what is already done.

## Say what became of each finding

A review scores a finding as *survived* the moment a refuter fails to kill it,
and nothing revisits that. This run is where a survivor meets the tree: one turns
out not to be reproduced, another cannot be grounded at all. Until that is
written where a later run can read it, every one of them stays on the record as a
success.

So for every finding that carried an **id** in the report, append one line to
`~/.claude/dror-skills/repairs.tsv` — the same log `dror-code-repair` writes, on the
store reference's terms for every log:

The columns and their order are the store reference's (`REPORT-STORE.md`, "The
logs"), stated there once, including the cap on `files_edited` and the rule that
the same values go on every row this run appends. This run's own values: `outcome` is the word from this run's report — `Corrected (grounded)`,
`Left — ungrounded`, `Not reproduced`, … — and `production` is **always `no`**,
since this skill writes prose and nothing else; the column stays so the pools
share one schema.

A report whose findings carry no id — one written before ids existed, or one this
skill was not given — records nothing here, and that is not a failure: the join
has no key, and a line keyed on a guess is worse than an absent one.

## Say whether another review is owed

The last line of the run, and the one a **looping caller** reads: does the
document this run leaves behind need reviewing again? Answer in a word with the
grounds in half a sentence, and name what was edited.

- **yes** — prose was written, so there are now sentences no review has read.
  Strongest where an edit reached a document the findings never named, or where
  an `echo` was synchronised across several copies. **A ticket this run filed or
  corrected counts**: the ticket set is what the review's `tickets` lens reads,
  and it has moved. A draft that was not filed does not — nothing outside this
  report has changed.
- **no** — nothing was written at all: every item was `Not reproduced`,
  `Left — ungrounded`, `Left — needs a decision`, an unfiled `Ticket drafted`, or
  handed to `dror-code-repair`. A
  run that changed no file leaves nothing for a further pass to read.
- **the user's call** — the document moved only in the narrow way each finding
  described, and the run has nothing further to suggest.

It is a **report, not a decision**: this skill neither reviews nor loops, and
whether the next round is worth its cost belongs to whoever called. Answer it
even when nobody asked — a caller that does not want it ignores one line.
