# Deploy IGC Blockchain On Dokploy

This repository should be deployed to Dokploy as a `Docker Compose` application.

Use [`docker-compose.dokploy.yml`](./docker-compose.dokploy.yml), not the local [`docker-compose.yml`](./docker-compose.yml).

## 1. Before deploy

Prepare these values in Dokploy:

```env
BESU_IMAGE=hyperledger/besu:latest
NETWORK_ID=1337
MIN_GAS_PRICE=0
```

You can copy them from [`.env.dokploy.example`](./.env.dokploy.example).

## 2. Create the Dokploy app

1. Create a new application.
2. Choose `Docker Compose`.
3. Connect this Git repository.
4. Set compose path to `docker-compose.dokploy.yml`.
5. Add the environment variables from `.env.dokploy.example`.
6. Deploy.

## 3. What happens on first deploy

- `network-init` generates the QBFT network config inside Docker volumes.
- `node-1` to `node-4` start from that generated config.
- Chain data is stored in named Docker volumes, so redeploy does not reset the blockchain.

## 4. Ports

The compose file exposes:

- `8545` -> node-1 RPC
- `8546` -> node-2 RPC
- `8547` -> node-3 RPC
- `8548` -> node-4 RPC
- `30303` to `30306` -> P2P ports

Recommended:

- expose `8548` publicly only if your backend needs external RPC access
- keep validator/admin RPC ports private when possible

## 5. After deploy

Check the application logs:

- `network-init` should finish successfully once
- `node-1` to `node-4` should stay running

Node-4 is the main backend RPC endpoint:

```text
http://<your-server-or-domain>:8548
```

## 6. Smart contract deploy

This compose deployment only starts the Besu network.

Contract deployment is still a separate step. Run it after node-4 is reachable:

```bash
cd smart-contracts
npm install
npx hardhat compile
npx hardhat run scripts/deploy.js --network besu
```

If you deploy from another machine, change the RPC URL in [`smart-contracts/hardhat.config.js`](./smart-contracts/hardhat.config.js) from `http://localhost:8548` to your server endpoint.

## 7. Resetting the blockchain

Do this only if you intentionally want a brand new chain.

Reset requires deleting the Dokploy/Docker volumes created by this stack:

- `besu-network-config`
- `besu-node-1-data`
- `besu-node-2-data`
- `besu-node-3-data`
- `besu-node-4-data`

If those volumes remain, redeploy will keep the same chain state.

## 8. Operational notes

- Do not expose validator/admin RPCs to the public internet unless you really need them.
- Do not click any Dokploy option that recreates or clears volumes unless you want a full reset.
- If the chain was reset, redeploy the smart contracts and update the backend contract address.
