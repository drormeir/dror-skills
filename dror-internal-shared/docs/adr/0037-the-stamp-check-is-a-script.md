# The stamp check is a script, run before the skill's text is read

`dror-internal-project-facts/facts.sh` does step 1 of that skill — reads the
store's `facts.md`, checks its stamp with `cksum`, looks for a check-list file
the stamp omits — and prints the facts on a hit or one `MISS:` line otherwise.
Every chain skill opens with
`` !`bash ${CLAUDE_SKILL_DIR}/../dror-internal-project-facts/facts.sh` ``, so the
facts are inside the skill's own text before the model reads a word of it, and
the skill `dror-internal-project-facts` is invoked only on a miss.

## The defect

The stamp check is a checksum comparison, and it was being done by the model: a
7.8 KB skill file loaded into every chain run, then three to five tool turns —
read the store, run `cksum`, compare, decide — each of which resent the whole
context. The decision was deterministic and the model added nothing to it but
cost and the occasional misreading of a number.

## Considered options

**Keeping step 1 in prose and asking for fewer turns** was rejected: a
comparison the model performs is a model turn however it is phrased.

**A hook** was rejected because a hook cannot put text into a skill's rendered
content; the `!` injection can, and runs in the same place a hook would.

**Injecting `facts.md` unconditionally** was rejected: it skips the stamp, so a
stale store would be trusted until somebody noticed.

## Consequences

**The injected command must be allowed without asking**, or the invocation
aborts. Each skill declares it in `allowed-tools`, and the user's settings carry
the same rule with a wildcard over the skill directory; a fresh install adds
that one line.

**The script always exits 0.** A non-zero exit aborts the skill, and a miss is
not an error.

**The script runs where the session shell stands**, not where the skill will
work. In a drain that is the user's checkout, and the drain's §1 says why that
is the same store.

**Re-invoking a skill after the store changed re-injects it whole.** Rendered
content that differs from the copy in context is appended again; a gather
mid-run therefore costs one extra copy of the next skill invoked. It is rare and
it is the cost of the store being right.

**The check list lives in the script.** The skill's prose describes it and says
so; a change to the list is a change to `facts.sh`.
