# Glossary

The words the `dror-*` skills use, one entry per term. Two neighbours carry the
rest: why a skill behaves as it does is in [`docs/adr/`](docs/adr/), and what
each skill is for is in [`DROR-SKILLS.md`](DROR-SKILLS.md). This file owns only
the terms no rule file carries; an entry whose rules live in a shelf file is a
condensed pointer, and that file owns the term.

## The work being described

- **ADR** — a written decision. In a project, a numbered file in a conventional
  decision directory ([`ADR-FILE.md`](ADR-FILE.md) owns which, and how the
  number resolves); for these
  skills, the files under `docs/adr/` beside this one. **Two numbering spaces,
  one word and one path shape**: a project's ADR 0011 and the skills' ADR 0011
  are unrelated documents, and a bare number is ambiguous outside the file that
  writes it. Inside a `dror-*` skill or its ADRs, a bare `ADR 0011` is the
  skills' own; anywhere a project is being discussed, say which set — "the
  skills' ADR 0018", "the repo's ADR 0002" — because a reader who looks in the
  wrong directory finds either the wrong decision or none.
- **Spec issue** — the parent issue that turns one ADR into work. Carries no
  acceptance criteria of its own.
- **Ticket** — a child issue of a spec issue, carrying one piece of the work.
- **Acceptance criterion** — one `- [ ]` line in a ticket's *Acceptance
  criteria* section. The contract: what a test is written against, what a review
  judges, and what a closed ticket means.
- **Criterion number** — the position of a criterion in its ticket's list,
  1..N, in the order the body lists them. Every `dror-*` skill numbers the same
  ticket the same way, so a test name, a review verdict and a report row all
  name the same criterion.
- **Unpushed work** — the commits a branch is ahead of its base by, plus staged,
  unstaged and untracked source. What `dror-review` reviews.
- **Base** — the commit a diff is taken against.

## Findings

- **Finding** — one defect, hazard or gap named by a review, after merging.
- **Bug** — production code is wrong. A finding already named in the
  conversation; `dror-repair` discovers none of its own.
- **Latent hazard** — code correct today that this diff made fragile, naming the
  future change that would break it **and the live caller that reaches it now**.
  Where every path in is clamped, guarded upstream or has no caller, it is not a
  hazard (ADR 0030).
- **Gap in cover** (also **cover**, as a finding's kind) — named behaviour that
  no test would catch the loss of. Nothing is broken, so nothing is fixed; the
  test alone is the deliverable.
- **Unmet criterion** — a criterion the diff claims and misses. Neither a bug
  nor a gap in cover.
- **Lens** — one review perspective, defined by a section of
  `dror-review/LENSES.md` or of `dror-adr-review/LENSES.md`, run as one agent
  that proposes findings.
- **Refuter** — the agent handed one merged finding whose job is to kill it.
- **Claim** — a comment written into source recording an invariant that is
  invisible at the site. Written by a refuter, verified rather than trusted by a
  later lens.

## Findings about an ADR

The kinds `dror-adr-review` returns. They are separate words because each
names a different hand as the one that fixes it.

- **Text** — the document says something about the code that is not true, or
  says something true that a reader acts wrongly on. `dror-adr-repair` fixes it.
- **Hole** — something a decision record must carry is missing: the alternative,
  a consequence, the scope, the migration. Filled only where it can be grounded.
- **Breach** — the code breaks a rule the ADR states, at a named `file:line`.
  The document is right; `dror-repair` fixes the code.
- **Conflict** — two decisions disagree, in one document or across two. Nobody
  repairs it without the user, because picking a side is deciding.
- **Revisit** — nothing is wrong, and what the decision predicted has not held:
  the measurement it stood on now reads differently, or the reason its rejected
  alternative lost no longer applies. Carries both numbers, the predicted and
  the measured. Nobody repairs it either — reopening a decision is the user's.
- **Echo** — a copy of an ADR's rule living where the rule is actually read: the
  conventions doc, the glossary, a docstring at the site, a README index. The
  copy that gets read is the one that governs, so a correct ADR beside a stale
  copy is a rule not in force. An `echo` finding names every copy and is
  repaired in all of them at once.

## Evidence for a document

A sentence is settled by reading the tree, so the two words below stand where
**red** and **green** stand for code.

- **grounded** — the corrected sentence was read out of the tree as it stands
  now, and the run can quote the `file:line` or command output that says it.
  Every sentence `dror-adr-repair` writes is grounded.
- **ungrounded** — nothing in the tree settles it. The sentence is not written;
  the question goes to the user.

## Evidence

These words are the same in every `dror-*` run. `dror-internal-shared/WRITING-TESTS.md`
holds the rules that go with them.

- **red** — the test was run and its failing assertion pasted, with the run's
  summary line.
- **green** — the test was run after the code exists and its passing summary
  line pasted.
- **red by mutation** — red earned in a copy of the repo in the scratchpad, with
  the named behaviour broken there. How an item whose code already works gets
  the same evidence.
- **unproven** — the mutation cannot be staged. The test is kept and named; what
  is missing is the evidence, not the test.
- **untestable** — no reasonable test can catch it at all. No test is written,
  and the reason is recorded.
- **covered** — a bug that went red and then green.
- **enrich** — extend a test that already exists so it also covers a new item,
  rather than adding a file.

## The ADR worktree

`dror-internal-shared/WORKTREE.md` holds the rules that go with these.

- **ADR worktree** — `<repo>/.claude/adr-wip/adr-<N>`, a `git worktree`
  holding one ADR's work so it is never another run's review scope. Beside the
  repo, `../<repo>-adr-<N>`, in trees made before the placement changed
  (ADR 0029).
- **ADR branch** — `adr-<N>`, the branch that worktree is on, with `<N>` the ADR's
  number unpadded. Local and remote carry the same name.
- **Guard** — one condition a project must satisfy before a worktree may sit
  inside it: `.claude/` gitignored, pytest's `norecursedirs` naming it, mypy's
  `exclude` covering it. A guard that does not hold stops the run.
- **Preflight** — the four checks run from inside a worktree before the first
  ticket: which interpreter, which tree imports resolve to, whether there is an
  upstream, and whether the guards still hold. It proves the environment rather
  than building it, and it runs on an adopted worktree too.
- **Drain state file** — `drain-<ADR>.json` in that worktree's store: the drain's
  current position, not a history. The work list, what remains, which numbers
  were attempted, and one entry per round.
- **Drain progress log** — `drain-<ADR>.log` beside the state file: the drain's
  per-round lines in the order they happened, appended and never rewritten. A
  forked run's text returns only at the end (ADR 0042), so this is the only way
  to watch a drain while it works — `tail -f` it.
- **Round outcome** — `picked` when a ticket is taken, rewritten to `finished`,
  `skipped` or `stopped` when its round ends. An entry left at `picked` is an
  interrupted round, and it is the only thing that distinguishes one from a
  completed ticket (ADR 0031).
- **Directory override** — `dror-implement-adr` §0a's sentence, "All commands
  run in `<path>` …", carried verbatim into every prompt a drain hands down.
  Prose to every agent that obeys it; an argument to `dror-review` and
  `dror-repair`, and the signal on which `dror-implement-ticket` folds its
  review-repair loop into its own context, keeping the chain's forks under
  the harness's spawn-depth cap — which strips an agent at the cap of its
  spawn tool and silently drops a forked skill's arguments (ADR 0043). The
  duties an obeying fork honours are `DIRECTORY-OVERRIDE.md`'s, on the shelf.
- **Step agent** — a spawned agent given another dror skill's file to follow,
  the carrier `dror-review-repair` and the drain's fold use in place of a
  `Skill` fork, which can arrive without its arguments when made from inside
  a fork (ADR 0044). How one is spawned and what its brief opens with are
  `STEP-AGENT.md`'s, on the shelf.

## The stores

These words are the same in every `dror-*` run.
`dror-internal-shared/REPORT-STORE.md` holds the rules that go with them.

- **The store** — `<repo>/.claude/dror-skills/`, holding what these skills learn about
  a repo. Disposable: every value in it is re-derivable.
- **Facts** — `facts.md` in the store: the five project facts, each run's answer
  to what this repo declares, ending in a stamp.
- **Stamp** — the list of files a gather read, each with its size and `cksum`
  checksum, plus the facts file's own size.
- **Review report** — `review-report-<ticket>.md` in the store (bare
  `review-report.md` for a review of no ticket): that review's survivors and
  kills, with the base and `HEAD` its line numbers came from. One file per
  ticket, so two sessions reviewing two tickets in one checkout cannot overwrite
  each other.
- **ADR review report** — `adr-review-report-<adr>.md` in the store: the same for
  one ADR review, named the same way and for the same reason. A separate family
  from the code review's, so neither review can erase the other's findings.
- **Identity line** — `Ticket: <n>` or `ADR: <n>` in a report's front matter,
  and the report's identity: a name can be taken, mistyped or slugged, so only
  the line inside can be compared against the number a reader was handed
  (ADR 0021).
- **Refutation log** — `~/.claude/dror-skills/refutations.tsv`, outside any repo: one
  line per merged finding, appended by every review and never rewritten. Its
  `summary` is what a finding *claimed*; why it died is in the report the
  `report` column points at, for as long as that report is the current one. Its
  `round` says which round of a caller's loop raised the finding, which is what
  makes a loop's rounds separable at all (ADR 0041).
- **Run log** — `~/.claude/dror-skills/runs.tsv`: one line per review, naming the
  lenses run and the lenses dropped. The denominator the refutation log cannot
  hold, since a lens that finds nothing writes no finding. It also carries the
  run's `elapsed_s`, the only record of what a review costs in wall-clock.
- **Repair log** — `~/.claude/dror-skills/repairs.tsv`: one line per finding a repair
  handled, appended by `dror-repair` and by `dror-adr-repair`, keyed by the
  report's finding id, carrying that run's outcome and the
  files that run edited. What
  says whether a survivor was a real defect once somebody tried to fix it — and,
  read across a head's rounds, which findings a round had in scope and did not
  return.
- **Finding id** — `<head>-<tag>-<hhmm>-<n>`: the short commit a report was
  written at, the run's tag, the minute it was written, and the finding's number
  in it. The one key joining a report, the refutation log and the repair log;
  the report carries no lens and a `file:line` moves. Two older shapes are in the
  logs — `<head>-<hhmm>-<n>` and `<head>-<n>` — so an id is matched **whole** and
  never split into parts (ADR 0025).
- **Run tag** — four hex characters minted per review run. Names the *run* in a
  report's front matter and in `runs.tsv`. It is not the report's file name,
  which ADR 0021 derives from the ticket — except where a caller names the path
  instead, as `dror-review-repair` does with `review-report-<tag>-r<n>.md` and
  `dror-adr-review-repair` with `adr-review-report-<n>-<tag>-r<k>.md`, one
  file per round (ADR 0041).
