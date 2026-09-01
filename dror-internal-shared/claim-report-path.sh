#!/usr/bin/env bash
# Claims a caller-named report path, exactly, before anything is written to it.
#
# Takes the path a caller named and prints the path actually claimed: that one
# where it was free, or the same name with `-2`, `-3` and so on before the
# extension where it was already another writer's. The claim is an exclusive
# create (`set -C`), so of two writers reaching for one path exactly one wins —
# decided by the kernel, not by a clock reading or a look-then-write.
#
# It claims by creating the file empty. The caller then writes its report over
# that file, and names on screen the path this printed when it differs from the
# path it asked for.
#
# This file **enforces** the claim, so it is the one place the suffix bound is
# spelled (the repo's tunable rule). REPORT-STORE.md owns when a run claims a
# path at all, and points here; neither restates the other.
#
# It exits 0 when it claims a path and 2 when it cannot. Unlike the facts
# stamp, nothing injects this at load time, so a non-zero exit aborts no skill —
# and a run that writes its findings nowhere is an error, not a miss.

set -u

SUFFIX_MAX=99          # how many `-<k>` names one path may grow before giving up

want=${1:-}

if [ -z "$want" ]; then
	echo "CLAIM-FAILED: no path given" >&2
	exit 2
fi

dir=$(dirname -- "$want")
mkdir -p -- "$dir" || { echo "CLAIM-FAILED: cannot create $dir" >&2; exit 2; }

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

echo "CLAIM-FAILED: $want and $SUFFIX_MAX names beside it are taken" >&2
exit 2
