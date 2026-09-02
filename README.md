# dror-skills

A working chain for Claude Code, built on one idea: **a finding is refuted before
it reaches you**. Lenses propose cheaply, refuters kill what they can, and only
the survivors are reported. The one exception carries stronger proof, not
weaker: a diagnostic the repo's own lint or type-check raised skips the
refuter, because the tool's output already is the proof.

## Install

```
/plugin marketplace add drormeir/dror-skills
/plugin install dror-skills
```

## The chain

[`STRUCTURE.md`](STRUCTURE.md) has the whole picture — every skill with its own
description, and a diagram of how they run into each other.

An **ADR** states a decision, a **spec issue** turns it into work, **child
tickets** carry the pieces, and each ticket's **acceptance criteria** are
checkboxes in its body. The criteria are the contract — what a test is written
against, what a review judges, and what a closed ticket means.

| Skill | Question it answers |
|---|---|
| `dror-show-tickets` | Which tickets does ADR N have, what blocks what, what landed? |
| `dror-implement-adr` | Work one ADR's ready tickets to exhaustion, on a branch of its own |
| `dror-adr-resume` | Whose is the lock an interrupted drain left, and start the drain again where it is nobody's |
| `dror-implement-ticket` | Run one ticket through the whole chain, in order |
| `dror-prove` | Does every criterion have a test that bites? |
| `dror-code-review` | What is wrong with the unpushed work? |
| `dror-code-repair` | Fix what the review found, each one red then green |
| `dror-code-review-repair` | Loop the two until it converges |

Above the chain, `dror-adr-review` and `dror-adr-repair` ask whether the decision
deserved the trust the chain gives it, and `dror-adr-review-repair` loops the two
over one ADR the way `dror-code-review-repair` loops the pair below.

**Reach for them before you write tickets against an ADR**, not after. Everything
downstream takes the decision on trust — the tickets are cut from it, the tests
are written against the criteria, the review judges the diff by them — so a
sentence that has quietly stopped being true is a rule about to be broken by
somebody following instructions correctly. The pass is optional and it is
cheapest here: correcting the document costs one run, while correcting it after
its tickets are built costs the tickets too.

An ADR is checked against five different things, which is why one read is worth
it: the **code** it governs, **itself**, **other documents** that restate its
rules, **its own tickets**, and **the reader** who will act on it. Only three of
the ten lenses read code at all.

The same shape turns on the skills themselves: `dror-skill-review` reviews one
skill's directory — against the harness contract, the tree it runs in, itself,
the shelf and the agent that reads it — or one shelf document, which drifts the
same way. `dror-skill-repair` corrects the
text from the findings without redesigning what the skill does, and
`dror-skill-review-repair` loops the two the way the other loops do.
Beside it, `dror-review-retrospective`
reads the refutation log across runs and says which lens is producing false
positives.

`dror-internal-project-facts` and `dror-internal-shared` are named for what they
are: the first opens every skill in the chain — its stamp script injects the
cached facts, and the skill itself runs only on a miss — the
second is a shelf of reference material — the test-writing rules, the report
store's rules, the lens fan-out's rules, the ADR worktree's rules, the glossary,
the map and the decision records behind the design.

Four skills work at the level of the session itself: `dror-guide` governs
step-by-step answers, `dror-brief-me` governs how a choice is put to you,
`brief` resets the answering style, and `screen-capture` lets Claude see your
screen.

## Why it is shaped this way

The find-then-fix pair appears three times — once for code, once for decision
records, once for skills — and the three are deliberately not interchangeable.
Each pair specialises in its own kind of document, and each repair skill takes
exactly what its own reviewer produces. What they share is the plumbing, held
once on the shelf. [`STRUCTURE.md`](STRUCTURE.md) owns that rule, under "Three
pairs, one document type each".

Every decision behind these skills is written down in
[`dror-internal-shared/docs/adr/`](dror-internal-shared/docs/adr/) — one file per
decision, with the alternatives it was chosen over. Start with
[`DROR-SKILLS.md`](dror-internal-shared/DROR-SKILLS.md) for the map.

## License

MIT
