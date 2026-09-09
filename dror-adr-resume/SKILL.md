---
name: dror-adr-resume
description: Clear the drain lock an interrupted dror-implement-adr left behind, then start the drain again on the same ADR - the holder identified before anything is removed, and a live one left alone. Use when a drain was interrupted and the next run says the ADR is locked, or the user asks to resume, restart or carry on draining an ADR.
disable-model-invocation: true
---

# dror-adr-resume

One ADR goes in. The run identifies whoever holds that ADR's drain lock, removes
it where removing it is safe, and then invokes `dror-implement-adr` on the same
number. It works no ticket of its own and owns no part of the drain.

The ADR number is this skill's one argument. Without it, say so and stop — and a
number named earlier in the session is not it, so say so and stop for that too.

**What it exists for.** A drain that ends by itself — a clean finish, a stop for
the user, a failed guard — releases its lock on the way out. A drain that is
*interrupted* never reaches any of those endings, so the lock outlives it, and
the next drain on that ADR stops on a holder that is not there. The recovery is
one `rm`, and `../dror-internal-shared/WORKTREE.md` deliberately leaves it to the
user: only they know whether the session behind that pid is really gone.
**Invoking this skill is that judgement, made once, by name.** Everything below
is about not letting it be made on a lock somebody is still using.

**It does not resume anything itself.** What an interrupted drain left — the
worktree, the branch, the state file, a round entry still reading `picked`, a
dirty tree — is `dror-implement-adr`'s to re-enter, by its own §3 and
`dror-implement-adr/RESUME.md`. This skill removes the one thing that stops that
re-entry from starting, and nothing else. So it is also the safe way to *start* a
drain: with no lock in the way it is `dror-implement-adr` with an extra look.

**It is convention-bound**, inheriting the binding from `dror-implement-adr`: it
takes an ADR by number and reads the lock path that skill's worktree rules fix.

## 0. This run does not fork, and that is deliberate

Most skills the user runs to work the chain carry `context: fork` (ADR 0036).
This one does not, because it would spend a whole level of the harness's
spawn-depth cap on four commands: forked, the drain it invokes would sit one
level deeper than it does today, and ADR 0043 — which owns that cap and its
arithmetic — ends on the rule this file obeys, that **the chain gains no depth**.
A drain invoked from here must land exactly where a drain the user typed lands.
`dror-adr-sweep` and `dror-interview` do not fork either, and both cite this
skill as their precedent.

What a fork would have bought is not worth that. This run reads two files and
runs four commands, five where it clears the lock; it keeps no working context
worth isolating, and the drain it starts is forked by its own frontmatter, so
the session it was invoked from still never reaches the drain.

**It takes nothing from the conversation all the same.** Not forking is what
makes that a rule this file has to state for itself, and it states it where the
argument is introduced, above.

## 1. Find the lock

From the user's checkout:

```
git rev-parse --show-toplevel
```

The lock's path and name are `../dror-internal-shared/WORKTREE.md`'s, in one
copy: read that file's lock section for the path and the release command, and
take both from it. This skill adds only the number.

Read the file at that path.

**No file there is the ordinary answer, not a failure.** Nothing holds the ADR;
say so in one line and go to §3 — the drain is invoked exactly as it would have
been without this skill.

Otherwise it carries the claiming session's pid, the moment it claimed, and the
host, as `claim-path.sh` wrote them.

## 2. Say who holds it, before anything is removed

Three questions, three commands, and their answers decide everything below:

```
ps -o comm= -p <the lock's pid>
```

```
hostname
```

and this session's own pid, which is what separates the case that is safe from
the case that looks identical:

```
echo "$PPID"
```

**Three of the four answers below are states
`../dror-internal-shared/claim-path.sh` defines** — `self`, `live` and `stale`
are its words, and this skill only reads them. It cannot ask the script for one:
the script has no inspect mode, the state exists only as a side effect of losing
a claim, and a call would take a lock this run does not want. So the two commands
above that name a pid make the script's own comparison by hand. The host is this
skill's own question, asked nowhere else: no `HELD:` line carries it.

Four answers, and only two of them clear the lock:

- **The lock's host is not this one.** A pid on this machine says nothing about a
  process on another, so nothing here can tell a dead drain from a running one.
  **Stop**, name the host and the pid, and hand the user the release command from
  WORKTREE.md, for them to run once they know.
- **The pid is this session's own — the script's `self`.** Then the claim was
  made by this very process, most often an earlier drain in this session,
  interrupted. It could also be a second drain still working: both wear the
  session's pid, and `self` cannot separate them — WORKTREE.md owns that blind
  spot and this file does not close it. **Clear it.** This is the case the whole
  skill is for: the script stops the drain that meets it, because clearing a lock
  is the user's word to give, and invoking this skill is that word.
- **The pid is another live `claude` — the script's `live`.** Another session is
  draining this ADR right now. **Stop**, name the pid and the time from the lock,
  and say that the other session is the one to stop or wait for. This is not an
  offer to override, for WORKTREE.md's reason: the second drain would commit into
  the first's tree.
- **No live `claude` wears the pid — the script's `stale`.** A killed session, or
  a machine that died. **Clear it.**

**Say which of the four it was, in one line, before acting on it.** A lock
removed without that line is indistinguishable from a lock that was never there,
and the next reader of the transcript is the person deciding whether to trust the
branch underneath.

## 3. Clear it, then start the drain

Where §2 said to clear, run WORKTREE.md's release command against the path §1
read, and say the lock is gone. Nothing else is removed: the worktree, the
branch, the state file and the progress log are all the drain's re-entry to
judge, and this run touches none of them.

The drain that starts next mints a stamp of its own, so the rounds and log lines
it inherits carry the dead run's. That is the ordinary shape of a resumed file
and not a second writer — §The writer test in
`../dror-implement-adr/SKILL.md` is what reads it, and it is the reason this run
leaves both files exactly as it found them.

Then, **in the same turn**, invoke the `dror-implement-adr` skill with the ADR
number as its argument, and nothing else — it takes the branch, the worktree, the
preflight and the whole ticket list from there, starting with a lock of its own
that it can now take.

That invocation is this step's last move and this run's whole remainder. The
drain is forked by its own frontmatter, so what comes back here is its closing
summary; **that summary is a step's result and not this run's reply**, and it is
the shape a run ends on by mistake — `../dror-internal-shared/DELEGATION.md`, the
shelf, owns what that means, at authoring time. So the named next action after
the drain returns: **relay its summary whole, add §Present's one line above it,
and stop.**

A run that stopped at §2 invokes nothing. Its stop is the whole answer.

## Present

One line first: which of §2's four answers held, and whether the lock was
removed. Then, where the drain ran, **its own summary, relayed whole and
unedited** — the stop or the table, the worktree, the log path, all of it. It is
the drain's account of the drain, and re-wording it is how a reader loses track
of which layer said what.

Where §2 stopped the run, that line is the whole reply, and §2's two stops do not
end the same way. On the host mismatch it is followed by the release command as
the user would type it. On a live holder it is not: handing the command over is
the override that branch refuses. Nothing about tickets either way, and no drain
summary: none ran.

Done when the holder was named, a lock was removed only in the two cases that
allow it, the drain was invoked wherever the lock was cleared or absent, and its
summary is on screen under that one line.
