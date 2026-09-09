#!/usr/bin/env bash
# The run-stamp rules as a script: a loop names itself before it starts, and a
# store it writes says so on every line.
#
# Takes one skill directory and prints one `BREACH:` line per rule broken, or
# `CLEAN`. `dror-skill-review` runs it beside `skill-rules-check.sh` and
# `carrier-check.sh`, and its findings skip the refuter the same way — the
# script's own output is the proof.
#
# The two rules, and both are `CONTEXT.md`'s `Run stamp` term:
#
#   1. **Minted before the loop.** A skill with a round loop mints its run tag
#      before the loop's first round, so every line it writes from its first one
#      carries the same name. The three review-repair loops each say "Before
#      round 1, mint a run tag"; `dror-implement-adr` minted at its ADR check
#      instead — part-way in — so its preflight lines went down unsigned.
#   2. **A store that is written says who wrote it.** A `.log` or `.json` a
#      skill appends to or rewrites per round names the tag near where it is
#      defined. A store with no writer on its lines leaves "who wrote this" to
#      memory, and memory is not evidence.
#
# Why a script and not a lens (ADR 0049's reasoning, as `carrier-check.sh` has
# it): both are decidable by reading one file in order, and a grep that always
# runs beats a lens that has to be chosen. `dror-implement-adr` acquired its
# progress log on 2026-08-31 in the same commit that gave every *other* log a
# `run_tag`; nine days later two drains stopped without working a ticket, each
# having read its own unsigned lines as a second writer's. This is the check
# that would have caught it that afternoon.
#
# It always exits 0. A breach is a finding, not an error, and a non-zero exit
# would abort the skill invocation that injected it.

set -u

# How far below a store's definition the stamp may be stated. A window and not a
# section, because a section boundary is not decidable here — the paragraphs that
# define a store run on for tens of lines and end at no mark a grep can see. Too
# wide misses nothing and reports nothing; too narrow fails an honest file. 40
# lines is the width of the widest of the three stores in the tree today, and 40
# was tried first and rejected: at that width the drain's progress log passed on
# a mention of the *state file's* tag thirty lines below it, which is the very
# defect this rule is for.
readonly WINDOW=20

dir=${1:-}
[ -n "$dir" ] || { echo "BREACH: (no argument) — stamp-check.sh takes one skill directory"; exit 0; }
dir=${dir%/}
[ -d "$dir" ] || { echo "BREACH: $dir — not a directory"; exit 0; }

n=0

for file in "$dir"/*.md; do
    [ -f "$file" ] || continue

    # --- Rule 1: the mint precedes the loop -------------------------------
    #
    # A loop heading is `## Rounds` or `## <n>. The loop`. "What this loop does
    # not repair" is a heading about the loop and not its start, which is why
    # the match is anchored rather than a search for the word.
    loop=$(grep -nE '^## (Rounds|[0-9]+[a-z]?\. The loop)\b' "$file" | head -1 | cut -d: -f1)

    if [ -n "$loop" ]; then
        # A mint line names the act and the thing minted. `grep -v kind` drops
        # the loops' other sense of the word — what a finding's *kind* means is
        # "minted in" the review, and that is not a tag.
        mint=$(grep -niE '\bmint(s|ed|ing)?\b' "$file" | grep -i 'tag' \
               | grep -vi 'kind' | head -1)
        mintline=${mint%%:*}

        # Two ways to be early, and the second is why the heading alone will not
        # do. A `## Rounds` section opens with pages describing the loop before
        # any round runs, so a mint written under it can still be the run's first
        # act — and the three review-repair loops all say so in the sentence
        # itself: "Before round 1, mint a run tag". Take the file at its word
        # when it states the order, and fall back to position when it does not.
        if [ -z "$mint" ]; then
            echo "BREACH: $file — has a round loop (line $loop) and never mints a run tag; every line the run writes is then unsigned (CONTEXT.md, \`Run stamp\`)."
            n=$((n+1))
        elif ! printf '%s' "$mint" | grep -qiE 'before (round 1|the (first (round|ticket)|loop))|right after the lock'; then
            if [ "$mintline" -gt "$loop" ]; then
                echo "BREACH: $file — mints its run tag at line $mintline, after the loop's section opens at line $loop, and does not say the mint happens before round 1. Whatever the run wrote first is then unsigned: mint it before the loop, or say in that sentence that it is minted before round 1."
                n=$((n+1))
            fi
        fi
    fi

    # --- Rule 2: a store that is written says who wrote it -----------------
    #
    # Only `.log` and `.json` under the store: those are the files a run appends
    # to or rewrites as it goes. A report is `.md` and carries its tag in front
    # matter by REPORT-STORE.md's own rule, which owns that half.
    while IFS=: read -r ln _; do
        [ -n "$ln" ] || continue
        end=$((ln + WINDOW))
        if ! sed -n "${ln},${end}p" "$file" | grep -qi 'tag'; then
            store=$(sed -n "${ln}p" "$file" | grep -oE '[A-Za-z<>0-9_.-]+\.(log|json)' | head -1)
            echo "BREACH: $file:$ln — defines the store \`${store:-?}\` and names no run tag within $WINDOW lines; a line in it cannot then be told from another run's (CONTEXT.md, \`Run stamp\`)."
            n=$((n+1))
        fi
    done <<EOF
$(grep -n 'dror-skills/[A-Za-z<>0-9_.-]*\.\(log\|json\)' "$file")
EOF
done

[ "$n" -eq 0 ] && echo "CLEAN" || echo "${n} breach(es)"
exit 0
