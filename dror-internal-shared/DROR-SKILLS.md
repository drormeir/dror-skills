# The dror skills — what each one is for

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
| `dror-implement-adr` | Work one ADR's ready tickets to exhaustion, on a branch of its own | a worktree, a branch, one commit per ticket, `drain-<ADR>.json` |
| `dror-implement-ticket` | Run one ticket through the whole chain, in order | code; then whatever the three below write |
| `dror-prove` | Does every criterion have a test that bites? | tests; ticks green boxes |
| `dror-review` | What is wrong with the unpushed work? | `review-report-<ticket>.md`; a per-criterion comment |
| `dror-repair` | Fix what the review found, each one red then green | code and tests; unticks a red box |
| `dror-review-repair` | Loop the two until it converges, up to seven rounds | whatever its two steps write |

## Above the chain

The chain starts at an ADR and takes it on trust. These ask whether it deserves
it, and they are the same shape one level up: find, then fix, in two runs
(ADR 0001), with the finding refuted before it reaches you.

| Skill | Question it answers | Writes |
|---|---|---|
| `dror-adr-review` | Is this decision still true, still coherent, still obeyed? | `adr-review-report-<adr>.md` |
| `dror-adr-repair` | Bring the document back in line with the tree | the ADR's prose, and nothing else |
| `dror-adr-review-repair` | Loop the two over one ADR until it converges, up to three rounds | whatever its two steps write |

They divide the findings by **kind**, because two different hands fix them: a
`text` or `hole` is the document's fault and goes to `dror-adr-repair`; a
`breach` is the code's and goes to `dror-repair`; a `conflict` between two
decisions is nobody's until the user says which wins. Neither skill writes code,
and neither may rewrite what was decided — see ADR 0020.

A typical ticket: implement → `dror-prove` → `dror-review` → `dror-repair` →
close, which is exactly what `dror-implement-ticket <N>` runs in one go.
`dror-show-tickets` is the map you read before and after. Matt's `/implement`
does the same shape with his own `/tdd` and `/code-review` in place of the two
middle steps — one or the other, never both, or one ticket gets two test sets.

## The three beside the chain

- **`dror-internal-project-facts`** sits under all of them — it caches what the repo
  declares in `<repo>/.claude/dror-skills/facts.md`, and every skill in the chain
  invokes it as its first step. See ADR 0010 and ADR 0013.
- **`dror-review-retrospective`** reads the refutation log across runs and says which
  lens is producing false positives and what wording to change. It proposes and
  stops.
- **`dror-guide`** governs the style of step-by-step answers. It works at the
  level of the session, on whatever is being discussed.

`dror-internal-shared` is the shelf the others read from, holding
[`WRITING-TESTS.md`](WRITING-TESTS.md), [`REPORT-STORE.md`](REPORT-STORE.md),
this map, the glossary and the ADRs.

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
  reachable by `gh` and ADRs at `docs/adr/<NNNN>-*.md`, `dror-adr-review`,
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
- **Matt's `/implement`** is the same orchestration over his own steps: its nine
  lines name `/tdd` and `/code-review` literally, so a plain run bypasses the
  dror chain entirely. **`dror-implement-ticket`** is the dror spelling of it —
  one ticket number threaded through all four steps, no review before the
  criteria are proven, a repair step to close what the review found, and no
  commit. Chaining Matt's `/implement` *into* the dror chain is the one
  combination to avoid: it reviews and commits before `dror-prove` has run.

## Who may move a checkbox

One writer per direction, because a tick is a claim about evidence (ADR 0004):

- **`dror-prove` ticks**, and only what it saw go green.
- **`dror-repair` unticks**, and only a box whose test it just saw go red.
- **`dror-review` touches no box.** It posts its per-criterion verdicts as a
  comment instead.

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
