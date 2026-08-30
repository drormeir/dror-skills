#!/usr/bin/env bash
# The stamp check of dror-internal-project-facts, as a script.
#
# Prints the five facts from <repo>/.claude/dror-skills/facts.md when its stamp
# still matches the tree, and one line beginning `MISS:` when it does not. It is
# run by the `!` injection line at the top of every chain skill, so the facts
# arrive inside the skill text and no model turn is spent comparing checksums.
# It always exits 0: a non-zero exit would abort the skill invocation, and a
# miss is never an error — the skill's step 2 gathers.
#
# The check list below is the closed list dror-internal-project-facts/SKILL.md
# step 1 names; this file is where it is enforced.

set -u
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
store="$root/.claude/dror-skills/facts.md"

miss() { echo "MISS: $*"; echo "store: $store"; exit 0; }

[ -f "$store" ] || miss "no facts.md in the store"
command -v cksum >/dev/null || miss "cksum is not available; gather and stamp by size and mtime"

# --- the stamp: every "- <path> — <size> — <cksum>" line after "## Stamp"
stamped=$(awk '/^## Stamp/{s=1;next} s && /^- /{print}' "$store")
[ -n "$stamped" ] || miss "facts.md has no stamp"

declare -A seen
while IFS= read -r line; do
    # "- path — size — cksum"; the separators are em dashes with spaces around them
    p=${line#- }; p=${p%% — *}
    rest=${line#*— }; size=${rest%% — *}; sum=${rest##*— }
    seen["$p"]=1
    [ -f "$root/$p" ] || miss "stamped file gone: $p"
    read -r now_sum now_size _ < <(cd "$root" && cksum "$p")
    [ "$now_sum" = "$sum" ] && [ "$now_size" = "$size" ] || miss "stamped file changed: $p"
done <<< "$stamped"

# --- the check list: a file that appeared since the stamp is a miss
cd "$root" || miss "cannot enter $root"
appeared=()
for f in CLAUDE.md AGENTS.md CONTEXT.md README* CONTRIBUTING* \
         package.json Makefile pyproject.toml Cargo.toml go.mod pytest.ini tox.ini; do
    [ -f "$f" ] && [ -z "${seen[$f]:-}" ] && appeared+=("$f")
done
if [ -d docs ]; then
    while IFS= read -r f; do
        case "$f" in *adr*|*agent*) [ -z "${seen[$f]:-}" ] && appeared+=("$f");; esac
    done < <(find docs -type f -name '*.md' | sed 's#^\./##')
fi
[ ${#appeared[@]} -eq 0 ] || miss "check-list file not in the stamp: ${appeared[*]}"

# --- hit: the facts, without the stamp
echo "Project facts — stamp matched, read from $store"
echo
awk '/^## Stamp/{exit} {print}' "$store"
