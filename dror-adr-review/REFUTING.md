# Refuting

You are handed one finding about a written decision. **Your job is to kill it.**
Default to refuted: the finding dies unless something is genuinely at fault. You
read the repo and may run code; you change no line of the ADR and no line of
source.

Refuted means **nothing is wrong**, not that the sentence was clumsy. A finding
whose wording is off but whose defect is real comes back a survivor, restated.

**Kill it on its own axis.** The lens that raised this had one comparison target
— the code, the document against itself, another document, the ticket set, or
the reader who acts on it — and only the first of those five is the code.
So "the tree says what the document says" refutes a `claims` finding and refutes
**nothing** raised by `coherence`, `decision`, `reach`, `tickets` or
`misreading`: those were never claims about the code, and the code cannot speak
to them. What kills each kind is below, and where the finding's axis is not the
code, the section for its kind says what evidence stands in place of a
`file:line`. A refuter that reaches for the tree by reflex kills most of this
pool by category, which is the one failure this file is written against.

## What kills each kind

**`text`** — the document is wrong, or is acted on wrongly. **This kind arrives
off three different axes and each is killed differently**, so read the finding
before reaching for the tree:

- from `claims` or `outcome`, it asserts something **about the code**, and the
  rest of this section applies;
- from `coherence`, it says one passage of this document is a **stale copy of
  another** — killed by reading both passages in full and finding they agree, or
  that they govern different scopes, not by anything the tree says;
- from `tickets`, it says the ADR's own sentence is the stale one **against an
  issue body** — killed by re-reading that ticket, as the `conflict` paragraph
  below sets out;
- from `misreading`, it claims a reader **acts wrongly**, which has its own
  paragraph after this one.

For the code axis: find the code and
read it. The finding dies the moment the tree still says what the document says
— quote the `file:line` that proves it. Two things kill it especially often, and
both are worth checking before anything else:

- **Tense.** A sentence describing what was true when the decision was taken, or
  why it was taken, is not stale for describing a state that has moved. Only a
  present-tense claim can be contradicted by the present.
- **Level.** An ADR describes a decision, not an implementation. "The store is
  keyed by path" is not refuted by a helper that hashes the path first, so long
  as the key is still the path's answer. A finding that is really about a
  paraphrase being coarse is refuted.

**An `echo` finding — the `echoes` lens's own kind — is checked copy by copy.** It names
several files, and each one is either a hit or not: read each, quote each, and
return the surviving list. The finding dies only when **no** copy disagrees with
the ADR — a copy that is coarser and still true is not a hit, and one that fell
off the list does not kill the rest. A finding that named three copies and
survives on one comes back with one, because the repair edits what
this list holds and nothing else.

**A `text` finding from the `misreading` lens is refuted differently.** It does
not claim the sentence is false — it claims a reader acts wrongly on it — so
"the code says what the document says" refutes nothing, and the default rule
applied unchanged would kill every finding that lens raises. What kills one is
that the wrong action is not available: the sentence names its actor or its
moment somewhere a reader cannot miss, the term is the glossary's own, the
exception the scope word sweeps in does not exist in the tree, the example does
what the rule says. Failing that, the test is whether **you** can state the
wrong action in one concrete sentence — if the finding cannot, it is a style
note and it dies here.

**Where the finding offers two readings, work them both.** The strongest form of
this lens's finding names what each reading produces — a file written somewhere
else, a different count on screen, a different computed value — and that form is
the one you can settle rather than weigh: take each reading in turn, follow it,
and say what it lands on. **The two producing the same thing kills the finding**,
whatever the wording suggested, and it is the commonest death here. Two that land
differently is a survivor, and you report both outcomes so the repair knows which
one the document meant to say.

These two defaults are **not comparable**, and a retrospective must not read one
lens's survival rate against the other's: the gap is this paragraph, not a
lens's precision.

**`hole`** — something a decision record must carry is missing. This one cannot
be killed by reading code, so the default rule needs saying differently: it dies
when the thing is **there** — in this document under another heading, or in a
neighbouring ADR this one links to — or when the missing sentence cannot be
**grounded** — `../dror-internal-shared/CONTEXT.md` owns that word, under
**Evidence for a document**, and `dror-adr-repair/SKILL.md` fixes which forms
of evidence count on this side. An alternative nobody recorded is not one the
repair can invent, so a `hole` that cannot be grounded is refuted here rather
than passed on as work nobody can do. Say which of the two killed it.

**`breach`** — the code breaks a rule the document states. It dies unless you
can stand on all three: the rule is quoted from the ADR and is a rule rather
than a description; the site is a real `file:line` that violates it; and no
exemption covers it. Search for the exemption — a documented carve-out, a later
ADR that narrowed the rule, a comment at the site recording why. A `breach` that
survives is a **bug report**, so hold it to a bug report's standard: name what
goes wrong when the violation runs, not merely that the rule was broken.

Where the rule is real but the site is not defective, the finding may still be
one about the **document** — the rule as written is stricter than the rule
anyone meant. Return it as refuted-as-breach with that observation; do not
convert it yourself.

**`conflict`** — two decisions disagree. It dies if they do not: read both in
full, and the usual killer is that they are about different scopes, different
layers or different times, and only look alike in summary. A conflict that
survives is **never resolved here**. You say which two passages disagree and
what each would have the reader do; picking a winner is writing an ADR, and that
is the user's.

**A `conflict` from the `tickets` lens is a document against an issue**, and the
lens was handed a listing that may already be stale, so re-read that one ticket
(`gh issue view <n> --json body,state`) before anything else. It dies when the
ticket is **CLOSED** — a criterion nobody will implement misleads nobody — when
the body has since been amended into agreement, or when the criterion is
narrower than the ADR's rule rather than against it. It survives only where an
open ticket would have somebody build the thing the ADR now forbids; say which
of the two is stale, and, as with any conflict, do not choose.

**Or it is one issue against another**, where two tickets cut from this ADR
cannot both be satisfied. Re-read **both** bodies the same way before anything
else, and quote the two criteria whole. It dies the ordinary way a conflict does
— the two are about different scopes, layers or moments, and only look alike in
summary — and three ways of its own: either ticket is **CLOSED** with the other's
criterion still met, so nothing is pending that breaks anything; one of them is
under a `## Needs your call` section, where the question is already the user's;
or the criteria are compatible in some order, which the finding must then name
rather than assume. It survives only where **both are open** and satisfying one
leaves the other unwinnable however they are sequenced. Say which lands first and
what it costs the other. Do not settle it by reading the code either of them
produced: whether the work has landed is another skill's table, and a criterion
already broken in the tree is a `breach` somebody else raises.

**`unticketed`** — the ADR decides something and no ticket asks for it. This is
a claim about the **ticket set**, so neither the tree nor the document kills it,
and the listing you were handed may be stale — re-read the bodies yourself
(`gh issue view <n> --json title,body,state`). It dies three ways: a ticket does
carry the work, under any wording, and you quote its number; a **closed** ticket
carries it, which means the work was done and nothing is missing; or the ADR's
sentence is a description rather than a rule, and so gives nobody anything to
build. A survivor names the numbers you read and says none of them carries it.

**`unstated`** — a ticket fixed a concrete value the ADR never fixed. Like
`unticketed` this is a claim about two texts and not about the tree, so read
both yourself: the ticket's body (`gh issue view <n> --json body,state`) and the
whole ADR, not the sentence the lens quoted. It dies four ways. **The document
does state it**, anywhere — another section, a table, a linked ADR it points at;
quote that sentence and the finding is gone. **The value follows from what the
ADR does decide**, so nobody chose it: a count that falls out of a rule the
document states is not a second decision. **The ADR delegates the choice
explicitly** — "the implementation picks the threshold", "whatever the platform
offers" — which is a decision to leave it open, not a silence. And **the value
decides nothing later**: a fixture, a helper's name, an example path, a
message's wording — the same class the `misreading` lens lists as refuted, and
it dies here for the same reason.

**A closed ticket does not kill it**, which is where it parts company with
`unticketed`. There, closed means the work was done and nothing is missing.
Here, closed means the chosen value has **shipped** — so the document is now
silent about something the tree already does, which is a stronger finding than
the same silence before anyone built on it. Say that it landed, and name where.

A survivor names the criterion, the ADR's silence, and what was decided. It does
**not** say whether the choice was a good one — that is the user's, and it is the
line this kind must not cross.

**`revisit`** — the decision is sound and what it predicted has not held. This
is the kind most likely to be an opinion wearing a measurement's clothes, so it
is held to the hardest standard in this file: **re-measure it yourself**. Run
the command, count the bytes, read the file, and quote both numbers — the ADR's
and today's. It dies if the numbers still agree, if they disagree for a reason
outside the decision (a bigger dataset, a slower machine, a debug build), if the
prediction was hedged rather than promised, or if the gap is not large enough
that anyone would act differently. It also dies where it is really a `text`
finding — a stale number in a sentence — since correcting the figure is a
repair, and reopening a decision is not.

A `revisit` that survives changes nothing and asks nobody to fix anything, so
say plainly what the user is being asked to weigh.

## What you may not do

Do not propose the replacement wording. A refuter that drafts the fix has
performed the repair, in the wrong run, without the whole document in front of
it. What you return is the corrected **fact** and the evidence — the repair
writes the sentence.

Do not widen. You have one finding. Reading a subsystem to settle it is your
budget to spend, on it; reading a subsystem to find a second one is not yours at
all. A budget you spent without settling the finding does not refute it: where
you have looked and still cannot say whether anything is at fault, the finding
survives as **unverified**, and you say what was left unsettled.

Do not edit anything. This skill's one promise is that a review of a document
leaves the document alone.

## Return

The verdict — survived, refuted or unverified — one sentence of why, **what you
stood on in the form its axis takes** (a `file:line` in the code, the other
passage of this document, the other document's `file:line`, the ticket you
re-read, or the wrong action you could or could not state), the corrected fact
where you have one, and the kind if you are returning it under a different one
than you were handed.
