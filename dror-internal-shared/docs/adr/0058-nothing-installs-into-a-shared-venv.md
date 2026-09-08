# Nothing installs into a shared venv

A worktree symlinks the user's virtualenv rather than building its own, because
building one costs minutes and gigabytes on every drain. `WORKTREE.md` guarded
the shared venv with a prediction: **a drain whose work will change the
dependency file gets a venv of its own.**

## The defect

The prediction is asked while the worktree is built, at `dror-implement-adr`
§0 — before §2 fetches the ticket table, before §3 builds the work list, before
the ADR itself is read at §3's check. The run holds the ADR's number and nothing
else, so it cannot answer, and nothing later re-asks. In practice it always
takes the shared branch, whatever the work turns out to need.

The question is also the wrong one. The dependency file is a proxy for "will
something install", and the two come apart in both directions: a package is
routinely installed by hand, tried out, and only written into the dependency file
afterwards once the choice has proved out — so the install happens with no file
change at all — and a run that edits the file may install nothing. Neither
direction predicts the other. Answering the question correctly would not have
protected the venv.

## Considered options

**Moving the question later** — after the ticket table, or per ticket — was
rejected: it makes the prediction answerable but keeps it a prediction, and it
means changing a run's environment after that run has started working in it.

**Asking the user up front**, through `dror-interview`, was rejected as partial:
the interview is optional, so every drain started without one is back where it
began.

**Always building a private venv** was rejected on cost. Minutes and gigabytes
per drain, paid on every ADR, to cover a case that arises rarely.

**Leaving it and correcting only the false justification** was rejected: it
leaves an agent free to install into the user's environment, which is the hazard
the rule existed for.

## The decision

The symlink is the default and stays. An **editable install** is the one case
that still earns the worktree a venv of its own, for its own reason: imports
would otherwise resolve back to the user's checkout and test the wrong tree.

**Nothing under `WORKTREE.md` installs into a shared venv** — not to make a test
pass, not to satisfy an import, not as a step it judges harmless.

**A package the shared venv does not have parks the ticket** (ADR 0054), naming
the package, the ticket, and that the venv is shared. The rest of the list is
worked; the drain carries on.

It is a fifth question that parks, and it is **not** a fifth standing
permission. §0b's four are questions an answers file may settle in advance; this
one is not, and cannot be — a standing answer is a permission this drain holds,
and no permission overrides a prohibition on writing into the user's own
environment. That is why asking it up front was rejected above rather than
merely deferred. A drain that finds an answer bearing on the ticket — a library
this ADR chose, say — has not found one that settles this.

## Consequences

The unanswerable question is gone, and nothing replaced it: a prohibition at the
moment an install would happen needs no prediction about work not yet read.

**It matches how the environment is actually maintained.** The user installs by
hand, deliberately, and records the dependency once satisfied. Where they have
already done so the package is present and nothing fires; where they have not,
the question reaching them is the same question they would have answered anyway.

**It forbids something no skill does yet.** No file in this repo instructs an
install — the only `pip install` in the tree is a sentence describing how an
editable install resolves imports. The rule lands before a first offender, which
is the cheap moment for it.

The cost is a parked ticket where an agent would previously have installed
silently and carried on. That trade is the point.
