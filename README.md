# dror-skills

A working chain for Claude Code, built on one idea: **a finding is refuted before
it reaches you**. Lenses propose cheaply, refuters kill what they can, and only
the survivors are reported.

## Install

```
/plugin marketplace add drormeir/dror-skills
/plugin install dror-skills
```

## The chain

An **ADR** states a decision, a **spec issue** turns it into work, **child
tickets** carry the pieces, and each ticket's **acceptance criteria** are
checkboxes in its body. The criteria are the contract — what a test is written
against, what a review judges, and what a closed ticket means.

| Skill | Question it answers |
|---|---|
| `dror-show-tickets` | Which tickets does ADR N have, what blocks what, what landed? |
| `dror-implement-adr` | Work one ADR's ready tickets to exhaustion, on a branch of its own |
| `dror-implement-ticket` | Run one ticket through the whole chain, in order |
| `dror-prove` | Does every criterion have a test that bites? |
| `dror-review` | What is wrong with the unpushed work? |
| `dror-repair` | Fix what the review found, each one red then green |
| `dror-review-repair` | Loop the two until it converges |

Above the chain, `dror-adr-review` and `dror-adr-repair` ask whether the decision
deserved the trust the chain gives it. Beside it, `dror-review-retrospective`
reads the refutation log across runs and says which lens is producing false
positives.

`dror-internal-project-facts` and `dror-internal-shared` are named for what they
are: the first is invoked by every skill in the chain as its first step, the
second is a shelf of reference material — the test-writing rules, the glossary,
the map and the decision records behind the design.

Two skills stand apart from all of it: `dror-guide` governs step-by-step answers,
`brief` resets the answering style, and `screen-capture` lets Claude see your
screen.

## Why it is shaped this way

Every decision behind these skills is written down in
[`dror-internal-shared/docs/adr/`](dror-internal-shared/docs/adr/) — one file per
decision, with the alternatives it was chosen over. Start with
[`DROR-SKILLS.md`](dror-internal-shared/DROR-SKILLS.md) for the map.

## License

MIT
