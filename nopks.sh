#!/bin/bash

STORAGE_DIR="/home/matt/"
mkdir -p "$STORAGE_DIR/allkeys"

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$3" = "" ]; then
	exit 1
fi

if [ "`cat "$STORAGE_DIR"/pgp-2.txt | grep $3`" != "" ]; then
	exit 1
elif [ "`cat "$STORAGE_DIR"/missing.txt | grep $3`" != "" ]; then
	exit 1
fi

if [ -f "$STORAGE_DIR/allkeys/$3" ]; then
	cat "$STORAGE_DIR/allkeys/$3"
	exit 0
fi

trap "echo NOKILL" SIGINT SIGTERM

"$SCRIPTDIR"/gpg-locker.sh --export "$3" >"$STORAGE_DIR/allkeys/$3" 2>/tmp/nopks-err.txt

if [ "$(cat /tmp/nopks-err.txt)" != "" ]; then
	OUTPUT="$($SCRIPTDIR/gpg-locker.sh --recv-keys "$3" 2>&1 | tail -n1)"
	if [ "$OUTPUT" = "gpg:     skipped PGP-2 keys: 1" ]; then
		echo "$3" >> "$STORAGE_DIR/pgp-2.txt"
		rm "$STORAGE_DIR/allkeys/$3"
		exit 1
	elif [ "$OUTPUT" = "gpg: keyserver receive failed: No data" ]; then
		echo "$3" >> "$STORAGE_DIR/missing.txt"
		rm "$STORAGE_DIR/allkeys/$3"
		exit 1
	fi

	$SCRIPTDIR/gpg-locker.sh --export $3 >"$STORAGE_DIR/allkeys/$3" 2>/tmp/nopks-err.txt
	if [ "$(cat /tmp/nopks-err.txt)" != "" ]; then
		rm "$STORAGE_DIR/allkeys/$3"
		exit 1
	else
		cat "$STORAGE_DIR/allkeys/$3"
	fi
else
	cat "$STORAGE_DIR/allkeys/$3"
fi
