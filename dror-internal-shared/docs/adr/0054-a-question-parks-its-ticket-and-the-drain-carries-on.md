# A question parks its ticket; the drain carries on

A drain that meets a question only the user can answer sets that ticket aside —
it and everything waiting on it — and works the rest of the list. Only a
condition that makes the whole run unsafe ends it. The questions are collected in
the summary, and `dror-interview` asks the answerable ones before the run
starts.

## The problem

`dror-implement-adr` is built to be left running. The user's case is a drain
started in the evening and read in the morning — up to a day of unattended work.

Until this decision, every question ended the run. A ticket whose criterion could
not honestly be implemented, a ticket still `owed` at its review cap, a tree found
dirty, a blocker still open: each was a §3a stop, and the stop was right about the
question and wrong about the time. A question raised at 3am is answered at 8am,
and the machine spends five hours doing nothing while fifteen workable tickets sit
on the list.

The old rule had a reason and it still holds where it applies: *an answer given
now applies to a tree with one ticket of work in it, while the same answer given
after four more tickets applies to a tree whose later work was written against
the guess.* That is a real cost. It is a smaller cost than a night.

## Considered options

**Answering the question with a default** was rejected outright and is worth
recording as rejected: a drain that decides what to build has left the one
judgement this chain reserves for the user, and it would do it unwatched.

**Stopping, as before** keeps the old guarantee — every answer applies to the
tree the question was asked about — and pays for it with the whole remaining
night. Rejected for the unattended case, which is the case this skill is for.

**Flags on the drain command** — standing answers passed as arguments — was
rejected as the whole answer. It settles the four fixed permissions, and nothing
about the questions that come from the ticket set itself, which are the ones the
user most wants asked while they are awake.

**A time box** — stop only after N hours of parking — was rejected as a rule with
a number nobody can pick, and as one that makes the drain's behaviour depend on
the clock rather than on what it found.

## The decision

**A question about one ticket parks that ticket.** It leaves the list with
everything downstream of it, exactly as §3's sort sets aside a node that is not
workable here; its round's `outcome` is `parked` and carries the question
verbatim; the drain takes the next ticket. Nothing is guessed, and what was
already committed under that ticket's number stays committed.

**A condition about the tree or the run stops it.** The red baseline, a ticket
run that reports it was in the wrong tree, a dirty tree holding somebody else's
work, a cycle in the graph, an unreadable status row. None of them is about a
single node, and no answer makes carrying on safe.

**The answerable questions are asked first.** `dror-interview` runs the same
ADR review the drain runs, reads the table, adds the four standing permissions,
puts them all in one sitting, and writes `interview-<ADR>.md`. The drain
applies an answer where it plainly settles the question in front of it, quotes
the file in its log, and parks where it does not — a stretched answer would be
the drain deciding after all.

## Consequences

**A parked answer arrives against a moved tree.** The ticket parked at 3am is
answered over a branch with ten more tickets in it, and it may need rewriting
against them. This is the cost the old rule was avoiding, taken deliberately and
named in the summary.

**The summary leads with the questions.** A night that parked six tickets and
finished eleven must not read as a night that needed nothing, so the questions go
first, numbered, above the table.

**A drain can now end with nothing finished and no stop.** Where every ticket
parks, the list empties, §4 finds its conditions unmet, the spec stays open and
the worktree stands. That is the correct outcome of a night whose every ticket
needed the user.

**`parked` joins the round outcomes**, beside `picked`, `finished`, `skipped` and
`stopped`, and `RESUME.md` reads it as what it is: a round that ended, with its
ticket workable again once the question is answered.

**The ordinary notification carries a park**, not the critical one. A night of
critical alerts is a night of alerts nobody reads; the drain is still working, and
the interruption is owed only where it has stopped.
