#!/usr/bin/env bash
# The stamp check of ANTHROPIC-SKILL-RULES.md, as a script.
#
# Prints one `VENDOR:` line saying whether the rules distilled beside it were read
# off the upload Anthropic serves right now. It is run by the `!` injection line
# in dror-skill-review, so the verdict arrives inside the skill text and no
# model turn is spent on a HEAD request.
#
# It always exits 0. A non-zero exit would abort the skill invocation, and
# neither a moved source nor a dead network is an error here: the review runs
# either way and reports what this line said.
#
# This file owns the comparison. ANTHROPIC-SKILL-RULES.md owns the URL and the
# ETag it compares against, and is the only place either is spelled.

set -u
rules="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ANTHROPIC-SKILL-RULES.md"

say() { echo "VENDOR: $*"; exit 0; }

[ -f "$rules" ] || say "unknown — no ANTHROPIC-SKILL-RULES.md beside the check script"
command -v curl >/dev/null || say "unknown — curl is not available, stamp not compared"

url=$(awk '/^- Source: /{print $3; exit}' "$rules" | tr -d '`')
want=$(awk -F'"' '/^- `etag:/{print $2; exit}' "$rules")
[ -n "$url" ] && [ -n "$want" ] || say "unknown — ANTHROPIC-SKILL-RULES.md carries no source URL or no etag"

head=$(curl -sIL --max-time 10 "$url" 2>/dev/null) || say "unknown — the source could not be reached, stamp not compared"
got=$(printf '%s' "$head" | awk -F'"' 'tolower($0) ~ /^etag:/{print $2}' | tail -1)
mod=$(printf '%s' "$head" | awk 'tolower($0) ~ /^last-modified:/{sub(/^[^:]*: */,""); print}' | tail -1)

[ -n "$got" ] || say "unknown — the source served no ETag, stamp not compared"

if [ "$got" = "$want" ]; then
    say "current — the distilled rules match the published guide (last-modified: ${mod:-unstated})"
fi

say "moved — the guide was re-uploaded (etag $got, last-modified: ${mod:-unstated}); ANTHROPIC-SKILL-RULES.md was distilled from etag $want"
