#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 Besu Network Status"
echo "======================"
echo ""

# Function: Extract result hex value from JSON
extract_hex() {
    echo "$1" | grep -o '"result":"0x[0-9a-fA-F]*"' | sed 's/"result":"//' | sed 's/"//'
}

# Function: Convert hex to decimal
hex_to_dec() {
    printf "%d" "$1" 2>/dev/null
}

# Function to check node
check_node() {
    local name=$1
    local port=$2

    response=$(curl -s -X POST \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        http://localhost:$port)

    if [ -n "$response" ]; then
        hex_block=$(extract_hex "$response")

        if [ -n "$hex_block" ]; then
            block=$(hex_to_dec "$hex_block")
            echo -e "${GREEN}✓${NC} $name (Port $port) - Block: $block"
        else
            echo -e "${YELLOW}!${NC} $name (Port $port) - Cannot parse block"
        fi
    else
        echo -e "${RED}✗${NC} $name (Port $port) - Unreachable"
    fi
}

# Check all nodes
echo "📦 Nodes Status:"
check_node "Node-1 (Validator)" 8545
check_node "Node-2 (Validator)" 8546
check_node "Node-3 (Validator)" 8547
check_node "Node-4 (RPC Node)" 8548

echo ""
echo "🔗 Network Info:"

peer_response=$(curl -s -X POST \
    --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' \
    http://localhost:8545)

# Count number of peers by counting "enode"
peers=$(echo "$peer_response" | grep -o '"enode"' | wc -l)

echo "  Connected Peers: $peers"

# Check block production
block1_hex=$(extract_hex "$(curl -s -X POST \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545)")

block1=$(hex_to_dec "$block1_hex")

sleep 5

block2_hex=$(extract_hex "$(curl -s -X POST \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    http://localhost:8545)")

block2=$(hex_to_dec "$block2_hex")

if [ "$block2" -gt "$block1" ]; then
    echo -e "  Block Production: ${GREEN}Active${NC} (+$((block2-block1)) blocks in 5s)"
else
    echo -e "  Block Production: ${RED}Stopped${NC}"
fi

echo ""
echo "🐳 Docker Containers:"
docker compose ps --format "table {{.Service}}\t{{.Status}}"
