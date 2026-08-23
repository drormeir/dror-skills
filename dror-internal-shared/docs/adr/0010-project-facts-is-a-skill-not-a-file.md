# dror-internal-project-facts is a skill, not a file the others read

It began as a shared reference. Making it a skill lets it *decide* — ask the
store, skip the gather when the stamp holds, rewrite when it does not — so a
caller says "get me the facts" and never repeats the caching rule.

## Consequences

It must be model-invoked to be reachable from inside another skill, and its
always-loaded description is the price.

Its instructions are loaded into the run that asked for them, so "return the
facts" means carry them on into that run — only a run started *for* the facts
ends there.

It is the one dror skill worth dispatching to a subagent: on a miss it reads
every rule file in the repo and only the facts and the stamp need to come back.
Read into the caller's own context, a large conventions doc is paid for again by
every later agent prompt.
