#!/usr/bin/env bash
# Claims a caller-named path, exactly, before anything is written to it.
#
# One primitive, two rules for losing it. Both rest on the same exclusive create
# (`set -C`), so of two writers reaching for one path exactly one wins — decided
# by the kernel, not by a clock reading or a look-then-write. What differs is
# what the loser is told to do, and the caller says which by the mode:
#
#   next-free <path>          A report. The path is a filing convention and
#                             nothing looks it up by name again, so losing means
#                             step aside: prints the same name with `-2`, `-3`
#                             and so on before the extension. The caller writes
#                             its report over the path this printed, and names
#                             that path on screen when it differs from the one
#                             asked for.
#
#   exclusive <path> <pid>    A lock. The path is looked up by name later — a
#                             resumed drain opens the state file it wrote — so a
#                             name beside it would be a second run working the
#                             same branch while neither could see the other.
#                             Losing means stop. Creates the file holding the
#                             claiming session's pid and the moment it claimed,
#                             and on a loss prints the holder and whether that
#                             process is still alive.
#
# `<pid>` is the *session's* pid, not this script's: pass `$PPID` from the shell
# of the tool call, which is the agent process and stays the same all run. This
# script's own parent is that shell and would die with the call.
#
# Releasing is `rm` — there is no release mode, because a lock is released by
# the run that holds it and taken over from one that died, and both are the same
# one command. A takeover is not atomic; two sessions recovering one dead drain
# can both take it, which is a narrower race than the one this closes.
#
# This file **enforces** the claim, so it is the one place the suffix bound is
# spelled (the repo's tunable rule). REPORT-STORE.md owns when a report claims a
# path at all and WORKTREE.md owns when a drain takes the lock; neither restates
# the other.
#
# It exits 0 when it claims a path, 3 when `exclusive` lost to a live or dead
# holder, and 2 on anything else. Unlike the facts stamp, nothing injects this at
# load time, so a non-zero exit aborts no skill — and a run that writes its
# findings nowhere, or drains an ADR another session is draining, is an error
# rather than a miss.

set -u

SUFFIX_MAX=99          # highest `-<k>` suffix a path may reach before giving up

mode=${1:-}
want=${2:-}

case $mode in
	next-free|exclusive) ;;
	*) echo "CLAIM-FAILED: mode must be next-free or exclusive, not '${mode}'" >&2; exit 2 ;;
esac

if [ -z "$want" ]; then
	echo "CLAIM-FAILED: no path given" >&2
	exit 2
fi

dir=$(dirname -- "$want")
mkdir -p -- "$dir" || { echo "CLAIM-FAILED: cannot create $dir" >&2; exit 2; }

if [ "$mode" = exclusive ]; then
	pid=${3:-}
	case $pid in
		"" ) echo "CLAIM-FAILED: exclusive needs the session's pid" >&2; exit 2 ;;
		*[!0-9]* ) echo "CLAIM-FAILED: pid '$pid' is not a number" >&2; exit 2 ;;
	esac

	set -C
	# stderr is redirected first, so the shell's own noclobber complaint about
	# the failing redirection that follows it is swallowed rather than printed.
	if : 2>/dev/null > "$want"; then
		printf 'pid=%s\nclaimed=%s\nhost=%s\n' \
			"$pid" "$(date +%s)" "$(hostname)" >> "$want"
		echo "$want"
		exit 0
	fi

	held=$(grep -m1 '^pid=' -- "$want" 2>/dev/null)
	held=${held#pid=}
	since=$(grep -m1 '^claimed=' -- "$want" 2>/dev/null)
	since=${since#claimed=}
	# Alive is not enough: a pid is reused, so the holder counts as live only
	# while the process wearing its number is still an agent.
	if [ -n "$held" ] && [ "$(ps -o comm= -p "$held" 2>/dev/null)" = claude ]; then
		state=live
	else
		state=stale
	fi
	echo "HELD: $want pid=${held:-unknown} claimed=${since:-unknown} $state" >&2
	exit 3
fi

base=$(basename -- "$want")
case $base in
	*.*) stem=${base%.*}; ext=.${base##*.} ;;
	*)   stem=$base;      ext= ;;
esac

set -C
for k in $(seq 1 "$SUFFIX_MAX"); do
	if [ "$k" -eq 1 ]; then
		try=$dir/$stem$ext
	else
		try=$dir/$stem-$k$ext
	fi
	# stderr is redirected first, so the shell's own noclobber complaint about
	# the failing redirection that follows it is swallowed rather than printed.
	if : 2>/dev/null > "$try"; then
		echo "$try"
		exit 0
	fi
done

echo "CLAIM-FAILED: $want and every name beside it up to -$SUFFIX_MAX are taken" >&2
exit 2
