#!/bin/sh
set -eu

NETWORK_ROOT="${NETWORK_ROOT:-/network}"
CONFIG_FILE="${CONFIG_FILE:-/config/qbftConfigFile.json}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Missing Besu config: $CONFIG_FILE" >&2
  exit 1
fi

mkdir -p "$NETWORK_ROOT"

if [ -f "$NETWORK_ROOT/networkFiles/genesis.json" ]; then
  echo "Besu network config already exists in $NETWORK_ROOT. Reusing it."
else
  echo "Generating Besu QBFT network config into $NETWORK_ROOT"
  rm -rf "$NETWORK_ROOT/networkFiles"
  besu operator generate-blockchain-config \
    --config-file="$CONFIG_FILE" \
    --to="$NETWORK_ROOT/networkFiles" \
    --private-key-file-name=key
fi

KEYS_DIR="$NETWORK_ROOT/networkFiles/keys"
if [ ! -d "$KEYS_DIR" ]; then
  echo "Missing generated keys directory: $KEYS_DIR" >&2
  exit 1
fi

BOOTNODES=""
NODE_INDEX=1

for KEY_DIR in "$KEYS_DIR"/*; do
  [ -d "$KEY_DIR" ] || continue

  ADDRESS="$(basename "$KEY_DIR")"
  NODE_DIR="$NETWORK_ROOT/node-$NODE_INDEX/config"
  mkdir -p "$NODE_DIR"

  cp "$KEY_DIR/key" "$NODE_DIR/key"
  cp "$KEY_DIR/key.pub" "$NODE_DIR/key.pub"
  printf '%s\n' "$ADDRESS" > "$NODE_DIR/address"
  chmod 600 "$NODE_DIR/key"

  PUBKEY="$(sed 's/^0x//' "$NODE_DIR/key.pub")"
  NODE_IP="172.25.0.$((NODE_INDEX + 1))"
  ENODE="enode://${PUBKEY}@${NODE_IP}:30303"
  if [ -z "$BOOTNODES" ]; then
    BOOTNODES="$ENODE"
  else
    BOOTNODES="$BOOTNODES,$ENODE"
  fi

  NODE_INDEX=$((NODE_INDEX + 1))
done

printf '%s\n' "$BOOTNODES" > "$NETWORK_ROOT/bootnodes.txt"
echo "Prepared node config for $((NODE_INDEX - 1)) nodes."
