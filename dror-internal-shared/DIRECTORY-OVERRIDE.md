# The directory override: what an obeying fork honours

The shared rule for a `dror-*` fork handed the sentence "All commands run in
`<path>` …" as part of its arguments. It owns **what that sentence obliges the
run to do** — the duties below, in one copy, owned by the shelf and belonging
to none of the obeying skills. A skill that accepts the override points here
and does not restate these duties; read this file whole when the sentence
arrives, and not otherwise — a direct run has no override and skips it.

What is **not** here: the term's definition (the glossary in
[`CONTEXT.md`](CONTEXT.md) owns that); the fold the sentence keys in
`dror-implement-ticket` (that skill's own); which of a skill's commands the
duties reach — each obeying skill names its own list, git alone or tests, lint
and type-check with it — and what "every agent this run spawns" covers there.
The reasons are ADR 0043.

## Where the sentence comes from

It is passed down by a drain (ADR 0043), or given by any caller pointing the
run at a checkout that is not the session's — a temp worktree, another clone —
because a forked skill starts in the session's primary working directory,
which is then the wrong repository. **No override means the session's own
checkout, which is the ordinary direct run.**

## The duties

Honour it everywhere:

- Every command the obeying skill's file instructs runs under `<path>` — the
  skill's own text says which commands it has and how they take the directory.
- `<repo>` in every path means that directory, and the store and the facts are
  that directory's.
- Every agent the run spawns is given the sentence at the top of its prompt.
- **The injected facts block is void.** It was printed in the session's
  primary directory, before the argument could be read — disregard it and run
  the same stamp script again with `<path>` as its working directory, treating
  what that prints, `MISS` included, as the facts from then on.

<!-- The obeying skill's frontmatter `allowed-tools` line covers only its `!`
injection; everything else its file instructs — the facts re-run under
`<path>` and the `git -C` commands alike — runs under the user's settings,
which carry the same rule with a wildcard over the skill directory (ADR 0037,
Consequences) — so the re-run needs no grant the skill file does not have. -->
