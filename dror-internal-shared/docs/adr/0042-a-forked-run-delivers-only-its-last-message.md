# A forked run delivers only its last message

A skill carrying `context: fork` reaches the user with its **final message and
nothing before it**. Every intermediate line it prints, and every tool call it
makes, is written where only that run's own context can read it. So a long
forked run is silent from the moment it is invoked until the moment it returns,
and `dror-implement-adr` reports its per-ticket progress by `notify-send` and a
progress log rather than by printing.

## How this was found

`dror-implement-adr` §3 step 1 requires a one-line counter before each ticket,
with an instruction to "emit it as your own text, not inside a tool call, or it
is written where only you can read it". The user reported never having seen one
across drains lasting more than a day.

Four probe skills settled it. A forked skill printing four marked lines around
two twenty-second waits delivered only the fourth and its return value; the
first three, and the `sleep` calls between them, never appeared. An otherwise
identical skill **without** `context: fork` delivered everything live — each
line as it was printed, each tool call as it ran. A forked skill invoked from
the unforked one behaved like the forked case: its own lines never appeared,
while its return value reached its caller intact.

The instruction was therefore not fragile, it was unachievable, and it had been
unachievable since ADR 0036 forked these skills.

## What still reaches the user

**The closing summary.** `§Present` is the run's last message, so every
skill's final report arrives exactly as its file describes.

**A stop.** `§3a` ends the run, so its question is the last message and reaches
the user. This is why a drain that needs an answer has always worked, while a
drain that is merely making progress has always looked hung.

**A returned value, to the caller.** The chain's whole delegation model rests on
this and it is unaffected.

## What does not

Anything printed mid-run. Which is: every progress counter, every "say so on
screen" that is not in the closing summary, and every tool call a reader might
have used to see where a run had got to.

## The decision

Keep the fork. ADR 0036's measurement stands — a drain is hundreds of turns, and
unforked it resends the whole prior session on each one — and the two things a
user most needs, the stop and the summary, arrive anyway.

Report progress through a channel the fork does not gate. `notify-send` is a
tool call whose *effect* lands on the desktop rather than in the transcript, so
it crosses the boundary that text cannot. The progress log beside the state file
is the written record for anyone who wants to `tail -f` it.

## Considered options

**Unforking `dror-implement-adr`** was rejected. It buys live progress and costs
the whole of ADR 0036 for the longest-running skill in the set — the one where
the inherited context is resent most often. It would also depend on the user
remembering `/clear`, which ADR 0036 already weighed and turned down, and it
fails silently: an expensive drain, not an error.

**A notification per sub-skill step** was rejected as noise. Hours of
notifications every few minutes is how a user learns to dismiss them unread. The
ticket boundary is the granularity that was asked for.

**Printing anyway, and treating the loss as harmless**, was rejected because it
is what the file said for as long as the problem existed. An instruction whose
effect nobody can observe is indistinguishable from one nobody follows, and this
one went unnoticed through every drain on record.

## Consequences

**"On screen" is now a claim about the closing summary only**, in every forked
skill. A file that says a step reports something on screen mid-run is describing
something that does not happen; where the reporting matters, it needs a channel
of its own.

**The notification is best-effort.** `notify-send` is absent on a headless box
and on macOS. Its failure is ignored, never reported, and never a gate — a
cosmetic channel must not stop a drain.

**Reporting belongs to whoever the user invoked**, which is the rule that keeps
this from multiplying. `dror-implement-ticket` stays quiet under a caller and
run directly, and the drain reports because the drain is what was typed.
`dror-code-review-repair` is the one skill that is both — a chain step and a command
people run by hand — so it notifies per round by default and is silenced by a
caller's declaration, trusted the same way its "a prove follows" declaration
already is. A skill cannot see who invoked it, so this can only ever be the
caller's word.
