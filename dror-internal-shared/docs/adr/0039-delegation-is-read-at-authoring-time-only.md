# DELEGATION.md is read at authoring time only

`dror-internal-shared/DELEGATION.md` is read whole by whoever writes or edits a
step that invokes another skill, and by no running skill. The eight callers
that said "read it whole before invoking" now say what the document owns and
that it owns it at authoring time; each step's named next action is unchanged.

## The defect

Every chain skill, and every fork of one, spent five kilobytes of context
reading a document whose own argument is that reading does not help. ADR 0034
found that a counter-instruction left as prose fails at the moment it is
needed, and that the fix is a named next action written into the step. Once that
action is in the step, the run holds the fix; reading the reasons for it mid-run
is the reading rule the document rejects, at the document's own cost.

## Considered options

**Keeping the run-time read for the loops only**, where the trap is worst, was
rejected: the loops' steps already name every branch of their next action, and
they are the files that are forked most often.

**Shortening DELEGATION.md** was rejected: the length is the argument, and the
argument is for authors.

## Consequences

**The rule in `CLAUDE.md` is unchanged** — a delegating step ends on a named
next action — and the document that explains it is now purely the authoring
reference it was written as.

**A step that still reads it at run time is a defect**, greppable by the phrase
"read it whole before invoking".
