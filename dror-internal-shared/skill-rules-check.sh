#!/usr/bin/env bash
# The mechanical half of ANTHROPIC-SKILL-RULES.md, as a script (ADR 0049).
#
# Takes one skill directory and prints one `BREACH:` line per published rule it
# breaks, or `CLEAN` when it breaks none. `dror-skill-review` runs it before its
# lenses and its findings skip the refuter — the script's own output is the
# proof, the way ADR 0045's lint pass already works in `dror-code-review`.
#
# This file **enforces** the rules, so it is the one place their numerals are
# spelled (the repo's tunable rule). ANTHROPIC-SKILL-RULES.md states them in
# prose and points here; neither restates the other.
#
# It always exits 0. A breach is a finding, not an error, and a non-zero exit
# would abort the skill invocation that injected it.

set -u

DESC_MAX=1024          # the published bound on `description:`
COMPAT_MIN=1           # the published bounds on the optional `compatibility:`
COMPAT_MAX=500

dir=${1:-}
[ -n "$dir" ] || { echo "BREACH: (no argument) — skill-rules-check.sh takes one skill directory"; exit 0; }
dir=${dir%/}
[ -d "$dir" ] || { echo "BREACH: $dir — not a directory"; exit 0; }

folder=$(basename "$dir")
n=0
breach() { echo "BREACH: $*"; n=$((n+1)); }

# --- the folder name
case $folder in
    *[A-Z]*)  breach "$folder — folder name has capitals; the published rule is kebab-case" ;;
esac
case $folder in
    *_*)      breach "$folder — folder name has an underscore; the published rule is kebab-case" ;;
esac
case $folder in
    *" "*)    breach "$folder — folder name has a space; the published rule is kebab-case" ;;
esac

# --- the instruction file, spelled exactly
skill="$dir/SKILL.md"
if [ ! -f "$skill" ]; then
    variant=$(ls "$dir" 2>/dev/null | grep -i '^skill\.md$' | head -1)
    if [ -n "$variant" ]; then
        breach "$dir/$variant — the instruction file must be named exactly SKILL.md, case-sensitive"
    else
        breach "$dir — holds no SKILL.md"
    fi
    echo "${n} breach(es)"; exit 0
fi

# --- no README.md inside a skill folder
[ -f "$dir/README.md" ] && breach "$dir/README.md — a skill folder may not hold a README.md; its documentation belongs in SKILL.md or a companion file"

# --- the frontmatter block
fm=$(awk 'NR==1 && $0!="---"{exit} NR>1{if($0=="---") exit; print}' "$skill")
if [ -z "$fm" ]; then
    breach "$skill:1 — no YAML frontmatter delimited by --- lines"
    echo "${n} breach(es)"; exit 0
fi

# --- no XML angle brackets anywhere in the frontmatter
case $fm in
    *"<"*|*">"*) breach "$skill — the frontmatter contains an angle bracket; frontmatter reaches the system prompt and brackets are an injection surface" ;;
esac

# --- name:
name=$(printf '%s\n' "$fm" | awk -F': ' '/^name: /{print $2; exit}')
if [ -z "$name" ]; then
    breach "$skill — the frontmatter has no name:"
else
    [ "$name" = "$folder" ] || breach "$skill — name: is '$name' but the directory is '$folder'; they must match"
    case $(printf '%s' "$name" | tr 'A-Z' 'a-z') in
        *claude*)   breach "$skill — name: contains 'claude', which is reserved" ;;
    esac
    case $(printf '%s' "$name" | tr 'A-Z' 'a-z') in
        *anthropic*) breach "$skill — name: contains 'anthropic', which is reserved" ;;
    esac
fi

# --- description:
desc=$(printf '%s\n' "$fm" | awk '/^description: /{sub(/^description: /,""); print; exit}')
if [ -z "$desc" ]; then
    breach "$skill — the frontmatter has no description:"
else
    len=${#desc}
    [ "$len" -le "$DESC_MAX" ] || breach "$skill — description: is $len characters, past the published bound of $DESC_MAX"
    # The trigger half is only owed where the description is what selects the
    # skill. `disable-model-invocation` keeps a skill out of the model's list
    # entirely, so it is chosen by the user typing its name and a trigger clause
    # would steer nobody.
    if printf '%s\n' "$fm" | grep -q '^disable-model-invocation: *true'; then
        :
    elif ! printf '%s' "$desc" | grep -qiE 'use when|use it when|use this|invoke (it )?when|trigger(s|ed)? (on|when)|reach for it when|when the user'; then
        breach "$skill — description: states what the skill does but names no trigger; the published shape is what it does plus when to use it"
    fi
fi

# --- compatibility:, where it is present at all
compat=$(printf '%s\n' "$fm" | awk '/^compatibility: /{sub(/^compatibility: /,""); print; exit}')
if [ -n "$compat" ]; then
    clen=${#compat}
    { [ "$clen" -ge "$COMPAT_MIN" ] && [ "$clen" -le "$COMPAT_MAX" ]; } \
        || breach "$skill — compatibility: is $clen characters, outside the published $COMPAT_MIN-$COMPAT_MAX"
fi

[ "$n" -eq 0 ] && echo "CLEAN" || echo "${n} breach(es)"
exit 0
