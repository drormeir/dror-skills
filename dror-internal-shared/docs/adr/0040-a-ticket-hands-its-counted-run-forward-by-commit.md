# A ticket hands its counted run forward by commit

`dror-implement-ticket`'s summary names the full-suite run its close read as
the gate — the **counted run** — against the sha of the commit it made, and
`dror-implement-adr` reads that line as an eighth fact and hands it to the next
ticket as its baseline. Step 0 of a ticket run checks the handed sha against
`HEAD`, unchanged.

## The defect

`dror-implement-adr` §0 promised that "no ticket pays for a suite the chain has
already seen": the first ticket takes §0's baseline, and each later ticket the
previous ticket's counted run. Two things broke the promise, and each was enough
on its own.

The ticket's summary never returned the run. The fact list the drain reads —
seven facts, ADR 0035 — had the commit, the criteria, the loop's word, the tag,
the close and the stop, and no counted run; a drain that cannot re-derive a fact
it was never handed passed nothing, and step 0 ran the suite.

And had it been handed, step 0 would have refused it. The counted run is made
before step 6's commit, so the sha it "ran over" is the previous tip, while step
0 takes a handed run only where `HEAD` is that sha and the tree is clean — and
`HEAD` is now the new commit. The run *was* over the commit's tree — every edit
between the counted run and the commit owes a suite by step 3's own rule, so the
tree the suite saw is the tree the commit holds — but nothing said so, and the
sha check read the two as different trees.

The cost was one full suite per ticket, over a tree the chain had already run it
on, at the one moment a ticket run has nothing to fix.

## Considered options

**Dropping step 1's suite**, on the reading that step 2 always adds tests and
the post-loop rule then owes another run over nearly the same tree, was
rejected: step 1's run is the only one whose author still fixes what it finds —
`dror-code-repair` leaves a failure no fix touched as `pre-existing failure`, and
step 4's prove ends the run on a red. And the post-loop run fires only when no
repair round ran a suite, which is the rare case.

**A quick form of the suite for repair rounds**, declared as a project fact,
was rejected: a round's review reads the diff and not test results, so a
regression one round's fix caused in another call site of a shared helper would
surface only at the last full run, with no step left that repairs; and it
edits `dror-code-repair`'s own closing guarantee for a direct user, which DELEGATION.md
forbids for a caller's convenience.

**Collapsing the end-of-ticket runs into one** was rejected on value: each
already fires only on a tree change since the last counted run, and the merge
saves a run only where the loop repaired nothing and step 4 still touched the
tree.

**Relaxing step 0 to compare trees rather than shas** (`git rev-parse HEAD^{tree}`
against a stored tree id) was rejected: it is right, and it moves the check
into a form neither the ticket nor the drain writes anywhere today. Naming the
run against the commit says the same thing in the sha the drain already
records with the round.

## Consequences

**The chain's rule for the full suite is what makes the hand-off sound.** "Owed
to the last code change" is why the counted run and the commit share a tree;
a ticket run that made an edit after its counted run and committed without a
suite would hand a false baseline forward. That rule was already load-bearing
for the close and is now load-bearing for the next ticket too.

**A red counted run is handed as red, and the drain hands nothing on.** Step 0
then runs its own suite and stops on the red as pre-existing, which is the stop
§0 already describes for the first ticket; the cost is one suite on a tree that
is going to stop the drain anyway.

**A recovered ticket's suite is its counted run.** The drain's step 5 already
runs the full suite before committing a ticket that stopped early, and that run
is now named as the next ticket's baseline where it was green.
