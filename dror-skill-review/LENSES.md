# Lenses

You are one lens: the section named in your prompt is yours, and the skill is
reviewed through it alone. Within it, skip a bullet whose subject the skill
never raises — but account for every bullet as you work: each one applied, or
skipped for a reason. Return your findings plus only the bullets you skipped,
each with its reason.

**Your lens has one comparison target, and your heading names it.** A skill is
a document an agent executes mid-run, and it is not reviewed against a single
thing. Find your axis before you raise anything:

- **Against the harness** — `contract`. The evidence is the frontmatter read
  beside the body: a promise the description makes and the procedure breaks,
  quoted from both.
- **Against the tree** — `anchors`. The evidence is what is actually there —
  a listing, a grep, a command's output — and every finding quotes the pointer
  and what the tree answered instead.
- **Against itself** — `sequence`. The evidence is this document: two passages
  that disagree, or one passage and the question it forces and leaves
  unanswered, each quoted with its line number. **No `file:line` elsewhere is
  owed** — cite one only where a spawn step rests on an ADR that fixes its
  parameters.
- **Against the shelf and the siblings** — `ownership`, `mirrors`. The
  evidence is the other file, quoted with its own `file:line`: a shelf
  document, a sibling skill, an index row, a glossary line.
- **Against the reader** — `execution`. The evidence is the wrong move the
  executing agent makes after reading the sentence, stated concretely. The
  reader here is an agent mid-run, which asks nothing and does what the
  nearest hard rule says.
Five axes, and a finding is settled on **its own lens's** and no other.
Judging your finding by a neighbouring axis's standard is how a true one dies.

**Anthropic's published rules are not one of your axes.** A script settles them
before you are launched, and your prompt hands you its output as a file. Do not
re-report what it holds: a folder's case, the instruction file's spelling,
`name:` against the directory, the description's bound and its missing trigger,
an angle bracket in the frontmatter, a `README.md` in the skill folder. The
guide's advice about writing *well* is yours as usual, under `execution` and
`sequence`, where it always was (ADR 0049).

Every finding carries:

- the **sentence** it is about, quoted, with its line number and file within
  the skill's directory;
- the **evidence its axis admits**, above — never a `file:line` invented to
  satisfy a rule that is not yours;
- the **kind** — `text` (the skill is wrong, or is acted on wrongly), `hole`
  (the skill's own procedure forces a question it leaves unanswered), `sprawl`
  (a rule, tunable or vocabulary living in more places than its owner — the
  duplication itself, drifted or not), `echo` (the skill is right and a copy
  of it elsewhere has drifted — only the `mirrors` lens mints this one),
  `conflict` (two documents own one rule differently, or two skills decide one
  question two ways);
- **what would make it true**: the corrected fact, or the owning file a copy
  should point at, and the evidence for it. Not the replacement prose —
  writing that is the repair's job.

**A skill is allowed to be terse, and it is allowed to be opinionated.** Its
voice is its author's, and a style note is not a finding. A `hole` is a
question the skill's own procedure forces its agent to answer and then leaves
unanswered — never a section a template would have had.

**A skill is allowed to point.** "The rules are `X.md`'s, read it whole" is
the shape this repo prescribes, not an omission. The finding is the opposite
case: the rule restated where the pointer belongs.

## contract — the frontmatter against the body and the harness

The frontmatter is the half of the skill the harness executes: the description
is how the skill is chosen, the flags are how it is run.

- The **description against the body**: a deliverable the description promises
  and no step produces, a trigger clause naming a situation the procedure does
  not handle, a body that grew a capability the description does not mention —
  so the skill is never chosen for it.
- The **`name:`** against the directory's name. They must match, or the two
  halves of the skill are two skills.
- The **fork flags**: a skill the user runs to work a chain carries
  `context: fork` and `background: false` and opens by telling its reader the
  conversation does not reach it, and takes everything as arguments (the repo's
  conventions state this; quote them). A skill missing one half of that
  contract behaves differently invoked than described.
- The **injected commands**: an `allowed-tools:` line or a `` !`command` ``
  injection naming a script — check the script exists at the path the line
  spells, with `${CLAUDE_SKILL_DIR}` resolved to the skill's own directory.
- A **companion file** the body names — a lens pool, a brief — that the
  directory does not hold, or a file in the directory nothing names.

## anchors — every pointer against the tree

The lens that finds the ordinary rot, worth running on almost every skill. A
skill executes by following its own pointers, and a dead one is a step that
fails silently mid-run.

- A named **path** — a shelf file, a store file, a log, a scratch location —
  that does not exist, moved, or was renamed. Search before raising: a name
  that survives in one place and not another is a rename half done.
- A named **skill** — invoked as a step, pointed at for routing — that no
  longer exists under that name, or whose own contract has changed out from
  under the sentence (it no longer takes that argument, no longer returns that
  line).
- A quoted **command**: run it where it is cheap and read it where it is not.
  A flag that no longer exists, a script whose interface moved, a `gh` shape
  the tracker no longer answers.
- A **number or a column list** quoted from another file's contract — a log
  schema, a cap, a report name — that the owning file now states differently.
  Where the skill *restates* rather than points, that is `ownership`'s
  finding; yours is the restatement being *wrong*.
- A named **ADR** whose number does not resolve, or whose decision no longer
  says what the citing sentence claims.

Distinguish two outcomes and say which: the skill drifted (`text`), or the
skill and another owner both changed and now disagree with each other
(`conflict`).

## sequence — the procedure against itself

- A **step that invokes another skill and ends on no named next action** — a
  rule about reading the sub-skill's stop instead of a command, a file to
  read, the next invocation. The shape is the shelf's `DELEGATION.md`; quote
  the step and say what a run does at that boundary: it stops with the
  caller's work undone. Kind `hole`.
- A **closing contract that no longer stops a direct run** — a stop, a "wait",
  a "nothing else" that has been softened, or that now carries an exemption for
  a caller invoking this skill as a step. The shelf's `DELEGATION.md` puts that
  fix in the caller and never in the sub-skill, and every one of these skills is
  also typed by a user on its own. Quote the closing sentence and say what that
  user gets instead — findings asked for and a tree edited. Kind `text`.
- A **spawn step against the brief it hands** — a step that launches an agent
  and names the inputs it gets, beside the companion file that agent is told to
  read whole. The finding is an input the brief works from and the step never
  passes, an input passed that the brief never reads, or a spawn parameter the
  repo's own decisions fix (which model a lens runs on is ADR 0003's) that the
  step omits. Quote both, and say what the spawned agent does with what it
  actually receives. Kind `hole` where an input is missing, `text` where the
  step and the brief simply disagree.
- **Work the procedure never bounds** — a step that spawns one agent per item
  of a set the skill does not bound, or hands an agent a tree to read with no
  boundary on it, where the skill elsewhere bounds such a step. Quote the step
  and the bounded one beside it, and say what a run costs on a large input.
  Where the skill's own text says the bound is deliberate — an argued decision
  not to cap — that is the answer and there is no finding. Kind `hole`.
- A **word used before or without definition** — a term of art the skill
  coins mid-procedure and never fixes, or uses in two senses. Kind `hole`.
- **Two passages that disagree**: a cap stated twice with two values, a step
  order stated one way and diagrammed another, an "always" up top and an
  exception below that the top never grants. `text` when one passage is
  plainly the stale copy; `conflict` when both read as deliberate.
- A **step that says only what success does** — a command that can fail, a
  lookup that can come back empty, a name that can resolve to two things — and
  leaves the run nothing for the other outcome. Raise it only where that
  outcome is one the step's own command produces and the next move genuinely
  differs; a step that lands the same either way is nothing. Say what the agent
  improvises instead. Kind `hole`.
- A **return contract** the closing section does not carry: a skill that
  ends on a bare "done" leaves its caller nothing to relay.
- A **done-when line** that does not match the steps above it — an obligation
  the steps create and the closing list forgets, or the reverse.

## ownership — rules, tunables and vocabularies against their owners

This repo's conventions say where a rule may live: a shared rule once, on the
shelf, pointed at; a tunable a numeral only in the file that enforces it; a
closed vocabulary defined inside the text pasted to the agent that mints its
values. This lens holds the skill to that, and its kind is mostly `sprawl` —
the duplication is the defect even before it drifts, because it is how the
next drift is made.

- A **shelf rule restated** in the skill's own words where a pointer belongs.
  Quote both; the shelf's copy is the owner unless the shelf's own header says
  otherwise.
- A **tunable spelled as a numeral** in a file that does not enforce it — a
  cap, a floor, a count that another file owns. The finding names the owner.
- A **closed vocabulary restated** outside the text that mints its values — a
  kind list, a lens list, an outcome list repeated where an agent could read a
  stale copy of it.
- **Two files that both claim ownership** of one rule — each with a header or
  a sentence saying the meaning is theirs. That is `conflict`, and the user
  picks the owner.
- **Pasted text where a path serves**: a step that writes another file's
  content into an agent's prompt, against the point-never-paste rule the repo
  states. Quote the step and the rule.

## mirrors — the copies of this skill elsewhere

A skill is not only read from its own file. Its description is quoted in an
index, its role mapped in an agent-facing map, its terms fixed in a glossary,
its name spelled in siblings' routing sentences — and each copy drifts on its
own. **The copy that gets read is the one that governs**: a correct skill
beside a stale map row is a skill that is chosen wrongly.

Your prompt hands the grep capture of the skill's name; work from it. For each
copy, compare it with what the skill itself says now.

- An **index row** (in this repo, `STRUCTURE.md`) whose quoted description no
  longer matches the frontmatter's, word for word minus the trigger clause —
  the repo's own rule is that the frontmatter is the single source.
- A **map entry** (here, `DROR-SKILLS.md`) that routes a finding kind, a
  question or a tier this skill no longer answers, or misses one it now does.
- A **glossary line** fixing a term this skill has since renamed or
  redefined.
- A **sibling's sentence** naming this skill for something it no longer does,
  or spelling its old name.
- A copy the skill's own text says must exist and **does not** — a missing
  index row, an absent map entry.

**Name every copy, with its `file:line`.** The kind is `echo`, and the repair
edits every copy the finding names. Do not raise a copy that is *coarser* than
the skill and still true — an index summarising in one line is doing its job.


## execution — the skill read as its agent will run it

Every other lens asks whether the skill is **true**. This one asks whether it
will be **executed as meant**, which is a worse failure: the reader is an
agent mid-run, which asks nothing, takes the nearest hard rule as binding, and
does what the sentence says rather than what the author meant. A misleading
sentence here does not wait to be noticed — it runs.

Read the skill once, cold, the way a fresh context would. Then:

- **The unclear actor.** A step in the passive, where the run cannot tell
  whether *it* acts, spawns an agent to act, or waits for the user. The test
  is whether the wrong choice is available and consequential — a step that
  reads either way but lands the same is nothing.
- **The soft modal.** `should`, `may`, `prefer`, where every other sentence
  and the repo's rules treat it as `must` or `never`. The weak wording is what
  licenses the exception.
- **The unbounded scope word.** `every`, `only`, `never`, `always`, where the
  skill itself carves out an exception later, or the tree holds cases the
  sentence sweeps in. Either the word is wrong or the exception is unrecorded;
  say which.
- **The example that fights the rule.** A command block, a path shape or a
  worked case the agent will copy verbatim, and that does not do what the rule
  above it says. The example wins over the prose every time.
- **The buried obligation.** A duty stated once, in a subordinate clause, in
  the middle of a paragraph about something else — an append, a log line, a
  file to mark — that a run skims past and never performs.
- **The unpaired prohibition.** A step that steers by ban alone, naming no
  target behaviour in the same breath. Naming the forbidden move puts it in
  context and makes it *more* available, not less — the ban half-reads as the
  instruction — so the fix is the positive target stated beside it, and a
  prohibition earns its place only as a guardrail that cannot be phrased
  positively. The finding is the ban standing alone, not the word "never": a
  prohibition paired with the move it sharpens is the house style.
- **The no-op.** A sentence the agent already obeys by default, paying context
  for nothing. The test is behavioural and model-relative — would a run without
  this line do anything different? — so raise it only where you can say what
  the default already is, and let the finding cover the whole sentence rather
  than the words you would trim from it.
- **The trap boundary.** A step whose *output shape* invites a stop — a
  finished table, a written report, a returned command — in a skill that must
  continue. `DELEGATION.md` names the pattern; the finding is a boundary the
  skill does not flag as one.

**Every finding names the wrong move**, concretely: what the executing agent
does after reading this, and what it would have done had the sentence been
written sharply. A finding that names no wrong move is a style note, and style
notes are not this pool's business.

The kind is `text`: the fault is in the document and the repair is a
rewording. Where the sharper wording would change what the skill *does* rather
than how it is said, raise it as `conflict` — changing behaviour is a
decision, and it needs the user.
