# The carrier rule is a script

Four decisions now say the same thing — ADR 0043 found it, ADR 0044 decided it,
ADR 0055 and ADR 0056 finished it: **a `Skill` fork made from inside a forked
context can arrive without its arguments, so a step rides a spawned agent.**
Nothing enforced it but the prose in each skill's own file.

## The defect

`dror-skill-review-repair` was written into the forbidden shape at `1d09c74`,
three hours after ADR 0044 forbade it at `44c6cc2` on the same day. It stayed
that way for a week, through several of its own runs, and was found only when a
review of the loop happened to raise it as a `conflict`. ADR 0044's deferral
list was never updated either, so the map did not show the skill as a candidate
at all.

That is the failure mode of a convention held only in prose: it binds the
author who remembers it. The repo has grown by several skills in a fortnight,
which is the churn rate at which a remembered rule decays.

The rule is entirely decidable by reading files. A caller's frontmatter says
whether it forks. Its body says which skills it invokes. The target's
frontmatter says whether it forks. Nothing needs judgement.

## Considered options

**A lens** — asking `dror-skill-review`'s `contract` or `sequence` lens to check
it — was rejected on ADR 0049's reasoning, applied again: a lens has to be
chosen before it can look, its finding then costs a refuter, and a model asked
to decide a two-file string comparison can only do it worse than `grep`. ADR
0049 moved Anthropic's published rules out of a lens for exactly this; the
argument does not change because the rule is ours rather than theirs.

**Adding the check to `skill-rules-check.sh`** was rejected: that file declares
itself the mechanical half of `ANTHROPIC-SKILL-RULES.md`, and a house rule of
this repo's is not that. One script per owner keeps each answerable to one
document.

**Leaving it to review** was rejected by the evidence above. A review found it
eventually, at the cost of a full loop over a skill nobody suspected, and only
because a lens chose to look.

## The decision

`dror-internal-shared/carrier-check.sh` takes a skill directory and prints one
`BREACH:` line per invocation of a forked skill from a forked caller, or
`CLEAN`. It reads **every Markdown file in the directory**, not only
`SKILL.md`: a companion is prose the same forked run executes, and the first
version of this script — which read `SKILL.md` alone — missed
`dror-implement-ticket/SETTLING.md` invoking `dror-prove`. `dror-skill-review` runs it in the mechanical pass beside
`skill-rules-check.sh`, and its breaches are handled identically: reserved lens
name `tool`, `survived` by construction, kind `text`, no refuter (ADR 0045,
ADR 0006).

**The exempt pairs live in the script**, each with the decision granting it,
because the script is the file that enforces the rule. Two today:
`dror-implement-ticket` → `dror-code-review-repair` (ADR 0044, 0055, 0056) and
`dror-implement-adr` → `dror-implement-ticket` (ADR 0056).

## Consequences

A skill written into the forbidden shape now fails its own review the first
time anyone runs one, rather than surviving until a lens is curious. Adding a
deliberate exception means editing the script, which is a visible act with a
place to name the decision — where before it meant editing nothing.

**It reads prose, so it is approximate.** The check looks for a `dror-*` name
the verb `invoke` governs, and skips lines that forbid one. A skill that
invokes another by some other phrasing is not caught, and a false positive is
possible. It was calibrated against the pre-fix `dror-skill-review-repair` taken
from git history, which it catches, and against every skill in the tree, which
it passes; and both exemptions were confirmed to suppress a real detection
rather than nothing. That is a check worth having, not a proof.

**It does not check the other half.** ADR 0056 requires a driver to read a step
agent's returned toplevel before anything else. That is a rule about what a
skill's prose says it does with a return, and no grep decides it. The scripts
now cover the carrier's shape; its duties remain a reading matter.
