# Checking the baseline is scheduled, distilling it is not

ADR 0047 vendored Anthropic's published rules as a stamped local baseline and
left re-distilling to a human, naming no procedure for it. That is a gap: a run
that reports `moved` tells the user something is owed and nothing says how to
pay it, so the baseline rots exactly as fast as the guide moves.

`dror-skill-vendor-rules` owns that procedure, in **three modes**. `check`
compares the stamp and reports. `refresh` fetches the guide, re-reads it whole,
rewrites the baseline and restamps it, then stops with the diff unstaged. Called
**bare** it does `check` and then, where the stamp did not read `current`, puts
the refresh to the user as a question and does `refresh` only on their yes.

**Only `check` may be scheduled**, and the schedule passes the word explicitly.
Distilling is a judgement — which published rules are visible in a skill's own
text, and which of this repo's conventions diverge on purpose — and the
divergence section is this repo's reasoning, which re-reading the guide cannot
reproduce. An unattended rewrite would change the rules every later review
judges by with nobody having read the diff, which is the objection ADR 0047
already made to refreshing mid-review.

**The bare mode is why `check` exists as a separate word.** A person who runs
the skill by hand wants the offer, not a second command to remember. A cron run
must never be offered anything: there is nobody to answer, and a run holding an
unanswerable question is a run that answers it itself. Naming the mode is what
separates the two, so the safe path is the one the schedule spells out rather
than the one it inherits by default.

The skill stays model-invocable, against the test ADR 0018 sets: nothing invokes
it, so the flag would fit. But a scheduled prompt reaches a skill only through
the model's own list, and `disable-model-invocation` empties that list of it —
the flag would make the schedule impossible. Reachability wins over the
description's context cost.

`dror-skill-review` keeps its own stamp check. The schedule warns early; the
review's check is what puts the receipt in the report, and a report that named
no baseline could not be read months later.

## Considered options

**A single mode that refreshes whenever the stamp moved** was rejected as the
unattended rewrite above.

**Refreshing into a scratch copy for the user to diff later** was rejected: the
copy is another thing to keep, and an unstaged working-tree diff is already
exactly that, in the place the user reads diffs.

**Dropping the review's per-run stamp check once a schedule existed** was
rejected. The schedule fires only while a session is idle and can lapse
silently; a review that assumed it had run would report a baseline it never
checked.

## Consequences

A weekly `check` is a cheap `HEAD` request and a sentence. It changes no file,
so a missed week costs nothing but lateness.

Re-distilling remains a decision with a diff attached. The guide has moved once
on record, so the manual half is expected to run rarely.

The harness scheduler expires a recurring job after seven days and fires only
into an idle session, so a genuinely weekly cadence is the operating system's
`cron` running the skill headless, not `CronCreate`.
