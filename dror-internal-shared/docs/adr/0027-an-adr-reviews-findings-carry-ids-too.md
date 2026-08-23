# An ADR review's findings carry ids too

`dror-adr-review` appends to the same `refutations.tsv` as `dror-review`, on
purpose (ADR 0009) — the `lens` column keeps the two pools apart and nothing else
has to. It wrote nine columns where the code review writes ten: its findings
carried no **finding id**, and its rows landed with the `id` field absent.

That put every ADR finding beyond the question the logs exist to answer. A
`breach` goes to `dror-repair`, which writes a `repairs.tsv` row only for a
finding that carried an id (ADR 0022), so nothing could say what became of one. A
`text` or `hole` went to `dror-adr-repair`, which recorded no outcome at all.
Both pools shared a schema while only one of them was joinable.

So `dror-adr-review` mints a **run tag** and writes it and the report's minute
into the front matter, gives every merged finding an id by the shelf's rule
(`REPORT-STORE.md`), and writes the tenth column. `dror-adr-repair` appends its
own `repairs.tsv` rows, keyed by that id, with `production` always `no` — it
writes prose and nothing else, and the column stays so the two pools keep one
schema.

**The denominator comes with it.** A pool that shares a schema while missing a
joining column is beyond the questions the logs answer, and a missing
`runs.tsv` line is that same defect one column over: a lens that ran and found
nothing writes no finding, so without a run row an ADR lens chosen twice and one
chosen thirty times are indistinguishable. `dror-adr-review` therefore writes its
run line too, with `concurrent` as **`unchecked`** — it runs no check of its own,
and `-` already means *a check ran and saw nobody* in `dror-review`'s rows. One
value for both would put "looked and found none" and "never looked" under one
column, which is the confound ADR 0024 added the column to remove. A caller that
does check passes what it saw, and that is written instead.

## Considered options

**Dropping the `id` column for ADR rows and reading them as a shorter shape** was
rejected: the shapes are told apart by field count (ADR 0025), and a pool that is
permanently short would make every reader guess whether a missing id meant an old
row or an ADR row.

**Letting `dror-adr-repair` key its rows on the ADR path and the quoted
sentence** was rejected for the reason the id exists at all: a sentence is edited
by the repair, so the key would name text that no longer exists by the time
anyone reads it.

**A separate log for ADR reviews** was rejected as ADR 0009's question again —
the file answers what the *lenses* get wrong, and splitting it by which lens pool
raised a finding is the split the `lens` column already makes, at the cost of two
files for `dror-review-retrospective` to pool.

## Consequences

Rows already in `refutations.tsv` from ADR reviews have no id and are left as
they stand, on ADR 0022's terms.

`dror-adr-review` now mints a tag, which it did not before, and accepts one from
a caller — which is what lets `dror-adr-review-repair` keep one tag across all of
its rounds, exactly as `dror-review-repair` does.

`runs.tsv` now holds rows from two kinds of review. They stay readable apart
because the two lens vocabularies are **disjoint** — no name appears in both
`LENSES.md` files — which is the same property that already let one
`refutations.tsv` hold both pools. Keeping them disjoint is therefore a
constraint on adding a lens to either file, not a coincidence to rely on.

The retrospective's recall question joins `repairs.tsv` against `refutations.tsv`
per head, so a document repair's rows are separable there by the same `lens`
column; nothing needs a column saying which kind of repair wrote a row.
