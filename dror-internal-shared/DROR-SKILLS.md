# The dror skills — what each one is for

The agent-facing map. It owns the tier lists, the checkbox rules and the
finding-kind routing; the glossary owns the terms, and each skill's own file its
procedure.

Thirteen skills over one way of working: an **ADR** states a decision, a **spec
issue** turns it into work, **child tickets** carry the pieces, and each ticket's
**acceptance criteria** are checkboxes in its body. The criteria are the contract
— they are what a test is written against, what a review judges, and what a
closed ticket means.

The words are in [`CONTEXT.md`](CONTEXT.md); the reasons are in
[`docs/adr/`](docs/adr/).

## The chain

| Skill | Question it answers | Writes |
|---|---|---|
| `dror-show-tickets` | Which tickets does ADR N have, what blocks what, what landed? | nothing |
| `dror-implement-adr` | Work one ADR's ready tickets to exhaustion, on a branch of its own | a worktree (removed on a clean finish), a branch, each ticket's push, each ticket's close, `drain-<ADR>.json` |
| `dror-implement-ticket` | Run one ticket through the whole chain, in order | code, in one commit, pushed to its branch; then whatever the three below write |
| `dror-prove` | Does every criterion have a test that bites? | tests; ticks green boxes |
| `dror-review` | What is wrong with the unpushed work? | `review-report-<ticket>.md`, its per-criterion verdicts inside |
| `dror-repair` | Fix what the review found, each one red then green | code and tests; unticks a red box |
| `dror-review-repair` | Loop the two until it converges, up to its own cap | whatever its two steps write |

## Above the chain

The chain starts at an ADR and takes it on trust. These ask whether it deserves
it, and they are the same shape one level up: find, then fix, in two runs
(ADR 0001), with the finding refuted before it reaches you.

| Skill | Question it answers | Writes |
|---|---|---|
| `dror-adr-review` | Is this decision still true, still coherent, still obeyed — usually asked before implementing it? | `adr-review-report-<adr>.md` |
| `dror-adr-repair` | Bring the document, and every drifted copy of its rules, back in line with the tree | the ADR's prose, and any other document an `echo` names |
| `dror-adr-review-repair` | Loop the two over one ADR until it converges, up to a cap of its own — lower than the loop below it, and with no round-1 floor | whatever its two steps write |

They divide the findings by **kind**, because different hands fix them. Six
kinds, and this is where each one goes:

- `text`, `hole` and `echo` are the document's fault and go to
  `dror-adr-repair`. An `echo` is a rule the ADR states correctly and a copy of
  it elsewhere has drifted, so it names every copy and is repaired in all of
  them at once — the copy that gets read is the one that governs.
- `breach` is the code's and goes to `dror-repair`.
- `conflict` between two decisions is nobody's until the user says which wins.
- `revisit` is nobody's either, for the opposite reason: nothing is wrong, and
  what the decision predicted has not held. Whether to reopen it is the user's.

Neither skill writes code, and neither may rewrite what was decided — see
ADR 0020. The glossary defines the six; `dror-adr-review` mints them.

A typical ticket: implement → `dror-prove` → the review-repair loop →
`dror-prove` on whatever is still unticked → commit, push, close — which is what
`dror-implement-ticket <N>` runs in one go.
`dror-show-tickets` is the map you read before and after.

**Where the context boundaries are.** Every skill in the chain and above it —
the ticket, the drain, the two loops, prove, review, repair and the three ADR
skills — carries `context: fork` in its frontmatter (ADR 0036), so each runs in
an agent of its own whether the user invoked it or another skill did: what
reaches it is its own file, the facts its first line injects, and its
arguments, never the conversation that invoked it, and what comes back is its
closing summary. Beneath those, `dror-review` and `dror-adr-review` spawn a lens
agent per lens with a refuter under each, and `dror-repair` and
`dror-adr-repair` fan out per item; every such agent is given paths and never
pasted text (ADR 0038). Each file owns its own arrangement and lists what its
agent must return, and a step is a step either way — see `DELEGATION.md`.

Matt's `/implement`
does the same shape with his own `/tdd` and `/code-review` in place of the two
middle steps — one or the other, never both, or one ticket gets two test sets.

## The three beside the chain

- **`dror-internal-project-facts`** sits under all of them — it caches what the repo
  declares in `<repo>/.claude/dror-skills/facts.md`, and every chain skill's file
  opens with its stamp script, which injects the cached facts on a hit; the
  skill itself is invoked only on a miss. See ADR 0010, ADR 0013 and ADR 0037.
- **`dror-review-retrospective`** reads the refutation log across runs and says which
  lens is producing false positives and what wording to change. It proposes and
  stops.
- **`dror-guide`** governs the style of step-by-step answers. It works at the
  level of the session, on whatever is being discussed.

`dror-internal-shared` is the shelf the others read from, holding
[`WRITING-TESTS.md`](WRITING-TESTS.md), [`REPORT-STORE.md`](REPORT-STORE.md),
[`WORKTREE.md`](WORKTREE.md), [`DELEGATION.md`](DELEGATION.md),
[`ADR-FILE.md`](ADR-FILE.md), this map, the glossary and the ADRs.

## Which of them know your repo's conventions

Two tiers, and each skill says which it is in (ADR 0011):

- **Repo-agnostic** — `dror-internal-project-facts`, `dror-implement-ticket`,
  `dror-prove`, `dror-repair`, `dror-review`, `dror-review-repair`,
  `dror-adr-repair`, `dror-guide`.
  They name no path and no tracker; whatever a repo
  declares reaches them through the facts. It does not mean free of **git**:
  `dror-review`'s scope is the unpushed work and `dror-implement-ticket`'s
  step 0 counts commits, and both say so.
- **Convention-bound** — `dror-implement-adr`, which inherits the binding from
  `dror-show-tickets` by using its vocabulary, `dror-show-tickets`, which assumes GitHub issues
  reachable by `gh` and ADRs in a conventional decision directory, `dror-adr-review`,
  which assumes the second of those, and `dror-adr-review-repair`, which inherits
  it from `dror-adr-review` by taking an ADR by number. In a repo that does
  neither, they say so and stop; a path named explicitly is always honoured.

## Why these skills exist beside Matt's

They answer different questions, and neither replaces the other.

- **Matt's `/tdd`** is a *reference* for the red-green loop — what a good test
  is, seams, anti-patterns. It takes no ticket. **`dror-prove`** is a *procedure*
  driven by one ticket's criteria list.
- **Matt's `/code-review`** reviews since a chosen point on two axes, Standards
  and Spec. **`dror-review`** reviews everything unpushed through lenses and
  refuters, and leaves a report file later runs read.
- **Matt's `/implement`** is the same orchestration over his own steps: it names
  `/tdd` and `/code-review` literally, so a plain run bypasses the
  dror chain entirely. **`dror-implement-ticket`** is the dror spelling of it —
  one ticket number threaded through every step, no review before the
  criteria are proven, a review-repair loop to close what reviews find, and its
  own commit, push and close at the end. Chaining Matt's `/implement` *into* the
  dror chain is the one
  combination to avoid: it reviews and commits before `dror-prove` has run.

## Who may move a checkbox

One writer per direction, because a tick is a claim about evidence (ADR 0004):

- **`dror-prove` ticks**, and only what it saw go green.
- **`dror-repair` unticks**, and only a box whose test it just saw go red.
- **`dror-review` touches no box.** Its per-criterion verdicts go into its own
  report; nothing is posted to the tracker.

## Naming

The chain's three verbs read in the order they run: **prove**, **review**,
**repair**.

`dror-prove` is deliberately not called `coverage`: coverage normally means lines
and branches from a tool, and it is satisfied by a test that asserts nothing —
the one thing this skill refuses. What it delivers is evidence: every criterion
seen to fail before it counts as met.

It is also deliberately not called `tdd`. The skill usually runs *after* the
implementation, as an audit, and a name next to Matt's `/tdd` invites reaching
for the wrong one.

`dror-review-retrospective` is not called `calibrate` because it takes no action of its
own: it reads and proposes.
