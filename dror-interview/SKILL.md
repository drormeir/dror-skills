---
name: dror-interview
description: Ask, one multiple-choice question at a time, everything a drain of this ADR can be expected to stop on - the conflicts between its tickets, the values they decided for you, the criteria that look unwinnable, and the standing permissions - each with a recommendation where the run honestly has one, and room to answer in your own words, and write the answers where dror-implement-adr reads them. Use when an ADR is about to be drained unattended, or when a drain keeps stopping to ask things you could have answered up front.
disable-model-invocation: true
---

# dror-interview

One ADR goes in. The run works out every question a drain of it can be expected
to stop on, puts them to the user **one at a time, as choices**, and writes the
answers to a file the drain reads instead of stopping. Each answer shapes what is
asked next. It implements nothing, commits nothing and touches no ticket.

**What it is for.** A drain runs for hours with nobody watching, and every stop
costs the rest of that time — a question asked at 3am is answered at 8am, and the
machine did nothing in between. Most of those questions are answerable **before
the first ticket is picked**: they come from the ticket set as written, not from
anything the drain does. This run asks them while somebody is there.

**It is the drain's questions, not its work.** Which ticket to work, in what
order, in which tree, and what to build are `dror-implement-adr`'s. This file
adds one thing: the answers being on disk before the run starts.

**It is convention-bound** (ADR 0011), inheriting from `dror-implement-adr` and
`dror-adr-review`: an ADR by number, its tickets in the tracker the facts name,
and the decision directory `../dror-internal-shared/ADR-FILE.md` resolves.

The ADR number is this skill's one argument. Without it, say so and stop.

## 0. This run does not fork, and that is why it can ask

A forked run's question reaches the user only as its last message, which ends
the run (ADR 0042); it cannot take the answer and ask the next. Asking, answer
after answer, is the whole of this skill. So it carries no `context: fork`, as `dror-adr-resume` and
`dror-adr-sweep` do not — and it keeps the chain's depth unchanged for the same
reason theirs do (ADR 0043): the review it invokes lands where a review the user
typed lands.

It holds little: one review's summary, one table, and the answers as they are
given.

## 1. Find the questions

Three sources, in this order, and each is named on screen as it is read.

**The ticket set, through a review.** Invoke the `dror-adr-review` skill for this
ADR. It is the same check the drain runs before its first ticket, and running it
here is what makes that one find nothing new. What this run wants from its report
are the kinds that reach a user. What each kind **means** is minted in
`../dror-adr-review/LENSES.md`'s preamble, and which hand fixes it is owned by
`../dror-internal-shared/DROR-SKILLS.md`; neither is restated here. The three
that reach the user, and so become questions:

- every **`conflict`** the report carries;
- every **`unstated`** — the ones the user most often did not know they had
  decided;
- every **`revisit`** item the report carries.

A review that writes no report — a stub or superseded ADR — is one line, and this
run carries on to the other two sources: a stub ADR has no decision to argue
with, and its tickets can still stop a drain.

**The table, through `dror-show-tickets`.** Its rows carry three things this run
must ask about and the review cannot see: a **`Needs your call`** row, a row
whose status is unreadable, and a **cycle** — tickets that block each other, which
`dror-implement-adr` cannot untangle and will stop on.

**The standing permissions**, which are the drain's own stop list and are the
same every run. They are in §2.

**Immediately after the review returns, and in the same turn, invoke
`dror-show-tickets`** — its stop is its own and this run has two more sources to
read (`../dror-internal-shared/DELEGATION.md`, at authoring time).

**The table is the second place this step ends by mistake** — a deliverable's
shape followed by a prohibition against guidance, in `DELEGATION.md`'s words —
and its stop is its own and not this run's. So: **immediately after
`dror-show-tickets` returns its table, and in the same turn, put §2's first
question with the harness's question tool.** That call is this step's last move,
and a turn that shows the table and asks nothing has stopped here. The third
source needs no reading — §2 holds the standing permissions in full.

## 2. Ask them one at a time, as choices

**One question per turn, and wait for the answer before composing the next.** The
answers change what is still worth asking — a conflict settled in one ticket's
favour retires the questions about the other, a criterion the user calls wrong
retires the ticket that carries it, and a user who answers *stop* to the first
two permissions has said this drain is not being left alone, which changes what
the rest of the interview is for. A batch of questions asked at once cannot
adapt to any of that, and it puts the longest list in front of the reader at the
moment they know least.

**Every question is a choice, put with the harness's question tool**, which is
what makes an answer one click rather than a paragraph, and which always offers
free text beside the options for the answer that is none of them:

- **Two to four options**, each naming what happens if it is chosen — not what it
  is called. "Work it anyway; if the tree turns out to hold somebody else's work
  the drain still stops" is an option; "override" is not.
- **The recommended one first, with `(Recommended)` at the end of its label**,
  and the reason for the recommendation in its description.
- **Where there is no honest recommendation, say so and recommend nothing.**
  Which of two conflicting tickets gives way is the user's decision and this run
  has no standing to prefer one — put them in the order they appear and let the
  descriptions carry the consequences. A recommendation invented to fill a slot
  is this run answering its own question.
- **The evidence goes in the question, not in the options**: the two criteria
  quoted, the ADR's silence, the row as the tracker shows it, the ticket numbers.

**Write it in plain words.** No kind names, no skill names, no section numbers in
what the user reads: not "an `unstated` from the `tickets` lens", but "ticket #131
says the cache holds 200 entries; the decision never says how many". The reader
is deciding about their project, not about this machinery.

**Order them so the answers can do the most work**: the questions that can retire
other questions first — the conflicts between tickets, then the criteria that look
unwinnable, then the values a ticket decided that the ADR left open — and the four
standing permissions last, since they apply to whatever survives.

**The standing permissions** are the same four every run, and each is a choice
between working on and stopping:

- **A ticket refuses because the tree is dirty.** Work over it, or stop?
- **A ticket refuses because a blocker of its is open.** Work it anyway, or stop?
- **A ticket is still owed another review round at its cap.** Park it and carry
  on, or stop the run?
- **A criterion cannot honestly be implemented.** Park that ticket and carry on,
  or stop the run?

**Three things are never asked, because no answer makes them safe**, and saying
so on screen is part of this run:

- a **red baseline** before the first ticket — every ticket would be worked
  around a failure that is already there;
- a ticket run that reports it was **in the wrong tree** — nothing is known about
  what it wrote or where;
- a **dirty tree holding somebody else's work** — committing it would put it under
  this ADR's number.

Each of those ends a drain whatever this file says, and the drain's §3a owns
them.

**One sitting is the promise, not one message.** The point of this skill is that
the user answers everything now rather than at 3am; asking in sequence keeps that
promise as long as the sequence runs to the end without going away to do
something else between questions.

**Say nothing about how many are left.** There is no honest number to give: an
answer retires the questions it makes moot, so a total stated at question two is
wrong by question three, and a total that silently shrinks is worse than none.
The questions come one at a time and the list only ever gets shorter.

**A question the user declines is a legitimate answer.** Free text saying "leave
it", or a skipped question, records as unanswered, and the drain treats it as a
question it does not hold — which parks that ticket rather than guessing.

**Stop asking when the answers say to.** A user who has answered *stop the run*
to every permission has told you they will be watching; say that the remaining
permission questions no longer change anything, ask whether to go on, and take
the answer.

## 3. Write the answers down

`<the user's checkout>/.claude/dror-skills/interview-<ADR>.md`, plain
Markdown, one section per question: the question, the evidence, the options as
they were put, and the answer as given — or `unanswered`. Front matter carries
the ADR, the time, and the review's report path.

**Append each answer as it is given**, not at the end of the interview. An
interview interrupted after four questions has four answers on disk and is worth
resuming; one that writes at the end has nothing.

**Record the answer the user chose, in their words or the option's**, and where
they wrote free text, that text verbatim — it is the answer the drain reads, and
a paraphrase of it is this run editing a decision it was told.

**It is written to be edited by hand.** The user answers three more of them a week
later in their editor, and the drain reads the file as it stands. Nothing here
parses a schema: a question, an answer, in the order they were asked.

**A file already there is read first and updated, never replaced.** An answer
already given stays given unless this run's user changes it, and questions that
have gone away — a ticket closed, a conflict repaired — are struck through rather
than deleted, so a reader can see what stopped being asked.

**A question this interview retired is written down too**, struck through the
same way, naming the answer that retired it. It has no answer and it is not
`unanswered`: it was never put. It is written for the same reason a question
that went away between runs is — the file is read by hand a week later, and a
question simply absent looks like one nobody thought of, which is how it gets
asked again.

**Say the path on screen**, and say that `dror-implement-adr` reads it by that
name. It is the whole product of this run.

## Present

No count. The user answered them one at a time and knows what they answered; a
tally of what they just did is ceremony, and the total it would be a fraction of
never existed. Say instead the two things they cannot know: **which questions
were left unanswered**, since each one parks its ticket, and **which were
retired without being asked**, with the answer that retired each — those were
never put in front of them. Then the file's path. Then the one line that says what a
drain will now do — that it holds standing answers for the permissions the user
settled, and that anything unanswered parks its ticket rather than ending the run
(`dror-implement-adr` §3a owns that rule).

Then the command as the user would type it:

> `/dror-implement-adr <N>`

Done when every question from the three sources that was still live when its turn
came was put — one at a time, as a choice, with its consequences in the options
and a recommendation where this run honestly has one — the answers are on disk at
the named path, the unanswered ones are marked as such, the retired ones are
struck through with what retired them, and the drain's command is on screen.

A question an earlier answer retired was never live, and its absence is not an
unfinished run: the losing ticket's questions once a conflict is settled, the
questions about a ticket whose criterion the user called wrong, and the remaining
permission questions where the user answered *stop the run* to every permission
and then said not to go on.
