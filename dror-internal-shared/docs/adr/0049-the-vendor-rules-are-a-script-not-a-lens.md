# The vendor's rules are a script, not a lens

ADR 0047 added a `vendor` lens to `dror-skill-review`, judging a skill against
Anthropic's published rules held in a local baseline. Reading that baseline back
against the tree showed two unlike halves in it.

One half is **mechanical**: a folder's case, the instruction file's exact
spelling, `name:` against the directory, a reserved word in the name, a
character bound on `description:`, an angle bracket in the frontmatter, a
`README.md` inside the folder. Every one is decided by a string comparison.

The other half is **advice about writing well**: be specific, put the critical
instruction first, state your error handling, do not assume you are the only
skill loaded. `execution` and `sequence` already judge all of it, with this
repo's own reasoning behind them.

So the lens is withdrawn and replaced. `skill-rules-check.sh` on the shelf takes
a skill directory and prints one `BREACH:` line per mechanical rule broken.
`dror-skill-review` runs it before the lenses and hands its output to every one
of them as a file, with the instruction not to re-report it. The breaches
**skip the refuter** — the script's output is its own proof (ADR 0006) — and
carry the reserved lens name `tool`, already minted by ADR 0045 for exactly this
shape. The advisory half is deleted rather than moved: it was a second copy of
what two lenses already do.

This is ADR 0045's argument, one level up. There, lint and type-check findings
stopped being guessed at by a cheap model and confirmed by an expensive one.
Here the same waste had been introduced deliberately, one week old, and is
removed the same way.

`ANTHROPIC-SKILL-RULES.md` keeps the URL, the `ETag` stamp and the rules in
prose; the script keeps their numerals, because the repo's tunable rule puts a
numeral only in the file that enforces it. `dror-skill-vendor-rules` is
unchanged: it still watches the guide and re-distils on a person's yes, and what
it maintains is now a shorter file feeding a script.

## The word ceiling is a recorded divergence

The guide advises a `SKILL.md` under five thousand words.
`dror-implement-adr` (10,544), `dror-implement-ticket` (6,152) and
`dror-code-review-repair` (5,543) are past it. It is advice, not a harness
limit, and each of the three is a long procedure rather than padding: splitting
a drain across companion files moves text a run opens anyway into a second read.
So the ceiling goes in the divergence section and the script does not test it.

## Considered options

**Keeping the lens and the script both** was rejected as the duplication the
change exists to remove: the same defect would arrive twice for the merge.

**Keeping the lens for the advisory half only** was rejected for the same
reason one level down — that half *is* `execution` and `sequence`, and a third
agent restating them adds cost and merge work, not coverage.

**Enforcing the word ceiling and shortening the three skills** was rejected. The
gain is compliance with advice; the cost is three procedures cut into pieces
that every run then reassembles.

## Consequences

A whole class of finding — the mechanical rules — now reaches the report at zero
refuter cost and zero false-positive risk, and the lens pool is back to five.

The check is one shell script, so it is runnable outside a review: over the
whole tree it takes a loop and a second, which is how the three false positives
in its first draft were found and fixed.

Anthropic's advice about writing well is no longer represented as such. It is
covered by `execution` and `sequence`, which were judged the better statements
of it, and a future guide that says something genuinely new will show up as a
`moved` stamp and a decision to make.
