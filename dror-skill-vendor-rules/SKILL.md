---
name: dror-skill-vendor-rules
description: Check whether the published guide behind the skill reviews' vendor baseline has been re-uploaded since that baseline was distilled, and re-distil it on request. Called bare it reports and then offers the refresh; called with check it only reports; called with refresh it rewrites the baseline and its stamp and reconciles the check script beside it, unstaged, and never commits. Use when a weekly check fires, when a skill review said the baseline moved or could not be checked, or when the user asks whether Anthropic's rules for writing skills have changed.
context: fork
background: false
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/anthropic-stamp.sh), Bash(bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/skill-rules-check.sh:*)
---

# dror-skill-vendor-rules

This skill keeps **one file** honest:
`../dror-internal-shared/ANTHROPIC-SKILL-RULES.md`, the vendor baseline that
`dror-skill-review`'s mechanical pass enforces, through the
`skill-rules-check.sh` script beside it (ADR 0049). That file owns the rules,
the source URL and the stamp; the script owns their numerals. Nothing here is
restated from either.

**A refresh that changes a rule may leave the script behind.** The prose and the
enforcement are two files, so step 5 below checks them against each other.

It has **three modes**, and the argument picks one.

- **no argument** — do check mode, and then, where the stamp did not read
  `current`, put the refresh to the user as a question and do refresh mode only
  on their explicit yes. This is the mode a person gets.
- **`check`** — check mode and nothing else. It asks nothing and edits nothing
  whatever the stamp said. **This is what a schedule runs**, and passing the
  word is what makes the schedule safe: a question nobody is there to answer is
  a question this run would end up answering itself.
- **`refresh`** — refresh mode directly, whatever the stamp said and without
  asking.

**The split is the whole point** (ADR 0047, ADR 0048). Distilling is a
judgement: which published rules can be checked by reading a skill's text, and
which of this repo's conventions diverge on purpose. A run that rewrote the
baseline unattended would change the rules every later review judges by, with
nobody having read the diff. Every path to refresh mode therefore passes
through a person: the word in the argument, or the answer to the question.

**This run has a context of its own.** The frontmatter forks it (ADR 0036):
what reaches it is this file, the stamp line below and the mode it was invoked
with — never the conversation that invoked it. There are no project facts here:
this run needs none of the five. Check mode touches the shelf and nothing else.
Refresh mode's step 5 also reads this repo's own skill directories, and what it
needs from them the script prints.

This skill is **repo-agnostic** (ADR 0011), and the extreme case of it: its
subject is the shelf file it maintains rather than any project, so it names no
tracker, no path and no runner of a repo it is pointed at, and takes no facts.

## The stamp

!`bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/anthropic-stamp.sh`

`anthropic-stamp.sh` printed that line before this text reached you, from the
URL and the `ETag` the baseline file carries. It reads `VENDOR: current`,
`VENDOR: moved` or `VENDOR: unknown`. What each of the three words means is
owned by `dror-skill-review/SKILL.md` §Whether Anthropic's rules are still the
ones on file, and is not restated here.

## Check mode

Say which of the three the line was, in one sentence each way:

- `current` — say the `last-modified` date the line carried, so a reader knows
  how old the match is. Nothing else is owed.
- `moved` — say both `ETag`s and the new `last-modified`, and say in one line
  that a `refresh` run is what acts on it.
- `unknown` — say the reason the line gave, in the words it uses, and that
  nothing is known either way.

**Check mode edits no file**, and that includes the baseline's own stamp: a
stamp rewritten without the rules under it being re-read would claim a
distillation that never happened.

Then stop — **unless this run was invoked with no argument and the line was
`moved` or `unknown`**. In that one case, ask the user whether to refresh now,
in plain words: that the guide behind the rules was re-uploaded (or could not
be reached), that refreshing re-reads it and rewrites the baseline, and that
the change would be left unstaged for them to read. Wait for the answer.

A yes runs refresh mode below, in this same run. Anything else stops here and
says the baseline was left alone. **Do not answer this question yourself** —
a run that talks itself into a yes is the unattended rewrite the design exists
to prevent.

Done when the verdict is on screen, no file has changed, and either the
question has been put or there was no reason to put one.

## Refresh mode

Reached two ways: the `refresh` argument, or a yes to the question above. The
run is identical either way.

Run it whatever the stamp said. `current` is a legitimate reason to refresh —
the distillation may have missed a rule the guide always carried.

1. **Fetch the source.** Take the URL from the baseline file. `curl` it into
   the scratchpad; do not read it through a fetch tool's summariser, which
   compresses a thirty-page document into a paragraph and loses every rule this
   skill exists to carry. Where the fetch does not come back with the deck — no
   network, no `curl`, or a body that is not the document — **stop here**:
   change no file, restamp nothing, and say which of those it was, in the words
   the `unknown` line uses. The baseline is left alone, for the reason check
   mode's no-edit rule gives above.
2. **Read it whole**, from the scratchpad copy, in page ranges. It is a slide
   deck: the rules sit in short bulleted panels, and a range that skips pages
   skips rules.
3. **Distil.** Keep only what a **script can decide by reading a skill's
   directory** — the folder, the frontmatter, the file names. That is a
   narrower test than "checkable by reading the text", and deliberately so: the
   guide's advice about writing well is `dror-skill-review`'s `execution` and
   `sequence` lenses' business, and a copy of it here would raise every defect
   twice (ADR 0049). Everything about uploading, distributing, pricing or
   running a skill is out of scope as well. The existing baseline's section
   order is the shape to follow.
4. **Carry the divergence section forward.** Its closing section — where this
   repo departs from the guide on purpose — is **this repo's judgement, not the
   vendor's**, and re-reading the guide cannot produce it. Preserve every entry
   unless the guide itself has changed under one, and say on screen which
   entries you kept, changed or added.
5. **Reconcile the script.** Read
   `../dror-internal-shared/skill-rules-check.sh` against the rules you just
   wrote: a rule added needs a check, a rule dropped needs its check removed, a
   bound that moved needs its numeral changed **there and not in the prose**.
   Then run it over this repo's own skills —
   `for d in <repo>/*/; do bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/skill-rules-check.sh "$d"; done` —
   and read every `BREACH:` line before believing it: the first draft of that
   script produced three false positives, and a check that fires on correct
   skills is worse than no check. A line that survives that reading is one of
   two things. Where the **check** is wrong, its test or its numeral is what
   changes, here in step 5. Where the **skill** is wrong, this run leaves it
   alone: say the directory and the rule on screen and go on. A skill directory
   is `dror-skill-review`'s to raise and `dror-skill-repair`'s to fix, and this
   run's edit set closes below at the two shelf files.
6. **Restamp.** Write the `ETag` and `last-modified` the fetch returned, and
   today's date as the distillation date. The values go in the baseline file and
   nowhere else.
7. **Verify.** Run
   `bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/anthropic-stamp.sh` and
   check it now prints `VENDOR: current`. A `moved` line here means the stamp was written wrong, or
   the source moved again mid-run; say which and fix it before going on. An
   `unknown` line means the comparison could not be made at all: say the reason
   it gave, and leave both files as they stand for the user to read.

**The editing ends here, with the diff unstaged and uncommitted.** The user
reads it, under `## Present` below, which is where this run ends. That is the
whole reason this mode is manual, and a run that commits — or that halts before
putting the changes on screen — has removed the only review the design relies
on.

## Present

Say the mode, the verdict line verbatim, and — in `refresh` — what changed in
the baseline: which rules gained, lost or reworded a bullet, what became of each
divergence entry, and what changed in `skill-rules-check.sh` beside it. Name
both files, and say they are unstaged.

Then say in one line whether any skill wants re-reviewing: a rule that changed
is a rule no existing skill was ever checked against, and `dror-skill-review`
is what checks one. It binds nobody.

Then stop and wait.

Done when the source has been read whole, the baseline holds the distilled
rules with its divergence section intact, `skill-rules-check.sh` enforces
exactly those rules and every `BREACH:` line it printed over this repo's own
skills has been read and either fixed in the script or named on screen, the
stamp matches the fetch, `anthropic-stamp.sh` prints `current`, the changes are on
screen, and nothing is staged or committed.
