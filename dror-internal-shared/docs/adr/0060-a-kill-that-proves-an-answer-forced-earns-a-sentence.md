# A kill that proves the answer was forced earns a sentence

A prose refuter gains a fourth verdict, `forced`: the lens was right that the
document is silent, and the refuter proved the document's own decisions leave
one possible answer. The finding still dies — nothing was wrong with the
decision — but the kill is carried to the repair, which grounds the answer again
and writes one sentence into the document. `dror-code-review` is unchanged: it
already writes a claim comment itself (ADR 0008), and this is that mechanism in
prose.

## What was missing

A kill is declared inert — one paragraph in `## Refuted`, evidence about the
review's own precision and nothing else (ADR 0017, ADR 0009). That is right for
the ordinary kill, where the lens misread the text. It is wrong for one shape,
and the log says how wrong.

One finding against the `geo_sense` ADR 0020 — a ticket fixing the unit a value
is stored in, where the ADR named no unit — was raised and killed in three
separate rounds across two run tags: `bf3fb4e-1789639242482342241-r1-5`,
`fcf9c62-1789649355463952662-r2-6`, `fcf9c62-1789649355463952662-r3-9`. The same
lens, the same claim, the same kill, the same reasoning bought three times. The
kills were correct. The document never changed, so the trigger never left, and
nothing in the chain could make it leave: the one run that knew why the silence
was harmless was the one run forbidden to write anything down.

ADR 0008 answered this on the code side and named the principle: *a lens
misreading the code is evidence the code did not carry something it needed to
carry.* A document is no different.

## This is not the decision the chain must not adopt

ADR 0053 rejected routing a ticket's chosen value into the ADR, because the
grounding would be **the ticket**, and the chain would have adopted a decision
nobody approved. That reasoning is untouched here, and the difference is exactly
where the sentence stands.

A clarification is never grounded in the ticket that asserted the value. It is
grounded in the tree and in the document's own decisions, which is the grounding
every sentence a document repair writes already has (ADR 0020, *Grounded
replaces red-green*). Where that grounding cannot be produced in the repair's own
re-read, nothing is written and the item leaves as `ungrounded`, by the door that
already exists.

ADR 0020 draws the line this must not cross: a repair may correct what a
document *describes* and may not change what it *decides*. An answer the refuter
proved forced was decided already, by the decisions that force it. Writing it
down records a consequence and takes no decision. A kill on any other ground
carries nothing, and that is what keeps the line where ADR 0020 put it.

ADR 0053 already names this class in its own guard — a value *"that follows from
a rule the document does state"* kills the finding. It named it and left it
inert. This says what to do with it.

## The decision

A prose refuter returns `forced` where both hold: the document really is silent,
and its own decisions or the tree leave one possible answer. It returns the
silence, the answer and the evidence — not the sentence, because drafting prose
in a review is still the wrong run.

The repair takes clarifications beside its other work, re-reads the evidence as
it re-reads every item's, and writes one sentence. Its outcome word is
`Clarified (grounded)`; a re-read that does not settle it ends in
`Left — ungrounded`, like anything else.

**A round that produced only clarifications makes a round owed.** This parts from
ADR 0053's fourth door, and for a reason that door does not have: a sentence
landed in the document, and prose that landed is text no review has read. That is
already the loops' first reason for another round.

**The repair writes it, not the refuter.** This is the one place the prose
mechanism diverges from ADR 0008, where the refuter writes its claim comment
itself. A comment beside code states an invariant and changes no behaviour; a
sentence in a decision record reads as a decision, and the repair is the run that
re-grounds what it writes.

## What keeps it from flooding

ADR 0008's gate, restated for prose: **most kills write nothing.** Two
conditions, both the refuter's, and both must hold.

- **The document is silent** — tested the way ADR 0053's refuter tests it, over
  the whole document, its tables and the ADRs it links.
- **The answer is forced** — the refuter can name the decisions that leave no
  other option. Not that the answer is obvious, and not that the code happens to
  do it today.

A kill because the lens misread the text carries nothing. Neither does a kill the
reading settled some other way, which is the commonest death there is.

## Consequences

The `verdict` column gains a fourth value. A `forced` is counted out of every
imprecision rate: a kill that improved the document is not a false positive, and
pooling it with one would make a precise lens look worse for being useful.

The `claim` column stays `no` for both prose reviews. Nothing is written into a
source file, and the column keeps meaning what it means in the code pool, so the
two share one schema.

`## Refuted` stops being wholly inert. ADR 0017's and ADR 0009's sentences about
it narrow to the ordinary kill rather than being withdrawn — they are still the
whole truth about every kill that is not `forced`.

A clarification a later lens meets is ordinary document text, read as the
document. ADR 0008's staleness guard transfers unchanged: it is verified, never
accepted, so one that goes stale becomes a finding instead of a shield.

The definition lives in the two prose `REFUTING.md` files, which are what reaches
the refuter's prompt, and every other file points at it.
