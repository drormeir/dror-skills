# The ADR worktree lives inside the project, behind three guards

An ADR's work happens in a `git worktree` at
`<repo>/.claude/adr-wip/<repo>-adr-<N>`, on a branch named `adr-<N>`, and the
rules for both live in `WORKTREE.md` on the shelf rather than in
`dror-implement-adr`.

This reverses the placement that skill carried until now. It said "beside the
repository, never inside it", and gave the reason: a worktree under the checkout
is walked by the parent's own tools, and "whether the repo in hand is configured
that way is not worth finding out". That reasoning was sound and its conclusion
was wrong in practice. Worktrees beside the repo accumulate in the parent
directory, one per ADR, under names nobody remembers — the tree this decision was
written in had `geo_sense-adr-14` and `geo_sense-adr13-wip` sitting next to
`geo_sense`, and the second was on a branch that was never pushed, had no
virtualenv at all, and had drifted for days without anyone noticing. Being beside
the project is what made it invisible.

Inside, three things get better. The work is where the project is, so one
directory holds everything about a repo. Tools that search *upward* from the
working directory reach the parent's files, which is how a shared virtualenv
resolves without being named anywhere. And `.claude/` is already the agent's
corner of the repo, already gitignored in every project these skills run in.

The cost the old rule named is real, so it is paid explicitly rather than
avoided: three guards, checked before the worktree is created, each of which
**stops the run** when it does not hold.

`.claude/` gitignored, or the parent's `git status` reports the whole worktree as
untracked and every ticket refuses on a dirty tree. Pytest's `norecursedirs`
naming it — and this is the one that surprises: setting `norecursedirs` at all
*replaces* pytest's default, which skipped dot-directories, so a project that
lists `build dist` has no dot-directory guard left and will collect the
worktree's entire suite a second time. Mypy's own `exclude` covering it, since
mypy never reads `.gitignore`.

Repo-wide search is the one cost with no guard: `rg` and `git grep` honour
`.gitignore`, `grep -r` does not.

## Considered options

**Staying beside the repository** was the status quo and needs no configuration
at all. Rejected for what it produced: worktrees nobody could see, on branches
nobody had pushed, discovered by accident.

**A single sibling directory grouping them** — `~/projects/<repo>.worktrees/` —
keeps the parent tidy and needs no guards. Rejected because it inherits nothing:
no upward search reaches the project's virtualenv or its settings, so every
worktree needs its own copy of what the project already has.

**A cache directory far from the project** was rejected for the same reason as
the sibling, more strongly: it is the hardest of the three to find by accident,
which is the failure this ADR is a response to.

**Guards checked but not enforced** — warn and continue — was rejected because
all three failures are silent and late. A doubled test suite is discovered
halfway through the first ticket and blamed on the ticket.

## Consequences

The branch name is a convention now rather than a per-run choice: `adr-<N>`, the
number unpadded, local and remote alike. Three things join on it — the drain's
state file records the branch and a resumed run compares them, `dror-review`
derives every ticket's base from the branch's upstream, and a person finds the
work by guessing the name months later.

A worktree in the old place is **adopted where it stands** and never moved
mid-drain: moving one means `git worktree move` plus a state file whose recorded
path is now wrong. The same holds for a branch under an older name — adopt it,
say on screen that it is not `adr-<N>`, and never create `adr-<N>` beside it,
which would put one ADR's work on two branches with the wrong review base on
each.

Extracting the rules to the shelf is ADR 0026's arrangement applied a third time,
and it took §0 of `dror-implement-adr` from 130 lines to 14.
