# A value a ticket chose, and the ADR never did, is a finding of its own

`unstated` joins `dror-adr-review`'s closed kind vocabulary, minted by the
`tickets` lens: an acceptance criterion fixes a concrete value — a number, a key
name, a path, a default, an order, a formula — that the ADR behind it never
fixed. It goes to the user and to nobody else.

## What was missing

The `tickets` lens read the ticket set for **disagreement** — a criterion
against the ADR's rule, a criterion against another ticket — and for
**absence in one direction only**: `unticketed`, a rule the ADR states that no
ticket carries.

The other direction had no kind. A ticket that quietly decides what the document
left open produces no contradiction, and that is exactly why it survives every
reading: the ADR is silent, the criterion is specific, and the two agree in the
only sense a comparison can test. The decision then lives in an issue body,
which is closed, archived and never read again once the work ships, while the
document a later reader opens says nothing about it.

It is the more expensive silence of the two. An `unticketed` costs work that does
not happen and is visible the moment somebody asks what is left. This one costs
a decision nobody knows was taken.

## Considered options

**Reporting it as `conflict`** was rejected on the plainest possible ground:
nothing conflicts. The user who asked for this said so first — "this is not
about contradictions; I want the silences that were filled" — and a kind whose
refuter is built to read two passages against each other would kill every one of
these on the first test.

**Reporting it as `hole`** was rejected because of where a `hole` goes. Holes are
`dror-adr-repair`'s, and that skill writes a **grounded** sentence — here the
grounding would be the ticket, so the repair would paste a value into the
document and the chain would have adopted a decision nobody approved. That is
ADR 0020's line exactly, and the paste being easy is what makes the line worth
drawing.

**Leaving it to a focus paragraph** — the user asking for it per run — was
rejected as the shape that does not survive: a focus reaches one run, and the
question is worth asking of every ADR that has tickets.

## The decision

A kind of its own, minted by the `tickets` lens, refuted by a section of its own,
and routed to the **user** beside `conflict` and `revisit`. The review reports
the criterion, the ADR's nearest sentence or its silence, the value, and whether
the ticket is open or has already shipped. It does not draft the sentence the ADR
would adopt, and it never says whether the choice was a good one.

`dror-adr-review-repair` gains a fourth door. Like the other three it never makes
a round owed: nothing was repaired, so a further round would find it again.

## What keeps it from flooding

Every concrete value in a ticket is a candidate, and most of them are noise. Two
guards, both borrowed from findings this repo has already had to kill:

- **The value must decide something later.** A fixture, a helper's name, an
  example path, a message's wording — the ADR is silent on those by design, and
  the `misreading` lens's refuted class covers the same ground in the same words.
- **The refuter reads the whole document**, not the sentence the lens quoted: a
  value stated in another section, in a table, or in a linked ADR kills it, and
  so does one that follows from a rule the document does state, and so does an
  ADR that delegates the choice out loud.

**A closed ticket does not kill it**, which is where it parts from `unticketed`.
Closed there means the work was done and nothing is missing; closed here means the
chosen value has shipped, so the document is silent about something the tree
already does.
