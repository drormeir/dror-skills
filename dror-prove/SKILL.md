---
name: dror-prove
description: Prove a ticket's acceptance criteria with tests, one test per criterion, each seen to fail before it counts. Use when the user names a ticket number and asks for tests for it, or asks which criteria are covered.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh)
---

# dror-prove

The ticket's acceptance criteria are the test list. Every criterion leaves this
run with **one final verdict** — what its test does against the real code once
the run is over — and the report says which, for every criterion, with the
failure that earned it.

The ticket number is this skill's one argument. Without it, say so and stop —
there is no default ticket and guessing one is worse than stopping.

**This run has a context of its own.** The frontmatter forks it (ADR 0036):
what reaches it is this file, the facts the line below injects, and the
arguments it was invoked with — never the conversation that invoked it.
Everything the run needs from that conversation arrives as an argument or not
at all; a question only the user can answer is returned as the result, and the
caller puts it; and what goes back to the caller is the closing summary.

This skill is **repo-agnostic**: it names no tracker, no path and no runner of
its own. Everything about the project in hand arrives through the facts below.

## How a test is written

`../dror-internal-shared/WRITING-TESTS.md` — the shelf beside this skill — holds the
rules every `dror-*` skill writes tests by: the red / green / red-by-mutation /
unproven vocabulary, the three rules every test obeys, where a test goes, how a
test is proved to bite when the code already works, and how expensive setup is
shared. Read it whole before writing anything. It is not restated here.

## The project facts

!`bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh`

The block above is the store's `facts.md`, printed by
`dror-internal-project-facts/facts.sh` before this text reached you, when its
stamp matched the tree (ADR 0037). Its test layout, verification commands and issue
convention are what matter here: write the tests the way this project writes
tests, run them with the command it actually uses, and read the ticket the way
this project tracks tickets. A block that begins `MISS:` means
the store could not answer: invoke the `dror-internal-project-facts` skill — it
gathers in a subagent, rewrites the store and returns the five facts — and hold
what it returns as the facts from then on. That skill is a **step of this
one**, not a hand-off; `../dror-internal-shared/DELEGATION.md` owns what that
means, at authoring time. Either way, the moment the facts are in hand,
**fetch the ticket, in the same turn**, the way step 1 says.

## Step 1 — read the ticket

Read it the way the **issue convention** fact says this repo tracks work. A repo whose
convention came back unstated stops here: say so and ask, rather than guess a
tracker. Take the `- [ ]` / `- [x]` lines under *Acceptance criteria*, in order,
and number them 1..N — that number is how every
later step, every test name and the report refer to a criterion, and it is the
numbering the other `dror-*` skills use for the same ticket. Read
`## What to build` too: it names the module the tests belong to. A ticket with
no criteria stops here — say so.

Fetch it every run. The body changes as boxes are ticked, so a cached copy is
stale exactly when it matters.

## Step 2 — find what is already covered

Before writing anything, look for each criterion in the tests that exist. Grep
the module's `tests/` directory for the behaviour the criterion names — the
function, the constant, the number, the refusal — and read the candidates rather
than trusting a name. A criterion already covered is reported as such and gets
no second test; a criterion covered *partly* (the case is there, the number in
the criterion is not asserted) is extended rather than duplicated.

Re-running this skill on one ticket must not grow the file: a criterion whose
test this skill wrote earlier is found here like any other.

## Step 3 — classify each criterion

Split what is left:

- **Behaviour** — an input yields an output, a state, a file, a refusal. These
  become tests.
- **Structural** — "imports neither Qt nor numpy", "the name exists in exactly
  one place in the source", "nothing here raises, whatever it is handed". These
  are testable too: an import assertion, a `Grep` count asserted in a test, a
  fuzz over hostile inputs. Prefer a real test over a note. A test that counts
  what is in the source is reading the tree rather than calling it, so
  `WRITING-TESTS.md`'s rule for a walk applies to it — an unpruned walk from the
  repository root finds the ADR worktree's copy of every file it matches, and
  says so only once the suite is run somewhere this run never runs it.
- **Not testable here** — a criterion about another ticket's work, about a
  platform this machine is not, or about a process. Say which, and why, and
  write no test. Never fake one with a test that asserts nothing.
- **Too vague to test** — a criterion that could be read two ways, where the two
  readings would assert different things. **Ask which**, naming both readings,
  and write nothing until it is answered. Guessing here is the worst outcome the
  skill can produce: a green box against a test that proves something else.
  Every other criterion carries on while the question is open.

Show this split and the seams you intend to test at **before** writing tests,
unless the user has already said to go ahead.

## Step 4 — one criterion, one slice

Work down the list, one at a time — not all tests first. Per criterion:

1. Write the test, by `WRITING-TESTS.md`'s rules.
2. Run it, and paste the output. The code not written yet means it must be
   **red**, and red for the reason the criterion names rather than an import
   error or a typo. The code already written means it passes first time and has
   proved nothing, so it earns its pass by **mutation** — that criterion's own
   negation, made in a scratchpad copy. Put the code back and run once more: the
   verdict is always what the test does against the unmutated code, and a run
   that reports while a mutation is still in the tree has reported on a repo
   nobody has.
3. Write only enough code to make it green, if code is this session's job at all.
   A tests-only request stops at red and reports it.

The test's name and a comment carry the criterion's number and its text, so a
reader of the test file can find the criterion and a reader of the ticket can
find the test.

## Step 5 — report

Run `printenv CLAUDE_CODE_ENTRYPOINT`. If it is `claude-vscode`, report one row
per criterion: **# | Criterion | Test | State | Note**. Otherwise the same rows
as one line each, in the same order, reading
`<n> — test: <name or none> — <state> — <note>`.

**State is the criterion's one final verdict**: what its test does against the
**real, unmutated code** at the end of this run. Seeing it fail first — before
the code, or in a mutated copy — is the *evidence* that the pass means
something, never a state of its own; a run that ends with a mutation still in
the tree has not finished. So `red by mutation` is not a verdict, it is what the
Note records.

State is one of:

- **`green`** — seen passing against the real code, **and** seen failing first.
  Say which failure earned it in the Note: `red first` (code written after) or
  `red by mutation` (with the mutation). It is the state that ticks; two others
  below (`already covered`, `gate`) tick on their own evidence, and nothing
  else does.
- **`red`** — seen failing, the code not written. The ordinary end of a
  tests-only run.
- **`unproven`** — the test is kept and passes, but was never seen to fail: no
  mutation could be staged. A pass nobody has tested is not a proof, so this
  does not tick.
- **`partial`** — the test proves part of the criterion and no test can prove
  the rest today (a clause naming another ticket's component, a platform this
  machine is not). Name the unproven clause in the Note. It does not tick:
  half a criterion is not the criterion.
- **`already covered`** — an existing test holds it, named, and was seen green
  this run. Ticks like `green`.
- **`gate`** — the criterion **is** the project's own verification gate: "the
  suite is green", "lint and the type-check pass", "the build succeeds". No test
  can hold it — a test asserting the suite passes is the suite — and it is
  verified all the same, by running those commands over the tree as it now
  stands. Three cases, in order: a green run of them already on screen with no
  change to the tree since is **quoted**, and ticks; where there is none and
  **this run is the last word**, run them once, at the end, and tick on that;
  where a caller will run them after this (the chain's own suite gate, which
  follows the repairs), leave it unticked with the Note naming the run it waits
  on, and that later step settles it. A red run does not tick and is not `red`
  either — that word is for work not done; say the gate is failing and quote it.
  Never write `not testable` for one of these: a criterion green in fact and
  unticked when its ticket closes is what that mistake produces.
- **`not testable`** — with the reason. No test written. It is for a criterion
  nothing here *can* judge — another ticket's work, a platform this machine is
  not, a process — never for one that is merely not held by a test of its own.
- **`criterion wrong`** — the criterion is precise, testable and **cannot be
  met as written**: the test bites exactly as it should and the behaviour it
  demands is not the behaviour that is right. This is the verdict for what only
  the end of the work reveals — the wording was reasonable when it was written
  and the implementation proved it wrong. Keep the test, red, and never soften
  it to pass. It does not tick, and it is **not** `red`: red is work not done,
  this is work done against a description that does not hold. The Note carries
  the clause that fails, why the code is right and the clause is not, and the
  wording that would be true — as a proposal, never as an edit. **Rewording is
  the user's,** so say plainly that this criterion needs their call, and change
  no criterion text under any circumstance.
- **`question open`** — waiting on the user, nothing written.

**Note** is empty only where a reader would be left guessing nothing; otherwise
it carries the failure that earned a `green`, the clause a `partial` leaves out,
or what could not be staged.

Below the rows: the summary line of the **targeted runs you actually made** —
the criteria's own tests and the existing tests found in Step 2, not the
project's full suite. Do not run the full suite here: this skill proves
criteria one at a time, and the suite gate belongs to the skill that changed
the code. A `gate` criterion is the one exception, and a narrow one: it quotes
that skill's run where there is one, waits for it where one is coming, and
earns a single run of its own only where neither is true. Then one closing
line — **how many criteria of N are ticked, and what the ticket needs before
the rest can be**. Never report a count you did not run.

## Step 6 — tick what went green

This skill holds the criterion-to-test mapping, so this skill owns the boxes: a
green suite says a criterion is met only to whoever knows which test covers it.

Tick — `- [ ]` to `- [x]` — every criterion whose verdict is `green`,
`already covered`, or a `gate` whose run is green **and already made**; a `gate`
still waiting on a later step's run is not one of them, and neither is a failing
one. A `criterion wrong` is left exactly as it
stands: ticking it would claim a proof, unticking or rewording it would settle
a question that is the user's. **A `green` earned by mutation ticks exactly
like one earned by writing the code**: the mutation is what made the pass count,
and a criterion the code already satisfies is met. `red`, `unproven`, `partial`,
`not testable` and `question open` leave the box as it stands. Write the body
back in one edit, and never untick a box this run did not judge — another run's
verdict is not this run's to withdraw.

Say how many boxes moved. A tests-only run that ended at red moves none, which
is the ordinary case and not a failure.

## Step 7 — record what the ticket is awaiting

A `partial` or a `not testable` whose reason is **another ticket's work** is a
dependency nobody wrote down: it was discovered here, by trying to prove the
criterion, and the ticket's `## Blocked by` was written before anyone knew. Left
in this reply it is lost by the next session, and the ticket reads as merely
unfinished for as long as it stands.

So write it into the body, in the **same edit as the ticks**. Under a
`## Awaiting` heading, one line per such criterion:

```
## Awaiting

- #<number> — criterion <n>: <the clause that ticket owns, in a few words>
```

Rules:

- Only where the owning ticket can be **named**. A criterion no other ticket
  owns is ordinary unfinished work — leave it alone and say so in the reply.
  Never invent a number to fill the line.
- The section is **rewritten** each run from this run's verdicts, so a criterion
  that has since gone green drops out of it. A criterion this run did not judge
  keeps its line untouched.
- No line for a ticket already named in `## Blocked by` — that dependency was
  known, and one fact belongs in one place.
- This changes no box. An awaited criterion stays `- [ ]`; the work is real and
  is not this ticket's to do.

Say which tickets the section now names. `dror-show-tickets` reads it as the
`Awaiting #NN` status, so a ticket that has finished everything it owns stops
looking like one nobody got round to.

## Step 8 — record what needs the user's call

A `criterion wrong` is recorded the same way and in the same edit, because it
too is a thing this run learned that the body does not say, and a red box says
"nobody did the work" when the truth is "the work is done and the sentence is
wrong". Under a `## Needs your call` heading, one line per such criterion:

```
## Needs your call

- criterion <n>: <what the code does> vs <what the clause demands> — proposed: <wording>
```

Rules:

- The criterion's own text is **untouched**, and so is its box. The section is a
  note beside it, never an edit of it: the decision it questions was the user's
  to make and the rewording is the user's to make too.
- Rewritten each run from this run's verdicts, like `## Awaiting`; a criterion
  this run did not judge keeps its line.
- The proposed wording is one line and a proposal. Do not open a discussion in
  the ticket body.

Where this run found such a criterion, name it at the end of what this run
reports and ask the user to settle it — this is the one outcome the skill
cannot carry any further on its own. Where it found none, this section produces
nothing and there is nothing to ask.
