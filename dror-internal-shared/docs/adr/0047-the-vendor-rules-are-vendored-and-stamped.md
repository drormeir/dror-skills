# The vendor's rules are vendored and stamped

`dror-skill-review` judged a skill against this repo's conventions and against
nothing else. Anthropic publishes its own rules for how a skill is written —
naming, the shape of a description, progressive disclosure, what makes an
instruction executable — and a skill can satisfy every convention here and
still break one of those. That is a worse failure, because the harness, not the
repo, is what enforces it.

**Superseded in part by ADR 0049**, which withdrew the lens in favour of a
script. Everything below about the local baseline and its stamp still holds;
only the `vendor` lens is gone.

So the review gains a sixth axis, the `vendor` lens, and it reads a **local
distillation**: `ANTHROPIC-SKILL-RULES.md` on the shelf, holding the published
rules reduced to what is checkable by reading a skill's own text, and closing
with the places this repo diverges on purpose so a lens does not raise a house
convention as a breach.

The distillation is stamped with the `ETag` of the upload it was read off. The
source PDF states no version and no publication date, so its `ETag` is the only
identity it has; the docs page covering the same ground serves `no-store` with
no `ETag` at all, which is why the PDF is the anchor. `anthropic-stamp.sh` makes
one `HEAD` request before the skill text is assembled and prints one `VENDOR:`
line — `current`, `moved` or `unknown`.

**All three verdicts run the review.** A `moved` or `unknown` line is carried
verbatim into the report's front matter and repeated on screen as a note that
the baseline wants re-distilling. Blocking was rejected: these rules are the
stable half of what a review checks, a re-upload is likelier to be a typo fix
than a reversal, and a review that refuses to start over a vendor's PDF is a
review nobody runs.

## Considered options

**Fetching the guide inside the lens on every run** was rejected. It makes the
baseline a moving target: two reviews of one skill days apart could disagree
with no change to the skill, the `vendor` findings would not be reproducible,
and every run would pay a download and a re-reading of thirty pages on the cheap
model. The lens is explicitly forbidden the web for this reason.

**Refreshing the local copy automatically when the stamp moves** was rejected:
the rewrite would happen mid-review, so a run could quietly change the rules it
was judging by, and the divergence section — the part that is this repo's
judgement, not Anthropic's text — would be lost on every refresh.

**Storing an age in days and calling the copy stale past it** was rejected as a
guess. The `ETag` answers the question exactly, for one cheap request, and needs
no tunable.

**Blocking the run on a moved stamp** was rejected, above.

## Consequences

Re-distilling is a human decision, taken when a run reports `moved`. Nothing in
the chain does it automatically, and the report says plainly which upload its
`vendor` findings rest on. ADR 0048 gives that decision a procedure —
`dror-skill-vendor-rules`, whose scheduled half only checks and whose refreshing half
is invoked by hand.

A machine with no network still reviews. `unknown` is treated exactly as
`moved`: the review runs and says the baseline could not be checked.

The stamp values live in `ANTHROPIC-SKILL-RULES.md` and the comparison lives in
`anthropic-stamp.sh`; neither restates the other's half.
