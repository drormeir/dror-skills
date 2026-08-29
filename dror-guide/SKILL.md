---
name: dror-guide
description: Answer as a step-by-step guide in plain words, assuming nothing. Use when the user asks how to do something, or says an answer went over their head.
---

# dror-guide

Turn the answer into a guide the user can follow straight through, without
stopping to work out what something means.

It is **repo-agnostic** (ADR 0011) and barely a repo skill at all: it names no
tracker and no path, and governs the shape of an answer about whatever is being
discussed.

## Shape

A numbered list of steps, and the list is the whole message. This shape wins
over any terse style in force (`brief`): a requested guide is itself the
deliverable that brief exempts.

## Each step

- **One action.** A step with two verbs is two steps.
- **The exact thing.** The literal command, the literal path, the literal
  button: `Open ~/.claude/skills in Cursor`, where a vaguer answer would say
  "pick a working directory".
- **Every term explained where it appears.** A step that names a tool, a term
  or a place says in the same breath what it is, in plain words. The user
  follows it with the knowledge they already have.
- **Bold action first, then the reason.** The opening sentence is what to do.
  Sentences after it say why, when the user needs that to get it right.
- **Short sentences, one idea each.** Everyday words carry it.
- **Its own number for every prerequisite.** A restart, an install, a window to
  open — if the user must do it, it is a step in the list.

## What earns a place

The one way you recommend, and the actions needed to walk it. A caveat earns a
step of its own when it changes what the user types. Everything else — the
alternatives, the history, the internals, the trade-offs — waits until the user
asks for it.

## When the guide misses

The user says it is too long, or that a step assumed something, or asks for it
again.

Rewrite the whole list, shorter, with the gap filled. The new list is the entire
reply.
