# Reviewing an ADR repairs the text only

The chain starts at an ADR and takes it on trust: `dror-show-tickets` reads it,
tickets carry its work, and every criterion is judged against it. Nothing asked
whether the document was still true. `dror-adr-review` and `dror-adr-repair` are
that question, in the shape ADR 0001 already fixed — find, then fix, in two runs
the user starts separately.

Reviewing a decision raises a problem code review does not have: **two things
can be at fault, and they are repaired by different hands.** A sentence and a
tree that disagree are either a stale document or a code defect, and one edit
makes each of them true. So the review classifies rather than merely reports,
and the kinds are the whole design:

- `text` and `hole` — the document. `dror-adr-repair` writes prose and nothing
  else. It touches no source file, so a document repair can never change
  behaviour to make a sentence true.
- `breach` — the code. It goes to `dror-code-repair`, which already fixes bugs red
  to green, rather than being fixed by the run that found it.
- `conflict` — neither. Two decisions disagree and picking a winner is deciding,
  which is the user's. A skill that resolved one would have written an ADR
  nobody approved.
- `revisit` — neither, for the opposite reason: nothing is wrong. The document
  is true, coherent and obeyed, and what it *predicted* has not held. It is a
  finding because it is the strongest reason to reopen a decision and the one
  nobody checks, and it is unrepairable because there is no wrong sentence.
  It carries the predicted number and the measured one, or it is an opinion
  about somebody else's decision.

A repair therefore edits prose **wherever that prose lives** — the ADR, the
conventions doc, the glossary, a README index, a docstring at the site — because
the ADR is rarely the copy that governs behaviour. That is still "text only": no
line below a docstring is touched.

> **Extended since.** The list above is four kinds; there are seven. `echo` was
> added later and is the named form of the paragraph immediately above it — a
> rule the ADR states correctly whose copy elsewhere has drifted. It is the
> document's fault and goes to `dror-adr-repair`, which synchronises every copy
> the finding names in one pass. The split this document draws is unchanged;
> `echo` is on the `text` and `hole` side of it.
>
> `unticketed` was added later still, and it widens "writes prose and nothing
> else" by exactly one destination. Nothing in the document is wrong — the ADR
> decides something no ticket asks for — so there is no sentence to correct, and
> the repair writes a **ticket body** instead: prose, saying what to build and
> building none of it. Filing it creates an issue other people act on, so it is
> filed only on the user's yes; without one the draft is the outcome. The
> current routing for all seven is in [`DROR-SKILLS.md`](../../DROR-SKILLS.md).

## The decision itself is not repairable

A repair may correct what a document *describes* and may not change what it
*decides*. An ADR records a decision at a moment; editing the decision to match
today produces a record with no author and no date that still claims somebody
approved it. Text that has been overtaken is marked superseded, never deleted
and never rewritten — the value of the record is that it says the question was
once settled the other way.

## Grounded replaces red-green

`dror-code-repair`'s whole rigour is watching a test fail and then pass. A sentence
has no such evidence, and the failure mode of a document repair is a correction
that reads well and is false. So the corresponding rule is **grounded**: every
sentence written is read out of the tree in that run and quoted with its
`file:line`; a fact the tree cannot settle is **ungrounded**, and the sentence
is not written at all — the question goes to the user instead.

The review's own evidence does not satisfy this. It was gathered against a tree
that may have moved and compressed to fifteen lines, so the repair re-reads it.
That re-read is step 1 and it is the reason the skill exists as a procedure
rather than as an instruction to edit the file.

## Considered options

**One skill doing both** was rejected for ADR 0001's reason, which holds
unchanged here: the user loses the moment at which they accept or subtract from
the findings, and here they would lose it over prose that is about to be
rewritten in their name.

**Extending `dror-code-review` with an ADR mode** was rejected because its scope is
the unpushed diff. An ADR is reviewed against the tree as a whole and against
its neighbours, an empty diff is the ordinary case, and every one of its lenses
would have needed a second reading.

**Letting `dror-adr-repair` fix a breach** was rejected: it would be a code
change with no test behind it, made by a run whose evidence standard is a
quotation.

## Consequences

The two skills share the refutation log with `dror-code-review` —
`~/.claude/dror-skills/refutations.tsv`, one schema, the `lens` column keeping the
pools apart — so the closed vocabulary of ADR 0014 now admits the section names
of `dror-adr-review/LENSES.md` as well. Rates stay separate because the names
do; a retrospective must not read an ADR lens's survival rate against a code
lens's, for the same reason ADR 0003's two refutation defaults are not
comparable.

The report is its own family of files, `adr-review-report-<adr>.md`, so a code review and an ADR
review cannot overwrite each other.

`dror-adr-review` is convention-bound (ADR 0011): it assumes ADRs in a
conventional decision directory, resolved by the shelf's `ADR-FILE.md`, and
honours an explicit path anywhere. `dror-adr-repair` is repo-agnostic — it
is handed a document.
