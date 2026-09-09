---
name: dror-adr-sweep
description: Sharpen every ADR in a repo as one pre-implementation phase - dror-adr-review-repair over each decision in turn, one at a time in number order, under one phase tag, with every question the loops left written to one phase report and only a table on screen. Use when the user asks to check or repair all the ADRs before implementation starts, or to carry on a sweep that stopped.
disable-model-invocation: true
---

# dror-adr-sweep

One repository's decision directory goes in. The run works the set one document
at a time — `dror-adr-review-repair` per member, sequentially — and ends on one
table saying what each member cost and what it left behind.

It owns the **set**: which documents are in it, in what order, one at a time, the
phase's tag, where the phase stopped and how it starts again. It owns nothing
about a document: the rounds, the cap, the judgement of when one has converged
and what each round repairs are `dror-adr-review-repair`'s, whole and unedited.

**It is the phase before implementation.** An ADR is either a naked document or
already cut into tickets; either way no ticket has been worked. Sharpening the
whole set at that moment is cheaper than sharpening each decision as its turn
comes, because a tree that moves under a repaired document moves once rather than
seventeen times.

**It is convention-bound** (ADR 0011), inheriting the binding from
`dror-adr-review-repair`: it assumes ADRs in a conventional decision directory,
resolved by `../dror-internal-shared/ADR-FILE.md`, which owns that rule and its
escape hatches.

**Every delegated skill is a step of this one, not a hand-off.**
`../dror-internal-shared/DELEGATION.md` — the shelf beside this skill — owns what
a sub-skill's closing contract means to a caller and why every step below ends on
a named next action, at authoring time. A sweep that ended on its first member's
summary has swept one ADR.

## 0. This run does not fork, and that is deliberate

Every other skill the user runs to work the chain carries `context: fork`
(ADR 0036). This one does not, and `dror-adr-resume` is the precedent: forked, it
would spend a level of the harness's spawn-depth cap on bookkeeping, and every
member's loop would then sit one level deeper than the same loop typed by the
user. That loop already reaches the cap — `dror-adr-review-repair` →
`dror-adr-review` → its lenses and refuters — so the level this run would add is
paid by the refuters, which is where the review's whole precision lives. ADR 0043
owns the cap and its arithmetic, and ends on the rule this file obeys: **the
chain gains no depth.**

What a fork would have bought is not worth that. This run reads no source, holds
one line per member, and every member's loop is forked by its own frontmatter —
so the session this was invoked from never reaches a review, a repair, a lens or
a refuter. What it does hold is the phase, which is the one thing that has to
outlive a member.

**It takes nothing from the conversation all the same.** The arguments below are
what it works from; a directory or a focus mentioned earlier in the session is
not one.

**And it can ask.** Running in the session rather than in a fork, this skill may
put a question and wait — which a forked run cannot (ADR 0042). It spends that on
two things only: the go-ahead before a phase starts spending, and the resumption
question. Every other question belongs to a member's loop and comes back through
its summary.

## What this run is given

**No ADR number.** The set is named from the decision directory, which is
unambiguous, rather than from a number the user typed — so
`dror-adr-review-repair`'s stop on an unlabelled number is untouched and not
weakened here. A user who names one ADR wants that skill, not this one; say so
and stop.

Four optional arguments, and nothing else:

- A **focus** — one free-form sentence about why the set is being checked now. It
  is carried into every member's loop, which carries it into every round. What a
  focus does to a review is `dror-adr-review-repair`'s, which states that rule
  and writes it into the prompt of every review it runs.
- A **yes to file**, which every member's repair is then told. Filing an issue is
  an outward action; without the yes the members return ticket drafts and §The
  phase report collects them.
- **`from ADR <n>`**, which drops every member before that one from the set. The
  ordinary reason is a phase already half done under another name.
- **`resume`**, which is §The phase state file's question asked outright.

## 1. Resolve the set

**The directory first.** `../dror-internal-shared/ADR-FILE.md` owns where a
project's decisions live, and this step asks it the question it answers for a
whole set rather than for one file — its section on the directory asked for on
its own, including both stops, which are this run's stops as well.

**Then the members.** Every file in that directory whose name that same rule
would resolve a number to, which is what keeps a `README.md`, an index or a
template out of the set without a list of names to maintain. Nothing else in the
directory is a member.

**Resolve each member by its number, not by the path you just listed**, so a
decision being worked in a worktree of its own is read there rather than as the
stub the checkout holds — the same rule, one file, `ADR-FILE.md`'s. Say on screen
where each member resolved when it was not the directory you listed.

**An empty set ends the run** — the directory exists and holds no decision. Say
so; there is nothing to sharpen and no phase to report.

## 2. Order it

**Ascending ADR number.** Print the order before the first member.

The order matters because a repair grounds every sentence it writes in the tree
as it stands, and a document that cites another is grounded against the citation
as it was when its turn came. Numbers are the cheapest ordering that puts a cited
document first: decisions are numbered as they are taken, so a citation nearly
always points backwards, at a lower number.

**A citation graph was rejected**, though it is the ordering this actually wants.
Building one means reading every member here, in this context, before the first
loop starts — which is exactly the reading each member's fork exists to keep out
of this run, and it would be paid whether or not any member had a finding. The
cost of getting the order slightly wrong is one member grounded against a
document a later member then moved; the cost of the graph is the whole set read
twice.

**Two passes over the set were rejected** for the same reason once more: a second
pass is a second sweep, and a second sweep is one command the user can type when
the first one's repairs warrant it. Say so in §Present where any member repaired
anything.

**Sequential, never parallel, and this is a decision rather than an omission.**
Two members' repairs reach for the same documents — the glossary, the conventions
doc, a README index, a sibling ADR's amendment note — and a document is one file
with no seam to divide. `dror-adr-review-repair`'s own concurrency check is a
report and not a gate, and it says so, so nothing beneath this run would prevent
the collision. One member at a time removes the case.

## 3. Say what the phase will spend, before it spends it

One short block on screen, then wait for the user's word — this run can ask, and
this is one of the two things it asks for:

- the directory, and how many members are in the set;
- the order, as a list of numbers;
- what one member costs: a review with its lens fan-out and a refuter under every
  finding, then a repair, per round, up to the loop's own cap — which that skill's
  file fixes, and which this run neither raises nor lowers;
- that the members run one at a time, so the phase costs about the set's size
  times a member;
- the phase tag, minted here by the store's recipe
  (`../dror-internal-shared/REPORT-STORE.md`) and handed to every member's loop as
  its run tag, so every report this phase writes carries it.

**A phase is many hours of agents.** A user who sees the number of members and
the shape of the bill before anything is spawned can cut the set with `from ADR
<n>`, or run the loop on one document instead. That is the whole reason this
block exists, so it is printed before the first member and never after.

## 4. Each member, one at a time

For each member in order:

**Fire one `notify-send` as the member begins, best-effort:**

```
notify-send "adr-sweep · <i>/<total> · ADR <n>" "<the focus, in a few words>"
```

Ignore its exit status and never let it gate a member — it is absent on a
headless box and on macOS.

**Then write the phase state file** with this member marked `started`, before its
loop is invoked. §The phase state file owns what is in it.

**Then invoke the `dror-adr-review-repair` skill:**

> Loop review and repair over **ADR `<n>`**, at `<the path step 1 resolved>`,
> until it converges. Use `<the phase tag>` as your run tag rather than minting
> one. `<Where this phase was told to file: file the drafted tickets. Otherwise:
> leave every ticket drafted — you have no yes to file on.>` `<Where the phase
> has a focus: For context, why these documents are being checked now: <the focus
> sentence>.>`

The ADR arrives **labelled**, which is that skill's one stop and is answered here
by construction: this run reads its numbers off the decision directory and never
off something the user typed.

**What comes back**: the member's per-round lines, its ending word and the
grounds for it, the files it edited, the tickets it filed or drafted, and
everything it handed on — breaches, conflicts, revisits, ungrounded items. Keep
it as it came. Re-wording a member's verdict is how a reader loses track of which
layer said what.

**Append it to the phase report and keep only the row.** Everything above except
the member's row goes straight into the file §The phase report owns, written as
this member ends rather than held to the end of the phase. What stays in this
context is one row per member — the number, the rounds, the survivors by kind,
the ending word — and nothing else. **This is what makes a long sweep affordable
in the session it runs in**: a phase over a whole directory would otherwise carry
every member's conflicts, ungrounded items and ticket drafts, in full, for the
rest of the run.

**A member that wrote no report is skipped, not the end of the phase.**
`dror-adr-review` writes none for a stub ADR — a title and no decision — or for
one marked superseded, and the loop then ends on that one sentence. Record the
member as `skipped — <the sentence's reason>` and go on. A phase over a directory
with three stubs in it is a phase, not three failures.

**The loop's summary is a step's result, not this run's reply** — a table of
rounds and a stack of questions for the user is the deliverable's shape
DELEGATION.md names, and it arrives at the end of a long wait, which is when it
reads most like a finished turn. So this step's named next action, both branches
concrete: **immediately after the member's loop returns, and in the same turn,
rewrite the phase state file with that member's ending word, and then either
invoke `dror-adr-review-repair` for the next member or print §Present's table.**

**The user may stop the phase between any two members**, and a phase told to stop
prints §Present for the members that ran rather than starting another. The state
file is what makes starting again cheap.

## The phase state file

`<the checkout this run was invoked from>/.claude/dror-skills/adr-sweep.json`,
rewritten as each member starts and again as it ends. It holds the directory, the
phase tag, the ordered set, and one entry per member: its number, its state —
`started`, `done`, `skipped` — its ending word where it has one, and the report
paths its loop named.

**It is a current position, not a history**, the same shape and the same reason as
the drain's state file: a phase over a large set will be interrupted, and what a
resumed run needs is which member is next.

**Read it before step 3.** A file whose set matches the one step 1 resolved, with
members still not `done`, is a phase already under way: say how many are done and
which is next, and ask whether to carry on from there or start the set again.
That is the second of this run's two questions. A member left `started` is one
whose loop was interrupted — offer it as the next member, since nothing else
knows whether its document was left half repaired.

**A phase that carries on takes the tag from the file**, not a new one, so a
resumed phase's reports stay one series.

Like every store in this chain it is disposable, by the store's own rule
(`../dror-internal-shared/REPORT-STORE.md`); losing it costs the user a re-run
of members the summary named as done.

## The phase report

`<the checkout this run was invoked from>/.claude/dror-skills/adr-sweep-report-<tag>.md`,
claimed before anything is written to it by the store's `next-free` rule
(`../dror-internal-shared/REPORT-STORE.md`), and appended to as each member ends
rather than written at the finish — an interrupted phase then still leaves
everything its members produced.

It holds **what the phase leaves for somebody else**, collected by kind across
the whole set rather than scattered through the members, each item naming its
ADR. This is the part a phase exists to produce and the part seventeen separate
runs destroy:

- the **conflicts**, the **unstated** values and the **revisits**, each as the
  question the user has to answer, with the passages, the criterion and the ADR's
  silence, or the numbers the member carried;
- the **ungrounded** items, each with what could not be settled;
- the **breaches**, each with its `file:line`, as work for `/dror-code-repair`;
- the **ticket drafts** nothing filed, each in full, with the one question they
  carry: file this, or not;
- under each member, the files it edited and the reports its rounds wrote.

Front matter first: the directory, the phase tag, the set, and the time the
phase started.

**It is written for a person to read after the run**, which is why it is a file
and not the summary below. These items are long — a draft ticket is a body, a
conflict is two quoted passages — and a set of them is more than a screen holds,
more than a reader takes in at the end of hours of waiting, and more than this
run can carry in context while it still has members to work.

## Present

**One table and nothing else of the findings.** One row per member, in the order
they ran: the ADR's number and title, how many rounds it took, its survivors by
kind as counts, its ending word — **owed**, **optional** or **no**, as its loop
gave it — and `skipped` with its reason where the loop wrote no report.

**No finding is printed here, and no question, and no draft.** They are in the
phase report, and the counts in the table say how many of each are waiting there.
A sweep is quiet on purpose: the run is long, the reader arrives at the end of
it, and one table plus a path is what they can act on.

Then the single lines: **the phase report's path, first** — it is the deliverable
and the reader's next move; the phase tag; how many members ran, were skipped and
were never reached; every file the phase edited, and every ticket it filed or
corrected by number; the state file's path; and — where any member repaired
anything — the one sentence that a second sweep is what checks the members whose
turn came before those repairs landed.

Then say the documents are left uncommitted, and stop.

Done when every member in the set has been worked or named as skipped or as not
reached, each worked member with its ending word and each skipped member with its
reason; the phase report holds every member's questions, drafts, breaches and
ungrounded items; the table is on screen with the report's path under it; the
phase tag and the state file are named; and nothing is committed.
