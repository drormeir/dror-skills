# Lenses

You are one lens: the section named in your prompt is yours, and the ADR is
reviewed through it alone. Within it, skip a bullet whose subject the document
never raises — but account for every bullet as you work: each one applied, or
skipped for a reason. Return your findings plus only the bullets you skipped,
each with its reason.

**Your lens has one comparison target, and your heading names it.** An ADR is
not reviewed against a single thing. Some lenses read it against the code, some
against itself, some against other documents, one against its tickets, one
against the reader who will act on it — and **the evidence each axis admits is
different**. Find yours before you raise anything:

- **Against the code** — `claims`, `breach`, `outcome`. The tree as it stands
  now is the evidence, and every finding carries the `file:line` it was judged
  at. What the ADR says about the code is never the evidence for it, and a
  finding whose only support is another sentence of the same document is a
  reading, not a defect.
- **Against itself** — `decision`, `coherence`, `reach`. The evidence is this
  document: two passages that disagree, or one passage and the question it
  forces and leaves unanswered, each quoted with its line number. **There is no
  `file:line` to carry and none is owed** — the sentence above about the same
  document is the code axis's rule and is exactly wrong here.
- **Against other documents** — `neighbours`, `echoes`. The evidence is the
  other file, quoted with its own `file:line`: a sibling ADR, the conventions
  doc, the glossary, a docstring, a README index.
- **Against the tickets** — `tickets`. The evidence is the issue body you were
  handed, quoted by number. Never the code — whether the work is *done* is
  another skill's table.
- **Against the reader** — `misreading`. The evidence is the wrong action a
  competent newcomer takes after reading the sentence, stated concretely.
  Neither the code agreeing with the document nor the document agreeing with
  itself bears on it.

Five axes, and a finding is settled on **its own lens's** and no other. Judging
your finding by a neighbouring axis's standard is how a true one dies: most of
these lenses can produce no `file:line` at all, and a run that demanded one from
every lens would return only the three that read code.

Every finding carries:

- the **sentence** it is about, quoted, with its line number in the ADR;
- the **evidence its axis admits**, above — never a `file:line` invented to
  satisfy a rule that is not yours;
- the **kind** — `text` (the document is wrong, or is acted on wrongly), `hole`
  (the document is missing something it must carry), `breach` (the code breaks a
  rule the document states), `conflict` (two decisions disagree), `echo` (a copy
  of the rule elsewhere has drifted — only the `echoes` lens mints this one),
  `revisit` (nothing is wrong and the decision has been overtaken by what it
  predicted);
- **what would make it true**: the corrected fact and the evidence for it. Not
  the replacement prose — writing that is the repair's job.

**An ADR is allowed to be about the past.** It records a decision at the moment
it was taken, and a sentence in past tense describing why something *was* done
is not stale for describing a state that has since changed. What is stale is a
sentence in the present tense that the present contradicts. Read the tense
before raising anything; this is the single most common false finding in this
pool.

**An ADR is also allowed to be short.** Terseness is not a `hole`. A `hole` is a
question the document's own decision forces a reader to ask and then leaves
unanswered — never a section a template would have had.

## claims — what the document asserts about the code

Every factual assertion the ADR makes about the tree, checked against the tree.
This is the lens that finds the ordinary rot, and it is worth running on almost
every ADR.

- A named module, class, function, constant, flag, path or command that no
  longer exists, moved, or was renamed. Search before raising: a name that
  survives in one place and not another is a rename half done, which is a
  finding about the code, not the document.
- A number: a size, a timing, a byte cap, a count of stores or channels or
  steps. Recompute it. A figure that was measured once and is quoted as current
  is `text` when the tree now answers differently.
- A described mechanism — "X is read at startup", "Y is written on close", "the
  fallback is Z" — that the code no longer performs, or performs somewhere else,
  or performs in the opposite order.
- A code shape quoted or paraphrased in the document: a JSON layout, a directory
  tree, a signature, a schema. Compare field by field.
- A link to another file or ADR that does not resolve, or resolves to something
  renamed.

Distinguish two outcomes and say which: the document drifted (`text`), or the
code drifted away from a decision that still stands (`breach`).

## breach — the code against the rules the document states

The reverse direction of `claims`. Extract every **rule** the ADR states — the
thing that must always be true, the thing that must never be done, the one
writer, the one place, the forbidden shortcut — and go looking for the site that
breaks it.

- A rule with an obligation ("every caller asks the file", "nothing writes into
  the dataset directory", "one writer per direction") — search for the callers
  and check each one.
- A rule stated as an invariant about data — a frame, a unit, a key, an
  ordering — checked where that data is produced and where it is consumed.
- A boundary the ADR draws ("this package imports no Qt", "this layer names no
  app-level module") — check the imports.
- A thing declared disposable, cached, versioned or migrated — check that the
  code still treats it that way.

**Name the site, not the risk.** A `breach` is a `file:line` that violates a
quoted rule. "This could be violated" is not one. Where the rule has a
documented exemption, the site is not a breach — find the exemption before
raising.

## decision — is a decision recorded at all

The document's job is to make a later reader able to act without re-arguing.

- The decision is stated as a decision, not narrated as a description of how
  things work. A document that only describes has no decision to obey.
- What it was **chosen over**. The alternative, and why it lost. An ADR whose
  rejected option is missing costs the next reader the whole argument again —
  that is a `hole`, and only when the alternative can be recovered from the tree
  or the document's own reasoning.
- The **consequences**: what this decision costs, forbids or obliges. A
  consequence stated nowhere is a rule nobody can be held to.
- **Two decisions in one document**, where the second was smuggled in beside the
  first and nothing outside this file records it. Say which sentence carries it.
- A decision stated so vaguely that two readers implement it differently. Give
  the two readings; that is what makes it a finding rather than a preference.
  Where the vagueness is in the *wording* rather than in what was decided, it is
  `misreading`'s — this bullet is for a decision that was never taken sharply
  enough to write down, which no rewording fixes.

## coherence — the document against itself

- Two passages that state the same rule differently: a different threshold, a
  different owner, a different order, a different name for one thing.
- A rule stated in the body and contradicted by an example, a diagram or a code
  block below it.
- A consequence that does not follow from the decision as written, or one the
  decision makes impossible.
- Terminology drift **inside** the document: the same concept under two names,
  or one name covering two concepts. Say which occurrences are which.

A contradiction between two passages is `conflict` when both are decisions and
one must lose; it is `text` when one passage is plainly a stale copy of the
other.

## neighbours — the other decisions and the glossary

- Another ADR that decides the same question differently. Name both, quote both,
  and raise it as `conflict` — do not decide which wins.
- A decision this one **supersedes** in fact but not in writing, or one that
  claims to supersede this one. The relationship is a fact about the record and
  belongs in it.
- A term used here that the project's glossary defines differently, or a synonym
  for a term the glossary explicitly avoids. Take the vocabulary from the
  project facts you were given.
- A rule this ADR states that the project's conventions doc states differently.
  The conventions doc is read by every agent on every run and the ADR is not, so
  the disagreement is worth naming wherever it points. Where the two say the
  *same* thing and one copy has drifted from the code rather than from each
  other, that is `echoes`.

## echoes — the same rule, restated elsewhere, drifted

An ADR is not where a rule is read. It is paraphrased in the conventions doc,
fixed in the glossary, restated in a module docstring at the site, and summarised
in a README index — and each copy drifts on its own. **The copy that gets read is
the one that governs behaviour**, so a correct ADR beside a stale paraphrase is a
rule that is not in force.

For each rule the ADR states, find its copies and compare them. Where to look,
in the order they are read: the project's conventions doc (`CLAUDE.md`,
`AGENTS.md`), the glossary (`CONTEXT.md`), the docstring or header comment of
the module the rule governs, the README's document index, the end-user or
developer documents the ADR names, and any sibling ADR restating it in passing.

- A copy that says something the ADR does not: a different threshold, owner,
  order, name, or an exception the ADR never granted.
- A copy that has **not** followed a correction the ADR already carries — the
  usual shape, since the ADR is where a decision is amended and the paraphrases
  are where nobody looks.
- A rule the ADR states and **no copy carries**, where every agent reads the
  copies. That is why the rule keeps being broken; say where it should be
  echoed.
- A copy that names a module, path or command the ADR renamed.
- The README index, or whatever the project maintains as its list of documents,
  not carrying this ADR at all.

**Name every copy, with its `file:line`.** A finding that names one of four is
worse than useless — repairing that one leaves three disagreeing copies and no
record that they exist. The kind is `echo`, and the repair edits every copy the
finding names.

Do not raise a copy that is *coarser* than the ADR and still true. A conventions
doc summarising a decision in one line is doing its job; only a copy that says
something different is a finding.

## tickets — the work the decision was cut into

The ADR's tickets are the copy of it that gets **implemented**. Whoever builds
the thing reads the ticket's acceptance criteria, not the decision behind them,
so a criterion that no longer matches the ADR is a rule that is about to be
broken by somebody following instructions correctly.

You are given the ticket set in your prompt — the spec issue and its children,
with each body. Do not go looking for more; the set was found before you were
spawned.

- A **criterion that contradicts a rule the ADR states now** — a different
  threshold, owner, path, default or order. Quote both.
- A criterion resting on a **name the ADR has since changed**: a module, a path,
  a command, a key. The ticket reads as current and cannot be followed.
- A rule the ADR states that **no open ticket carries**, where the decision is
  not yet built. That is the part that will quietly not happen; say which
  ticket it belongs on.
- A ticket **whose subject the ADR no longer decides** — the section it came
  from was amended away, or another ADR took the question over.
- A criterion the ADR's decision makes **impossible or already true**. Both mean
  the ticket was written against an older reading.

**Direction decides the kind, and you must say which way it runs.** The ADR was
amended after the ticket was written ⇒ `text` is wrong here: the document is
right and the *ticket* is stale, which nothing in this chain repairs — raise it
as `conflict` and name the ticket. Only where the ADR's own sentence is the
stale one is it `text`. A ticket that is simply ahead of the document — it
records a decision the ADR never took — is `conflict` too, and the user chooses
which side wins.

Never judge a ticket against the code, and never say whether it is done: that is
`dror-show-tickets`'s table and this lens has no business duplicating it. The
comparison here is document against ticket, both as written.

## outcome — did the decision do what it said it would

Every other lens asks whether the document is true, obeyed or clear. This one
asks whether it should still stand. An ADR predicts: this will be cheap, this
will be small, this will stop happening, this will be one place. The tree can
now answer, and a prediction the tree contradicts is the strongest possible
reason to reopen a decision — and the one nobody ever checks, because the
document is not wrong about anything.

- A **measurement** the ADR justified itself with — a timing, a size, a count,
  a rate. Re-measure it, with the command, and quote both numbers. A cache
  justified by 0.8 s that now costs 30 ms, or a 56 KB file that is now 4 MB, is
  the same finding in either direction.
- A **predicted consequence**: "writes become small and local", "one corruption
  costs one file", "callers stop having to know". Look for the thing that was
  supposed to stop happening, and say whether it did.
- A **cost the ADR accepted knowingly** — an explicit trade — that has since
  grown past what was accepted. Quote the sentence that accepted it.
- An **alternative it rejected** whose reason for losing no longer holds: the
  dependency it needed now exists, the platform it broke is no longer supported,
  the scale it could not reach is no longer wanted.
- A decision **overtaken in fact**: the thing it decides about was removed,
  replaced or subsumed, and no ADR records it. This one is `conflict` when
  another decision did the subsuming, and `revisit` when nothing did.

The kind is `revisit`, and it is the one kind nobody repairs: nothing is wrong,
so there is nothing to correct, and whether to reopen a decision is the user's.
**Every finding carries both numbers or both states** — what the ADR predicted
and what the tree shows — and how you measured. Without the measurement it is an
opinion about somebody else's decision, which is the one thing this pool must
never produce.

## misreading — the document read as instructions

Every other lens asks whether the document is **true**. This one asks whether it
will be **obeyed as meant**, which is a different failure and a worse one: a
stale sentence gets caught the first time somebody checks it against the code,
and a sentence that is true and gets acted on wrongly is never caught at all.
These ADRs are read as instructions — by an agent on every run, through the
project's conventions doc and its facts — so a rule that misleads is a defect in
the same sense a wrong number is.

Read the document the way a competent newcomer would, once, without the context
you have from the rest of this run. Then:

- **The unclear subject.** A rule in the passive or with no actor: who does
  this, at what moment, on whose behalf. "The record is written on close" —
  by which of the two writers, and which close.

  **A missing actor is not the finding; a wrong action is.** The test is whether
  a reader, not knowing who acts, would *do the wrong thing* — write to the
  wrong store, run at the wrong moment, skip a step they owned. Where the
  sentence records a **decision** and the actor is the implementation of it, the
  ADR is silent on purpose: a decision that named its call site would have to be
  rewritten every time the code moved, which is the drift these documents exist
  to avoid. "This names no site", "this names no reader", "this constant is
  unattributed", "the resolver is unnamed" — none of those is a finding on its
  own, and each was refuted repeatedly across five documents and eight days for
  the same reason. Ask what the reader does wrongly; if you cannot say, there is
  nothing here.

  What this loses is the genuinely ambiguous rule whose wrong action is real but
  awkward to state in one line. Take the awkward sentence over the drop where
  you can write it at all.
- **The soft modal.** `should`, `may`, `prefer`, `generally`, where the project
  actually treats it as `must` or `never`. The evidence is the tree: a rule
  every site obeys without exception is a `must` written weakly, and the weak
  wording is what licenses the next site to be the exception.
- **The loose term.** A word the glossary or the conventions doc fixes tightly,
  used here in its everyday sense — or one word covering two things that the
  code keeps apart. Say which sense a reader would take and what they would do
  with it.
- **The example that fights the rule.** A code block, a path, a diagram or a
  worked case that a reader will copy, and that does not do what the rule above
  it says. The example wins over the prose every time — assume it will be copied
  verbatim.
- **The unbounded scope word.** `every`, `only`, `never`, `always`, `all`, where
  the document itself carves out an exception later, or where the tree has cases
  the sentence sweeps in. Either the word is wrong or the exception is
  unrecorded; say which.
- **The buried rule.** An obligation stated once, in a subordinate clause, in
  the middle of a paragraph about something else. A reader who skims acts
  without it. Name the sentence and what they would miss.
- **The stale imperative.** An instruction to do something at a path, with a
  command, or through an interface that has moved. It reads as current and it
  cannot be followed.

**Every finding names the wrong action**, concretely: what a reader does after
reading this, and what they would have done had it been written sharply. A
finding that names no wrong action is a style note, and style notes are not this
skill's business — the ADR's voice is its author's.

The kind is `text`: the fault is in the document and the repair is a rewording.
Where the sharper wording would change what is *decided* rather than how it is
said, it is not this lens's finding at all — that is `decision`'s, and it needs
the user.

## reach — what the decision forces and the document leaves out

Only what the ADR's **own** decision makes unavoidable. This lens is where an
invented finding is most likely, so the test for every bullet is: does the
decision as written leave a reader unable to act?

- The **migration**: the decision changes a format, a path or a layout, and the
  document says nothing about what happens to what already exists.
- The **failure case**: what happens when the thing the decision relies on is
  absent, unreadable, or half written. An ADR about a store that never says what
  a miss means has left the reader to invent it.
- **Who enforces it**: a rule with no test, no assertion and no reviewer named.
  Say what would catch a violation today — if the answer is nothing, that is the
  finding.
- The **scope**: the decision names one case and the tree has three; the
  document does not say whether the other two are in.
