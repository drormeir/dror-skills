# Refuting

You are handed one finding. **Your job is to kill it.** Default to refuted: the finding dies unless the code
at its `file:line` is genuinely defective. You read the repo and may run code;
you change no behaviour.

Refuted means **the code is fine**, not that the sentence was clumsy. A finding
whose scenario is misstated but whose code is genuinely broken comes back
a survivor, with the scenario rewritten.

## Prefer a run to a reading

The strongest verdict either way is an execution, not an argument (ADR 0046).
Where the failure scenario can be staged — a snippet calling the code with the
scenario's own input, a narrow test invocation, the interpreter one-lining it —
stage it and let the output decide: the defect appearing confirms, its absence
under the scenario's own conditions refutes, and the pasted output is the
evidence either way. Stage it **in a copy outside the repo** — the scratchpad —
never in the working tree: refuters run in parallel, and a review changes no
line of code. Reading alone settles only what no run can reach — real GUI or
thread timing, a scenario needing state no copy can hold — and the return says
which kind of verdict it was.

The budget rule from the missing-test section holds here too: the narrowest
invocation that could possibly show the defect, never a full suite.

## A missing-test finding is refuted differently

This section travels only with a `cover` finding — the hand-off in `SKILL.md`
sends it to no other kind, so a refuter reading it is holding one.

Its code is sound by definition — that is what it says — so "the code is fine"
refutes nothing, and the default rule applied here would kill every finding the
`tests` lens ever raises.

These two defaults are **not comparable**. A `cover` finding's survival rate and
a bug finding's survival rate measure different things, and a retrospective must
not read one against the other — the gap between them is this section, not a
lens's precision.

What refutes one is a test that **does** cover the behaviour: find it and name
it, wherever it lives. Failing that, revert the behaviour **in a copy of the
repo outside it** — the scratchpad — and run the tests there. Red refutes the
finding and names the test that went red; green confirms it.

The copy is not a nicety. Refuters run in parallel and several are editing at
once, so a revert made in the working tree is another refuter reading a file
mid-edit, and it breaks this skill's one promise: that a review changes no line
of code.

**Run the narrowest set that could possibly go red** — the tests of the module
the behaviour lives in, or the single file or `-k` selection covering it.
Several agents each starting a full suite at once thrashes the machine and each
then waits on the others' load. Where that narrow set is genuinely unknowable,
the finding survives as **unverified**, which is cheaper than the full suite N
times over.

## Leave the claim behind

A lens misreading the code is evidence the code did not carry something it
needed to carry. Where your refutation turned on an invariant invisible at the
site — the caller that already clamps, the unit converted one layer up, the
ordering the framework guarantees — write that invariant in as a **claim**: one
comment giving the constraint and the reason, phrased so a later lens can test
it against the code and find it stale.

Neutral, short, for a human eye first. Never a verdict on the finding — a
verdict is the one thing nobody can check.

Gate this hard: the test is whether a careful human reading only that code could
have reached the same wrong conclusion. **Most refutations write nothing.**

A claim goes where the information is missing, which is often *not* the
finding's `file:line` — the seam, when that is where the conversion happens and
you have just traced it. Read the file immediately before editing and insert
whole comment lines, leaving every line of code as it was.

## Return

The verdict — survived, refuted or unverified — one sentence of why, whether an
execution or a reading decided it, the corrected scenario where you rewrote
one, and the path and line of any claim comment you wrote. Where an execution
decided, also the **exact command that decided it**, phrased to run from the
live repo's root: your scratchpad copy is gone by the time a repair replays it,
so the copy's paths become the repo's own and a staged snippet is folded into
the command itself — a heredoc, a `-c` one-liner. A run only the copy could
phrase returns no command and says so. The report carries the command forward
as the finding's `repro:` line, verbatim, and a repair replays it (ADR 0046).
