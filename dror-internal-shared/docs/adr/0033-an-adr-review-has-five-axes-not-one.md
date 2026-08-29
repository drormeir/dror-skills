# An ADR review has five axes, and evidence is owed per axis

`dror-adr-review`'s lens pool does not compare the document against one thing.
Each lens has exactly one **comparison target**, and there are five across the
pool:

| Axis | Lenses | What the evidence is |
|---|---|---|
| the code | `claims`, `breach`, `outcome` | a `file:line` in the tree as it stands now |
| the document itself | `decision`, `coherence`, `reach` | another passage of this document, by line number — or the question it forces and leaves unanswered |
| other documents | `neighbours`, `echoes` | the other file's own `file:line` |
| its tickets | `tickets` | the issue body handed to the lens, quoted by number |
| the reader | `misreading` | the wrong action a competent newcomer takes |

**Three of ten read code.** That is the fact the design had lost.

`LENSES.md`'s preamble — pasted verbatim into every lens agent's prompt — used to
open "The document is not the evidence. Every finding is settled against the tree
as it stands now… and it carries the `file:line` it was judged at. A finding
whose only support is another sentence of the same document is a reading, not a
defect." Every clause of that is right for the code axis and wrong for four of
the other five. It was handed to the `coherence` agent, whose entire subject is
two passages of one document disagreeing — a finding whose only support *is*
another sentence of the same document, with no `file:line` in existence to carry.
It was handed to `tickets`, which its own section tells "never judge a ticket
against the code". A lens obeying its preamble returns nothing; a lens finding
something has ignored the instruction it was given.

The refuter had the same shape and the same hole. Its default is "the finding
dies unless the document, or the code, is genuinely at fault", and a refuter
reaching for the tree by reflex kills `coherence`, `decision`, `reach`, `tickets`
and `misreading` **by category** rather than on their merits.

## This was already found once, and patched too narrowly

`REFUTING.md` carries a carve-out for `misreading`: "the default rule applied
unchanged would kill every finding that lens raises." That paragraph is correct
and its argument was never generalised — the same sentence is true of four more
lenses, and the fix stayed a special case for the one lens where somebody
happened to notice. A carve-out that has to be written a second time is a rule in
the wrong shape.

## The rule

**A finding is settled on its own lens's axis and no other**, and the evidence it
owes is that axis's. A `file:line` is what *one* axis's findings carry, not what
a finding is. The preamble now names the five, the refuter kills on the axis it
was raised on, the read budget is capped per axis (the document alone for the
three that read only it), and the report records "what it was judged against" in
the form the axis takes rather than a `file:line` column that four axes cannot
fill.

## Considered options

**Splitting the pool into one skill per axis** was rejected: one read of the
document settles findings on several axes at once, which is the whole reason the
lenses run as one batch over one document read in the parent context. Five skills
would read the ADR five times to produce one report.

**Dropping the non-code lenses** was rejected outright, and it is worth saying
why, because the preamble amounted to that by accident. The lenses that never
read code are the ones with no other check anywhere: nothing downstream catches a
decision that was never taken sharply enough to write down, and `tickets` is the
only thing in the chain comparing a criterion against the rule it was cut from —
a mismatch there is a rule about to be broken by somebody following instructions
correctly.

**Keeping one evidence rule and loosening it to "quote something"** was rejected
as the version that reads fine and changes nothing. The value of the old sentence
was that it was strict; the defect was that it was strict about the wrong thing
for most of the pool. Five stated axes keep the strictness and move it.

## Consequences

The skill's opening frame was "two directions at once", both of them the code
axis — a description of three lenses standing in front of ten. It now opens on
the five, and its `description:` follows: "against itself, its tickets and the
code it governs".

`REFUTING.md`'s `text` section splits, because that one kind arrives off three
axes — `claims`/`outcome`, `coherence`, `tickets` — and each dies to different
evidence. `hole` and `conflict` already said so in their own words; they are
unchanged.

Rates across axes are **not comparable**, for the reason ADR 0003 gives about the
two refutation defaults and ADR 0020 repeats about the two pools. A
`dror-review-retrospective` ranking `coherence` against `claims` is measuring the
axis, not the lens. That is a third such warning in this design, and it is the
same warning: a survival rate is only readable against findings judged by the
same standard.
