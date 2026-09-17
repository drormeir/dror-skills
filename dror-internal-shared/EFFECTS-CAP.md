# The effects lens's cap, and how it is tuned

`dror-adr-review`'s `effects` lens looks for side effects of a decision that its
author would reconsider. Its width is unknown up front. Too narrow, and it
reports what was already obvious. Too wide, and it reports conspiracies. So the
width is one number, and the logs move it by a fixed step. This file is that
number's one copy: where it is stored, what is counted, and the rule. Read it
whole before reading the cap, writing a row, or suggesting a change.

## The cap

The lens reports **at most N findings** per ADR, ranked by what would change for
a user, a saved file or another feature. It says how many more it had and
dropped.

N is the `value` of the **last `cap` row** in
`~/.claude/dror-skills/effects.tsv`. With no such row, or no file, N is **5**.
Nothing else stores N, and nobody edits a lens text to change it.

## The log

`~/.claude/dror-skills/effects.tsv` — its columns are `REPORT-STORE.md`'s, under
"The logs". One row per event:

- `reconsidered` — the user answered a finding by changing the decision.
  Written by `dror-interview`.
- `accepted` — the user kept the decision and accepted the effect in writing.
  Written by `dror-interview`.
- `dismissed` — the user said the effect is not a real concern. Written by
  `dror-interview`.
- `missed` — a drain parked or stopped a ticket on a side effect of the ADR that
  no `effects` finding named. Written by `dror-implement-adr`.
- `cap` — N changed. Its `value` is the new N. Appended only on the user's yes.

An unanswered question writes no row.

## The window

Count only rows **after the last `cap` row**, in file order. With no `cap` row,
count the whole file.

**ADRs reviewed** is the number of distinct `(repo, subject)` pairs in
`~/.claude/dror-skills/runs.tsv` whose `lenses_run` names `effects`, dated on or
after the last `cap` row's date. With no `cap` row, count every such pair.

## The rule

Suggest nothing until the window holds **at least 5 ADRs reviewed**. Then:

- **dismissed share** = `dismissed` ÷ (`dismissed` + `accepted` +
  `reconsidered`). With no answers at all, the share is 0.
- **missed** = the number of `missed` rows.

| dismissed share | missed | Suggestion |
|---|---|---|
| more than half | 0 | N−1 |
| half or less | 1 or more | N+1 |
| more than half | 1 or more | keep N; read the missed rows by hand |
| half or less | 0 | keep N |

N never goes below **2** or above **10**. A suggestion that would cross a bound
is `keep N`.

## Suggesting it

The suggestion is one line, and only where it is not `keep N` alone: the window's
counts, the suggestion, and the command that applies it, verbatim:

> `printf '%s\t%s\t-\t-\tcap\t%s\t%s\n' "$(date +%F)" "-" <new N> "<counts>" >> ~/.claude/dror-skills/effects.tsv`

The user runs it or says no. A `keep N` with missed rows names those rows'
notes instead, since the answer is theirs to read. Applying a change starts a
new window, so the next suggestion waits for five more ADRs.
