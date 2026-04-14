#!/bin/sh
set -eu

BOOTNODES_FILE="${BOOTNODES_FILE:-/network/bootnodes.txt}"

for _ in $(seq 1 60); do
  if [ -f "$BOOTNODES_FILE" ]; then
    break
  fi
  sleep 1
done

if [ ! -f "$BOOTNODES_FILE" ]; then
  echo "Missing bootnodes file: $BOOTNODES_FILE" >&2
  exit 1
fi

BOOTNODES="$(tr -d '\n' < "$BOOTNODES_FILE")"

if [ -z "$BOOTNODES" ]; then
  echo "Bootnodes list is empty." >&2
  exit 1
fi

exec besu "$@" "--bootnodes=$BOOTNODES"
