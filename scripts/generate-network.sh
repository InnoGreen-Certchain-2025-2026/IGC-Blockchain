#!/bin/bash

echo "🔧 Generating Besu QBFT Network Configuration..."
echo "================================================"

# Fix Git Bash Docker path issue
export MSYS_NO_PATHCONV=1

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if config file exists
if [ ! -f "config/qbftConfigFile.json" ]; then
    echo -e "${RED}❌ Error: config/qbftConfigFile.json not found!${NC}"
    exit 1
fi

# Clean previous network files
echo -e "${YELLOW}🧹 Cleaning previous network files...${NC}"
rm -rf nodes/networkFiles
rm -rf nodes/node-*/data

# Generate network configuration
echo -e "${YELLOW}⚙️  Generating network configuration...${NC}"

docker run --rm \
  -v "$PWD/config:/config" \
  -v "$PWD/nodes:/nodes" \
  hyperledger/besu:latest \
  operator generate-blockchain-config \
  --config-file=/config/qbftConfigFile.json \
  --to=/nodes/networkFiles \
  --private-key-file-name=key

# Check if generation was successful
if [ ! -f "nodes/networkFiles/genesis.json" ]; then
    echo -e "${RED}❌ Network generation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Network configuration generated successfully!${NC}"

# Create node data directories
echo -e "${YELLOW}📁 Creating node directories...${NC}"

for i in 1 2 3 4
do
  mkdir -p nodes/node-$i/data
done

# Copy keys to node directories
echo -e "${YELLOW}🔑 Distributing node keys...${NC}"

ADDRESSES=($(ls nodes/networkFiles/keys/))

for i in 1 2 3 4
do
  NODE_INDEX=$((i-1))
  NODE_ADDRESS=${ADDRESSES[$NODE_INDEX]}

  echo -e "  ${GREEN}✓${NC} Node-$i: $NODE_ADDRESS"

  cp nodes/networkFiles/keys/$NODE_ADDRESS/key nodes/node-$i/data/
  cp nodes/networkFiles/keys/$NODE_ADDRESS/key.pub nodes/node-$i/data/
  echo $NODE_ADDRESS > nodes/node-$i/data/address
done

# Secure key files
echo -e "${YELLOW}🔒 Securing private keys...${NC}"
chmod 600 nodes/node-*/data/key 2>/dev/null
chmod 700 nodes/node-*/data 2>/dev/null

echo ""
echo -e "${GREEN}✨ Network setup complete!${NC}"
echo ""
echo "📋 Generated Files:"
echo "  - Genesis file: nodes/networkFiles/genesis.json"
echo "  - Node keys: nodes/node-{1..4}/data/key"
echo ""
echo "Next steps:"
echo "  Review the genesis file: cat nodes/networkFiles/genesis.json"
echo ""
