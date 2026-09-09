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

## The lock: one ADR, one session

**Take the lock before creating or adopting anything.** The re-entry rule below
adopts a worktree that is already there, and it cannot tell a worktree left by a
finished session from one a live session is working in. Two sessions on one ADR
therefore share a checkout, a branch, a state file and a progress log, and none
of the four notices. The state file is the worst of them: it is rewritten whole
each round, so the second session's write drops the first's rounds, and the
`picked` entry that makes a dead session's ticket recoverable is exactly what is
lost.

The lock is **`<repo>/.claude/adr-wip/adr-<N>.lock`**, beside the worktree
directory and not inside it, so it is answerable before the directory exists and
outlives its removal. Claim it with
[`claim-path.sh`](claim-path.sh) in `exclusive` mode:

```
bash ${CLAUDE_SKILL_DIR}/../dror-internal-shared/claim-path.sh exclusive \
  <the user's checkout>/.claude/adr-wip/adr-<N>.lock $PPID
```

`$PPID` is the agent process, which is what makes a dead holder recognisable
later; the script says why that pid and not another. **Exit 0 is the only
answer that may proceed.**

A loss names one of three holders on its `HELD:` line — `live`, `self` or
`stale` — and only the first of them ends the run flatly.

**A live holder ends the run before anything is touched** — no worktree adopted,
no ticket picked, no file written. Say which ADR, the pid and the time from the
`HELD:` line, and that the other session is the one to stop or wait for. This is
not an offer to override: the second drain would commit into the first's tree.

**A `self` holder is this session's own earlier run**, interrupted before it
reached an ending and so never releasing what it took. The pid on the lock is
the session's, not the run's, so it is still alive and still `claude` — which is
why the script compares it against the caller's rather than asking `ps` alone,
and why this case would otherwise be reported as the one thing it is not,
another live session. Nothing is being written into: the run that held it is
gone, and whatever worktree it left is what §Re-entry adopts. **Report it and
stop, the same shape as `stale`** — name the lock's path and the one command
that clears it, say the holder was this session's own interrupted run, and let
the user say the word. This run still touches nothing, because the clearing is
theirs: a forked run's question reaches the user only as its last message, which
ends the run, so it can ask and it cannot then act on the answer (ADR 0042).

**A stale holder is the ordinary end of a killed session**, and the script says
`stale` when no agent process wears that pid any more. Say so, name the lock's
path and the one command that clears it, and stop. Taking it over is the user's
call, because a pid can be stale while the branch it left behind is mid-ticket,
and only they know whether that session is really gone.

**`self` has one blind spot: two runs at once in one session.** They share the
pid, so a second drain started while the first is working reads `self` and is
told an interrupted run left the lock. The `rm` it offers is the sentence that
saves it: a user who knows the first drain is still going does not run it, and
the stop is what gives them the chance to say so.

**That blind spot is the lock's, and it is answered here or not at all.** A run
that took the lock and then, mid-work, suspects a second writer from what it
finds in its own log has not found a lock condition and must not stop as though
it had — it compares run stamps, by §The writer test in
`../dror-implement-adr/SKILL.md`. Twice now the suspicion was the run reading
its own writing.

**A per-run token on the lock does not close it**, and the reason is worth
writing down so nobody spends a day on it. What the reader needs is *liveness* —
is the run behind this lock still going — and a token is *identity*. A second run
comparing tokens learns that the holder is not itself, which it already knew from
the pid, and learns nothing about whether that holder is alive. Liveness is
answerable for a session because a session **is** a process and `ps` answers for
it; a run is not a process — every run in a session shares one `claude` — so the
kernel has nothing to be asked. **This says nothing against a token on the log
lines**, where the question really is identity: see `Run stamp` in
[`CONTEXT.md`](CONTEXT.md) and §The writer test in
`../dror-implement-adr/SKILL.md`. What is left is a clock: a heartbeat written into
the lock, and a threshold above which a holder counts as gone. This lock is
deliberately decided by the kernel rather than by a clock reading, and a drain
round can take an hour, so any threshold honest enough to be safe is too long to
be useful. The stop and the named `rm` are the answer instead.

```
rm <the user's checkout>/.claude/adr-wip/adr-<N>.lock
```

**`dror-adr-resume` is that call made by name.** A user who invokes it on an ADR
has said the holder is gone; the skill identifies the holder before removing
anything, clears a `stale` one and a `self` one, refuses a live one and a lock
claimed on another host, and then starts the drain. It is where the rule above
is delegated, and the only thing in this chain that removes a lock it did not
take.

**Release it wherever the run ends**, and that is the same command — a clean
finish, a stop for the user, a failed guard, a failed preflight. There is no
release mode and no unlock script, because a release and a takeover are the same
one line. **A run that ends without releasing locks the ADR against its own
next session**, which is why the stop that keeps a worktree standing must name
the lock path with it.

The two races this does not close: two sessions clearing one stale lock can both
take it, and a machine that dies between the claim and the first ticket leaves a
lock with nothing behind it. Both are narrower than what the lock closes, and
both are one `rm` to recover.

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
venv of its own, with the project installed from the worktree. That is the one
case that earns a private venv — building one is minutes and gigabytes, and the
symlink is the default everywhere else.

**Nothing installs into a shared venv.** A symlinked venv is the user's own, and
an install into it reaches their checkout and every other session at once. So no
run under this file installs a package, upgrades one, or removes one — not to
make a test pass, not to satisfy an import, not as a step it judges harmless.

**A missing package parks the ticket** (ADR 0054). Where a ticket cannot proceed
without a package the venv does not have, that is a question only the user can
answer: say which package, which ticket, and that the venv is shared; park it and
work the rest of the list. Installing it would be answering that question on the
user's behalf, in their environment.

**The dependency file is not the signal, and was the wrong thing to watch.** This
section used to ask, while the worktree was being built, whether the drain's work
would change the dependency file — a question the run cannot answer, since no
ticket has been read yet, and the wrong question besides: a package is often
installed by hand with no file change at all, and the file is often edited
afterwards, once the choice has proved out. Neither direction predicts the other.
Forbidding the install at the moment it would happen needs no prediction.

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
   must be a venv, and the one intended — the parent's, symlinked, in the
   ordinary case, or the worktree's own where an editable install earned it.
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
directory and the branch first, and adopt them. The lock above is taken before
this check, never after it — adopting first and locking second is two sessions
in one tree for however long the check takes. Report the path either way —
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
`dror-implement-adr`'s §4a, and only from a clean finish — every ticket closed and
pushed, the tree clean, nothing shared pointing into it. Any other end of a run
leaves it standing, and so does any other skill.

Where the user does remove one, `git worktree remove` is the command and `rm -rf`
is not: a plain delete leaves the registration behind, and `git worktree list`
goes on advertising a path that is not there — which is exactly what the re-entry
check above reads. `--force` is ordinarily needed, because the ignored `.venv`
symlink and `.claude/` count as untracked to that command.

**The lock does not die with the directory.** It sits beside it rather than in
it, so `git worktree remove` leaves it exactly where it was; releasing it is the
separate `rm` above, and it is owed on every ending, not only this one.

**What dies with the directory is the store beside it** — the drain's state file
and its progress log, `facts.md`, the reports. All of it is re-derivable, and
the drain's own state file says what re-deriving costs. The progress log is the
one thing there a *reader* may still want: it is only removed on a clean finish,
where the summary has just said everything the log would have, so nothing is
lost that was not also printed. What does *not* die is any committed and pushed
work, which is on the branch.
