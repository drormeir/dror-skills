# Settling a round still owed

Read whole, and only, when `SKILL.md` step 3's loop came back on the word
**owed**. On **optional** or **no** there is nothing here: the loop settled
itself, and step 4 goes straight on to step 6's count.

It owns what happens between the loop's word and the commit — whether a further
loop runs, what it is capped at, what the prove after it must tick, and what the
commit and the push are allowed to do while the word still stands. It does not
own the loop, which is `dror-review-repair`'s, nor the boxes, which are
`dror-prove`'s, nor the commit and push themselves, which stay in `SKILL.md` at
steps 6 and 7 and are read every run.

Why it is a separate file rather than a section: it is the one step of a ticket
run that most runs never take, and a ticket run is spawned once per ticket by
`dror-implement-adr`, so every line held here is a line that agent does not carry
on the tickets that converge. The same arrangement `dror-implement-adr` makes
with its own `RESUME.md`, for the same reason.

## What the word is for

Step 3's loop ends on one word — **owed**, **optional** or **no**. This file acts
on it, because the two steps after it are the commit and the push, and both are
irreversible in a way a round is not: work pushed unreviewed is work the next
ticket is written on top of.

**Read the grounds before spending on the word.** An **owed** whose ground is *a
criterion only the user can settle* is not something another round can move: two
more rounds over an unchanged diff find what the last ones found and hand back
the same sentence, having spent a lens agent per lens and a refuter per finding
to do it. Say so and go straight to step 6. The other grounds — the cap, a repair
that touched production code — are exactly what a further round is for.

## owed, on grounds a round can move

Settle it now, before the commit, by invoking `dror-review-repair` **capped at
two rounds**, telling it **this is a chain run, so it notifies nothing**. Not an
inline review-then-repair: that skill owns the round, judges
it, and carries the account of why the tree is dirty into every round, its run
tag, and the rule that the full suite is owed to the last code change.

**An owed-at-cap hand-back is a command, not a description.** Where step 3's loop
came back with the command that would resume it, run **that** rather than
composing a fresh invocation: it carries the report path, the tag and the round
count already reached, and a re-invented prompt starts a loop that thinks it is
on round one.

Then `dror-prove` for any box those repairs unticked — the loop deliberately
ticks nothing — and **one box on that list is not proved by a test**: the
criterion that *is* the project's verification gate is ticked on the full-suite
run that counted for this round, quoted to it, exactly as step 4 does. A prove
that touched the tree owes the suite before the commit, by step 3's rule.

Both of those are steps of the run, and each ends on a shape DELEGATION.md
names — the loop on **a hand-back command** where it is still owed, the prove on
**a deliverable's shape**. So each has its named next action: **immediately
after the loop returns, and in the same turn, invoke `dror-prove` for the boxes
it unticked, or where it unticked none, fetch the ticket body for step 6's
count; immediately after that prove returns, run the full suite where it touched
the tree, then fetch the ticket body for step 6's count.** The still-owed case
below changes what the commit says and whether the push runs, not whether the
commit is made.

## Still owed after that cap, and the word travels up unchanged

This step does not raise the cap or run a third loop: a ticket still owed after
them is not converging, and hiding that behind another round buries it. Report
the word, its grounds and the hand-back command the loop returned — a caller that
stops on this hands that command to the user, and cannot compose it afterwards.

Then commit at step 6, and **do not push**: that command is `/dror-review` over
the unpushed work, with no base of its own, so step 7's push is the one act that
would spend it — `@{upstream}` would be `HEAD`, and the review it names would
read an empty diff and call that convergence. The work is real whatever the
verdict and the commit is what keeps it findable; the push is the user's, after
the round the command runs, and step 8 leaves the ticket open on that condition.

## Report

Say which of the three cases fired — settled by a further loop, gone straight to
step 6 on grounds no round can move, or still owed after the cap — and carry the
word, its grounds and any hand-back command into `SKILL.md`'s §Present unchanged.
Then return to step 6.
