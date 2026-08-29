---
name: dror-show-tickets
description: Show one table of every ticket belonging to an ADR — whether it is closed, ready to close, ready or blocked, whether its code landed, and how many acceptance criteria are ticked. Use when the user names an ADR number and asks which tickets it has, what to implement next, or what is left.
---

# dror-show-tickets

One table, for one ADR. The reply is the table plus at most two sentences under
it. This shape wins over any terse style in force (`brief`): the table is the
deliverable.

## What this skill assumes

Unlike the rest of the `dror-*` chain, this one is **convention-bound** and says
so rather than pretending otherwise: it assumes ADRs in a conventional decision
directory, resolved by `../dror-internal-shared/ADR-FILE.md`, and issues in
GitHub, reachable by
`gh`. A repo that does neither gets one
sentence saying which assumption failed, and no table — an inferred table over a
tracker this skill cannot read would be a guess wearing a table's authority.

## Step 1 — find the ADR

Resolve the number by `ADR-FILE.md`'s rule. If no file matches, say so and
stop — do not guess which decision the user meant. An ADR that exists only as an
untracked file still counts; note that in the closing sentence.

## Step 2 — find the tickets

Where the repo documents its issue conventions — `docs/agents/issue-tracker.md`
is one common home — read that if the commands below do not fit.

1. **The spec issue.** `gh issue list --state all --limit 200 --json number,title,state,body`
   and keep the issue whose body or title names the ADR — its slug, its title, or
   the string `ADR <NNNN>` / `ADR 0<NN>`. It is the parent and usually carries no
   checkboxes.
2. **The children.** An issue whose body opens with a `## Parent` section naming
   the spec's `#number`. Where GitHub sub-issues are enabled, the sub-issues
   endpoint answers the same question — prefer whichever the repo actually uses.
3. If no spec issue names the ADR, fall back to a contiguous number block whose
   titles match the ADR's sections, and **say in the closing sentence that the
   set was inferred**.

## Step 3 — read each ticket

Per issue, from `gh issue view <n> --json body,state,labels`:

- **Status** — one cell answering "can this be worked on now", read in this
  order, first answer wins:
  - `Closed` where GitHub's state is CLOSED. A closed ticket is not asked what
    blocks it — that question is spent.
  - `Needs your call` where the body carries a `## Needs your call` section —
    `dror-prove` found a criterion that is precise, testable and cannot be met
    as written, and only the user can reword it. It outranks every other open
    answer because no amount of work moves the ticket while it stands.
  - `No tickets yet` for a spec issue that is OPEN and has **no children at
    all** — the decision was published as work, and nothing has been cut from it
    yet. It is checked here, above `Can close`, because "every child is CLOSED"
    is vacuously true of a spec with no children, and an ADR nobody has started
    would otherwise be reported as ready to close. It outranks the blocker
    question for the same reason the row below does: no ticket blocks a set that
    does not exist. The actionable answer is to write the tickets, and the
    closing sentence says so.
  - `Can close` where the issue is OPEN, it defines at least one criterion, and
    every one of them is ticked. The work is done and only the user's close is
    missing, so this outranks the blocker question too: a ticket whose criteria
    are all met is not waiting on anything. **The spec issue reaches this answer
    through its children instead**, since it usually defines no criteria of its
    own: an open spec whose every child is CLOSED can close.
  - `Awaiting #NN` — **blocked for closing only**: the work may go on freely,
    but the ticket cannot close until that one does. It says that every
    criterion still unticked belongs to another open ticket, a discovery made
    while working, so it is not in `## Blocked by`. This is the mirror of a
    blocker, not a kind of one: a blocked ticket cannot start, an awaiting one
    has finished everything it owns. Where ordinary unfinished work is left *as
    well*, the row is `Ready` — the actionable answer is to work on it, and the
    closing sentence can name what it will end up awaiting. Read it from the
    body's `## Awaiting` section, which `dror-prove` writes when a criterion
    proves to be another ticket's work; where there is none, infer it from the
    unticked criteria — one naming another ticket's `#number`, or naming as its
    subject a thing another open ticket is the deliverable of — and say in the
    closing sentence that the row was inferred. A criterion nobody else owns is
    unfinished work, and the row is `Ready`. Two such tickets can name each
    other, and that is a real fact about the pair, not an error to resolve.

    **The open spec issue is the largest case of this, and it is read from the
    child set rather than from any section.** A parent carries no checkboxes, so
    it owns no unfinished work of its own and its close waits on every child that
    is still OPEN — which is `Awaiting` exactly, and for the whole list of them:
    `Awaiting #12, #13, #14`. Shorten a long list to the first few and `+N more`
    rather than dropping any. This is the one row whose blockers no `## Blocked
    by` section names, so a spec left to the sections alone comes back looking
    workable when it is the last thing in the ADR that can close — and a caller
    ordering the tickets by this column would put it first.
  - `Blocked by #12, #34` where the `## Blocked by` section names issues that
    are still OPEN, shortened to those numbers alone.
  - `Ready` where every blocker is CLOSED, or there are none.
  - `—` for a row the question does not apply to. **An open spec issue is not
    one of them**: it is answered above, by its children. What is left for `—` is
    a row where the question is genuinely empty — an issue that is neither the
    spec nor a child of it, swept in by an inferred ticket set.
- **Criteria done** — `- [x]` count over `- [x]` + `- [ ]` count, both literal
  greps of the body. Never infer a tick from the code; the number is what
  GitHub holds. A ticket with none reads `none defined`.

## Step 4 — check what landed

Only for tickets whose code could plausibly exist. Cheap checks, in this order:

- `git log --oneline -20` — a commit whose subject matches the ticket title.
- The module the ticket names: does the file exist? That is the **Module built**
  cell. Whether anything imports it (`Grep` for its module name) decides the
  **How to see it** cell below, and is never a column of its own — who calls a
  module is an implementation detail a reader of this table does not want.
- `git status --short` — uncommitted work belonging to the ticket. Its commit
  cell reads `unstaged`.
- Its tests: run them and report the real count, or leave `—`. Never write a
  pass count you did not see.

## Step 5 — how a person sees it

The **How to see it** cell is the gesture that shows this ticket working in the
running application — *open the same file twice; the second open is instant* — taken
from the ticket's own criteria and shortened, never invented. Where the criteria
describe no user-visible behaviour, or nothing in the application imports the
module yet, the cell reads `nothing to see`; that empty answer is the column's
main worth, because it says which rows the user can check and which they cannot.
`—` where nothing is built.

## The table

Columns, in order:

| # | Title | Status | Module built | Commit | Tests | How to see it | Criteria done |

`Status` carries the whole scheduling answer: `Closed`, `Needs your call`,
`No tickets yet`, `Can close`, `Awaiting #NN`, `Ready`, `Blocked by #NN` or `—`,
and never two of them at once.

Rows in issue-number order, spec first. **A spec issue with no children is still
one row**, not an empty table: the row is the answer, and a run that printed
nothing would read as a missing spec. `—` for a cell that does not apply. One
fact per cell — a cell holding three facts is three columns.

## After the table

At most two sentences: which ticket to start on, and any mismatch worth naming
(code landed with zero criteria ticked, a criterion belonging to another
ticket, an inferred ticket set). Nothing else — no plan, no next steps, no
offer, unless the user asks.
