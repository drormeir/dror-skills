# The facts cache is capped in bytes, and the cap is measured

`facts.md` is pasted into every agent prompt of every run that asks for it, so it
carries a budget. The budget used to be "about 60 lines together", and the file
written for one real repo came out at 124 lines and **37 KB** — roughly 9k tokens
per agent prompt. A line is not what a prompt pays for, and nothing measured the
cap anyway.

So the cap is **about 12 KB**, measured with one `wc -c` before the file is
written, and the resulting size is recorded in the stamp so the next run can see
the budget was met.

## Considered options

Blessing the 40 KB the gather already produced was rejected: the cache would then
cost more per agent than reading the source documents once. Raising the line
count was rejected because a future gather can double the bytes without moving
it.

## Consequences

Over the cap, the fix is to cut to pointers — `ADR 0005 §working set` costs six
tokens and the agent that needs the paragraph opens the file. A fact reproduced
in the cache also goes stale there, silently, while a pointer never does.
