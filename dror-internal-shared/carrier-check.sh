#!/usr/bin/env bash
# The carrier rule as a script (ADR 0057): no skill invokes another skill with
# `Skill` from inside a forked context.
#
# Takes one skill directory and prints one `BREACH:` line per offending
# invocation, or `CLEAN`. `dror-skill-review` runs it beside
# `skill-rules-check.sh` and its findings skip the refuter the same way — the
# script's own output is the proof.
#
# Why a script and not a lens (ADR 0049's reasoning, applied again): the rule is
# decidable by reading two files' frontmatter, and a lens that has to be chosen
# and then reasoned with is a worse instrument than a grep that always runs.
# `dror-skill-review-repair` was written into the forbidden shape three hours
# after ADR 0044 forbade it and went unnoticed for a week; this is the check
# that would have caught it that afternoon.
#
# It is **not** in `skill-rules-check.sh` because that file owns the mechanical
# half of ANTHROPIC-SKILL-RULES.md — what Anthropic publishes — and this is a
# house rule of this repo's own. One script per owner.
#
# It always exits 0. A breach is a finding, not an error, and a non-zero exit
# would abort the skill invocation that injected it.

set -u

# The exempt caller→target pairs, each with the decision that grants it. This
# file enforces the rule, so the list lives here and nowhere else.
#
# **The list is empty, and that is the point** (ADR 0059). Every skill-to-skill
# hand-off in this repo now rides the carrier. An entry added here is a
# deliberate exception and needs the decision that grants it named beside it —
# the two that used to sit here were closed rather than kept, because a guard on
# one and a shallow path on the other were reasons to go last, not reasons to
# stay behind.
exempt() {
    case "$1 -> $2" in
        # (none)
        "") return 0 ;;
    esac
    return 1
}

forks() {  # $1 = a SKILL.md; true when its frontmatter carries context: fork
    [ -f "$1" ] || return 1
    awk 'NR==1 && $0!="---"{exit} NR>1{if($0=="---") exit; print}' "$1" \
        | grep -q '^context: *fork'
}

dir=${1:-}
[ -n "$dir" ] || { echo "BREACH: (no argument) — carrier-check.sh takes one skill directory"; exit 0; }
dir=${dir%/}
[ -d "$dir" ] || { echo "BREACH: $dir — not a directory"; exit 0; }

skill="$dir/SKILL.md"
[ -f "$skill" ] || { echo "CLEAN"; exit 0; }   # skill-rules-check.sh owns that breach

caller=$(basename "$dir")
root=$(cd "$dir/.." && pwd)
n=0

# A caller that does not fork cannot make a fork-from-fork. This is why
# `dror-adr-resume`, `dror-adr-sweep` and `dror-interview` invoke forked skills
# freely: they run in the session, and a fork made there has never arrived bare.
if ! forks "$skill"; then
    echo "CLEAN"; exit 0
fi

# Every Markdown file in the directory, not just SKILL.md: a companion is prose
# the same forked run executes, and `dror-implement-ticket/SETTLING.md` invoked
# a forked skill while its SKILL.md did not.
for file in "$dir"/*.md; do
    [ -f "$file" ] || continue

    # The `dror-*` name the verb actually governs — "Invoke the `dror-x` skill",
    # "invokes `dror-x`" — and not every name that happens to share the line: one
    # sentence names the loop it invokes and the two skills that loop runs, and
    # only the first of the three is invoked there. A line forbidding an
    # invocation is not one; `sort -u` so a target named twice is one breach.
    targets=$(grep -E '\b[Ii]nvoke[sd]?\b' "$file" \
        | grep -vE '[Dd]o not invoke|never invoke|rather than invoking|instead of invoking' \
        | grep -oE '[Ii]nvoke[sd]?( the)? `dror-[a-z-]+`' \
        | grep -oE '`dror-[a-z-]+`' | tr -d '`' | sort -u)

    for target in $targets; do
        [ "$target" = "$caller" ] && continue
        forks "$root/$target/SKILL.md" || continue
        exempt "$caller" "$target" && continue
        echo "BREACH: $file — invokes \`$target\` with \`Skill\` from inside a forked context; a fork made from inside a fork can arrive without its arguments (ADR 0043). Drive it as a spawned agent by STEP-AGENT.md, or record the exemption in carrier-check.sh."
        n=$((n+1))
    done
done

[ "$n" -eq 0 ] && echo "CLEAN" || echo "${n} breach(es)"
exit 0
