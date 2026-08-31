# The ADR worktree: names, placement, environment and re-entry

The shared rules for isolating one ADR's work in a `git worktree` — where it
goes, what it is called, what has to be true of the project before it may go
there, what is carried into it, and how a later run finds it again. They live
here, owned by the shelf and belonging to none of the callers: one copy, so
sharpening a rule sharpens every run that obeys it. Read this file whole before
creating or adopting a worktree; do not restate it in the calling skill.

What is **not** here is what the worktree is *for*. Which tickets are worked in
it, in what order, and what is written to the state file beside it belong to the
skill that drives the drain.

The isolation is `git worktree`: a second working directory backed by the same
`.git`. Nothing is cloned and the object store is shared, so the cost is a
checkout and not a copy of the history.

Why it sits inside the project, and what that costs, is ADR 0029.

## The names

The branch is **`adr-<N>`** and the worktree is
**`<repo>/.claude/adr-wip/adr-<N>`**, with `<N>` the ADR's number written
the way it is spoken — `adr-14`, not `adr-0014` and not `adr14-wip`, even though
the ADR's own file is `0014-*.md`. Local and remote carry the same name.

**This is a convention, not a choice made per run.** Three separate things join
on it: a drain's state file records the branch it was written under and a
resumed run compares them, `dror-code-review` derives every ticket's base from this
branch's upstream, and the user finds the work by guessing the name months
later. A branch named per-run breaks all three quietly.

## Creating one

From the user's checkout:

```
git fetch origin
git worktree add .claude/adr-wip/adr-<N> -b adr-<N> <the remote's default branch>
git -C .claude/adr-wip/adr-<N> push -u origin adr-<N>
```

Three things in those three lines look optional and are not.

**Off the remote's default branch, not `HEAD`.** The user's checkout may hold
uncommitted work and unpushed commits. Starting from the remote head is what
makes the branch's contents exactly this ADR's work. `origin/main` is the common
case and not a rule: resolve it the way the rest of the chain does —
`origin/HEAD`, then `origin/main`, then `origin/master` — since many clones never
ran `git remote set-head`, and a repo whose default is `master` would otherwise
fail at the first command.

**Inside `.claude/adr-wip/`, and only where the guards below hold.** Keeping the
work under the project is what makes it findable — one tree, one place, no
sibling directories to lose — and `.claude/` is already the agent's own corner of
the repo. It also means a tool that searches *upward* from the working directory
reaches the parent's files, which is how a shared virtualenv resolves without
being named. The cost is that a worktree under the checkout is walked by the
parent's own tools, and that cost is real rather than theoretical: see the
guards.

**Pushed, with upstream set.** `dror-code-review` derives its base from
`git merge-base @{upstream} HEAD` **where there is an upstream**, and falls back
to the remote's default branch where there is none — which for this branch would
be every ticket's work at once, so the `-u` is what picks the first of those two.
With the branch tracking `origin/adr-<N>` and every finished ticket pushed, each
ticket's review sees that ticket's work and nothing earlier. Tracking
`origin/main` instead would have ticket five reviewed together with tickets one
to four, and a repair would then fix their findings under ticket five's number.

## The three guards, checked before the worktree is created

In the user's checkout, not the worktree — the worktree does not exist yet.

1. **`.claude/` is gitignored.** `git check-ignore -v .claude` answers it.
   Ungitignored, the parent's `git status` reports the whole worktree as
   untracked, and a ticket run's own dirty-tree check refuses every ticket.
2. **pytest does not recurse into it.** Read `norecursedirs` in the project's
   pytest config. Pytest's *default* skips dot-directories, but a config that
   sets `norecursedirs` at all **replaces** that default rather than adding to
   it — so a project listing `build dist` and nothing else has no dot-directory
   guard left, and will collect the worktree's entire suite a second time. Where
   it is set and does not name `.claude`, that is the case.
3. **mypy does not read it.** mypy never consults `.gitignore`, so only its own
   `exclude` keeps it out. A repo-wide `mypy .` otherwise type-checks both copies
   and reports every finding twice.

**A guard that does not hold stops the run**, naming which one and the single
line that fixes it — `norecursedirs = … .claude`, an `^\.claude/` alternative in
mypy's `exclude`, `.claude` in `.gitignore`. Do not create the worktree, and do
not silently fall back beside the repo: a suite that doubles, or a type check
that reports everything twice, is discovered halfway through the first ticket and
blamed on the ticket. Editing the project's own config is the user's call, and
one sentence naming the line is what lets them make it.

Repo-wide search is the one cost with no guard: `rg` and `git grep` honour
`.gitignore` and are fine, `grep -r` is not.

**A test that walks the tree itself has no guard either**, and it is the same
cost wearing a green tick: the three above configure *tools*, and a test's own
`rglob` is not one of them. It finds the worktree's copy of every file it
matches, and it fails only when the suite is run from the user's checkout — which
is not where a drain ever runs it. `WRITING-TESTS.md`'s rule for such a walk is
what keeps that out, and it belongs to whoever writes the test, not to this
checklist.

## Carrying the ignored things across

A worktree contains tracked files only, and everything a run needs to verify with
is ignored: the virtualenv, the agent settings and hooks, the local data
directory. Symlink them one by one from the user's checkout — the venv, the
settings file, any hook scripts it names, the data directory.

**Do not symlink the whole agent directory.** Its `dror-skills/` store holds
`facts.md` and the reports, and sharing those is sharing exactly what the
isolation was for.

**Check the venv for an editable install before trusting its symlink.** A project
installed with `pip install -e` resolves imports through the venv back to the
checkout it was installed from — the user's — so the worktree's edit to an
existing module is silently not the code under test. A new module fails loud; a
changed one tests the wrong tree with everything green. `pip show <package>` says
which install it is in one command; where it is editable, give the worktree a
venv of its own, with the project installed from the worktree. A ticket that
changes the dependency file needs its own venv for a different reason: installing
into the shared one reaches every other session.

**Inside `.claude/adr-wip/`, a missing venv is no longer an error — it is the
parent's.** A launcher that finds the virtualenv by walking upward from the
working directory reaches the user's checkout in three steps, so a worktree with
no `.venv` of its own runs against the shared one silently, where beside the repo
it would have failed loudly and been fixed. Two consequences, and the second is
the one that bites: the symlink is still worth making, because a named symlink is
what a reader can see; and a worktree given a venv of its own must have that venv
**present**, since the upward walk will otherwise sail past the absence into the
very venv it was isolated from.

## Preflight: prove the environment, do not assume it

Everything above *constructs*. This section *checks*, and it runs on a worktree
that was created a minute ago and on one adopted from a year ago alike — the
adopted one needs it more, because nothing here built it.

Four questions, four commands, run **from inside the worktree** and reported as
one line each:

1. **Which interpreter?** `python -c 'import sys; print(sys.executable)'`. It
   must be a venv, and the one intended — the parent's for a shared setup, the
   worktree's own where a ticket earned one.
2. **Which tree do imports resolve to?** Import the project's own top-level
   package and print its `__file__`'s directory. **It must be under this
   worktree.** Pointing at the user's checkout is the editable-install failure
   above, and it is invisible in every other way: the suite goes green against
   code the worktree did not write.
3. **Is there an upstream?** `git rev-parse --abbrev-ref @{upstream}`. No
   upstream means every review in this drain derives its base from the remote's
   default branch, and reviews ticket five together with tickets one to four.
   Fix it with `git push -u origin <branch>` before the first ticket, not after
   a review has already reported another ticket's work.
4. **Do the guards still hold?** The three above, re-asked. A project's pytest
   or mypy config can change between drains, and a guard that held in March is
   not a guard that holds now.

**A preflight that fails stops before the first ticket.** Each of these four
fails *silently* and *late*: a green suite over the wrong tree, a review over the
wrong base, a doubled collection blamed on a flaky test. The whole value of the
section is that it costs four commands at a moment when there is nothing to
misattribute them to. Say what each answered, including when all four passed — a
run that prints no preflight line is indistinguishable from one that skipped it.

## Re-entry

**A worktree that is already there is resumed, not recreated**: check for the
directory and the branch first, and adopt them. Report the path either way —
every later step, and every command in it, runs in that directory. Then run the
preflight above, which is the only thing that knows whether an adopted
environment still works.

**A worktree in the old place is adopted where it stands.** `git worktree list`
is the question, and it names paths, so a worktree beside the checkout —
`../<repo>-adr-<N>`, where these skills used to put them — is found by it. Adopt
it, say on screen that it is outside `.claude/adr-wip/` and that the guards
therefore do not apply to it, and leave it there. Moving a worktree mid-drain
means `git worktree move` plus a state file whose recorded path is now wrong, to
buy tidiness in the middle of work; between drains it is the user's to do.

**A branch for this ADR under a different name is adopted, never duplicated.**
`git worktree list` and `git branch --list '*adr*<N>*'` are the two questions, and
an older or hand-made name — `adr<N>-wip`, `adr-<N>-work` — is this ADR's work
wearing a name from before the convention. Take it as it is, say on screen which
name you adopted and that it is not `adr-<N>`, and do **not** rename it: the
remote may track it and a state file may record it, so a rename mid-drain
invalidates both to buy tidiness. Renaming is the user's call to make between
drains, and the sentence on screen is what lets them make it. What must not
happen is creating `adr-<N>` beside it — two branches holding one ADR's work,
each reviewed against the wrong base.

## Leaving it

Nothing here merges the branch: that is a gesture with consequences outside
this work, and it is the user's. The worktree is removed by exactly one caller,
`dror-implement-adr`'s §4, and only from a clean finish — every ticket closed and
pushed, the tree clean, nothing shared pointing into it. Any other end of a run
leaves it standing, and so does any other skill.

Where the user does remove one, `git worktree remove` is the command and `rm -rf`
is not: a plain delete leaves the registration behind, and `git worktree list`
goes on advertising a path that is not there — which is exactly what the re-entry
check above reads. `--force` is ordinarily needed, because the ignored `.venv`
symlink and `.claude/` count as untracked to that command.

**What dies with the directory is the store beside it** — the drain's state file
and its progress log, `facts.md`, the reports. All of it is re-derivable, and
the drain's own state file says what re-deriving costs. The progress log is the
one thing there a *reader* may still want: it is only removed on a clean finish,
where the summary has just said everything the log would have, so nothing is
lost that was not also printed. What does *not* die is any committed and pushed
work, which is on the branch.
