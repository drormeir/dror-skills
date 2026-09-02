---
name: dror-adr-resume
description: Clear the drain lock an interrupted dror-implement-adr left behind, then start the drain again on the same ADR - the holder identified before anything is removed, and a live one left alone. Use when a drain was interrupted and the next run says the ADR is locked, or the user asks to resume, restart or carry on draining an ADR.
disable-model-invocation: true
---

# dror-adr-resume

One ADR goes in. The run identifies whoever holds that ADR's drain lock, removes
it where removing it is safe, and then invokes `dror-implement-adr` on the same
number. It works no ticket of its own and owns no part of the drain.

The ADR number is this skill's one argument. Without it, say so and stop.

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

Every other skill the user runs to work the chain carries `context: fork`
(ADR 0036). This one does not, because it would spend a whole level of the
harness's spawn-depth cap on four commands: forked, the drain it invokes would
sit one level deeper than it does today, and ADR 0043 — which owns that cap and
its arithmetic — ends on the rule this file obeys, that **the chain gains no
depth**. A drain invoked from here must land exactly where a drain the user typed
lands.

What a fork would have bought is not worth that. This run reads one small file
and runs three commands; it keeps no working context worth isolating, and the
drain it starts is forked by its own frontmatter, so the session it was invoked
from still never reaches the drain.

**It takes nothing from the conversation all the same.** The ADR number is the
argument, and a number named earlier in the session is not one — say so and stop,
exactly as a forked skill would.

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

Two questions, two commands, and their answers decide everything below:

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

Four answers, and only two of them clear the lock:

- **The lock's host is not this one.** A pid on this machine says nothing about a
  process on another, so nothing here can tell a dead drain from a running one.
  **Stop**, name the host and the pid, and hand the user the release command from
  WORKTREE.md, for them to run once they know.
- **The pid is this session's own.** Then the claim was made by this very process
  — an earlier drain in this session, interrupted — and it is not running now,
  because this session is running this skill instead and a drain blocks the
  session it runs in. **Clear it.** This is the case the whole skill is for, and
  it is the one `claim-path.sh` must call live: it asks only whether some
  `claude` wears that pid, and one does — us.
- **The pid is another live `claude`.** Another session is draining this ADR
  right now. **Stop**, name the pid and the time from the lock, and say that the
  other session is the one to stop or wait for. This is not an offer to override,
  for WORKTREE.md's reason: the second drain would commit into the first's tree.
- **No process wears the pid, or it is not `claude`.** The stale holder — a
  killed session, or a machine that died. **Clear it.**

**Say which of the four it was, in one line, before acting on it.** A lock
removed without that line is indistinguishable from a lock that was never there,
and the next reader of the transcript is the person deciding whether to trust the
branch underneath.

## 3. Clear it, then start the drain

Where §2 said to clear, run WORKTREE.md's release command against the path §1
read, and say the lock is gone. Nothing else is removed: the worktree, the
branch, the state file and the progress log are all the drain's re-entry to
judge, and this run touches none of them.

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

Where §2 stopped the run, that line is the whole reply, followed by the release
command as the user would type it. Nothing about tickets, and no drain summary:
none ran.

Done when the holder was named, a lock was removed only in the two cases that
allow it, the drain was invoked wherever the lock was cleared or absent, and its
summary is on screen under that one line.
