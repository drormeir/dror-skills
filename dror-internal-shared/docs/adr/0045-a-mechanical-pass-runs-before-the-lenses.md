# A mechanical pass runs before the lenses

`facts.md` already carries the lint and type-check commands the repo itself
trusts, and `dror-code-review` never ran them: lenses on the cheap model hunted for
defects a tool finds deterministically, each such finding then cost a refuter,
and the refuter's verdict was a model's judgement about something a tool had
already proved.

So the review runs those two commands over the changed files before any lens is
launched. A diagnostic on a line the diff added or changed is a finding that
**skips the refuter** — the tool's pasted output is its own proof (ADR 0006) —
and a diagnostic elsewhere in a changed file predates the diff and is named in
one line, not raised. The surviving diagnostics go to every lens as a file, with
the instruction not to re-report what it holds.

In the report and in `refutations.tsv` these findings carry the reserved lens
name **`tool`** — the second reserved name beside `criterion`, added to the
closed set ADR 0014 defines. Their verdict is `survived` by construction, so
`dror-review-retrospective` counts them out of every precision rate; a refuted
`tool` row is a defective row. The pass is not a lens and appears in neither
`lenses_run` nor `lenses_dropped`.

## Considered options

Handing the diagnostics to the lenses as input only, letting them raise the
findings, was rejected: each lens would paraphrase the tool's words, the
paraphrases would merge imperfectly, and every one would cost a refuter to
confirm what the tool had already settled.

Running the tools inside each lens agent was rejected as the same work done
once per lens instead of once per run.

Running the project's test suite here was rejected: the suite is the repair's
evidence, a review changes no behaviour, and several sessions sharing a
checkout would thrash the machine the way the refuting rules already warn
against.

## Consequences

A whole class of findings — type errors, undefined names, the patterns the
repo's own lint config bans — reaches the report at zero refuter cost and with
zero false-positive risk, and the lenses stop spending their read budget
rediscovering them.

A repo whose verification commands came back unstated skips the pass and the
report says so, the same wording an unstated issue convention already gets.
