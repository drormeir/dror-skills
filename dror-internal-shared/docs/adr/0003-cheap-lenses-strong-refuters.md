# Lenses run on the cheap model, refuters on the strong one

`dror-code-review` passes `model: "sonnet"` to every lens agent and leaves the
refuters on the session's own model. The two halves of a review are not alike
work: a lens reads widely and *proposes*, and a weak proposal costs one refuter;
a refuter *decides*, and a wrong decision either ships a false positive or buries
a real bug.

Bulk reading is most of a run's cost, and it is the half that tolerates the
cheaper model.

## Consequences

The cost of a review is controlled before the refute step, not inside it: fewer
lenses (five at most), a tighter read boundary, and lenses that kill their own
weak findings. Every merged finding faces a refuter, with no cap — cutting that
list would put unchecked suspicions in the report, and a reader cannot tell an
unchecked finding from a confirmed one.
