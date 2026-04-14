# IGC Blockchain

Consolidated project documentation (no separate `docs/` folder).

## 1. What this project does

This is a local private blockchain network built with Hyperledger Besu (QBFT), running 4 nodes.

Dokploy deployment guide: [`DOKPLOY.md`](./DOKPLOY.md)

Goals:

- Provide an internal blockchain environment for development/testing
- Deploy and use business smart contracts
- Allow backend applications to interact with the chain via RPC

## 2. Project structure

```text
IGC-Blockchain/
|-- config/
|   `-- qbftConfigFile.json
|-- scripts/
|   |-- generate-network.sh
|   `-- network-status.sh
|-- smart-contracts/
|   |-- contracts/
|   |-- scripts/
|   |-- test/
|   |-- hardhat.config.js
|   `-- package.json
|-- docker-compose.yml
|-- start.bat
`-- .env
```

## 3. Key jargon

- `Node`: one blockchain instance participating in the network.
- `Besu`: Ethereum client used to run nodes.
- `Private chain`: internal blockchain network.
- `Permissioned`: only approved nodes/accounts can participate in specific actions.
- `RPC`: API endpoint for external apps to talk to a node.
- `JSON-RPC`: JSON-based request/response protocol.
- `P2P`: node-to-node communication layer.
- `Transaction (tx)`: request to change on-chain state.
- `Block`: accepted batch of transactions.
- `Consensus`: mechanism used by validators to agree on blocks.
- `QBFT`: BFT consensus algorithm used for private Besu networks.
- `Validator`: node that votes/proposes blocks.
- `Genesis`: chain initialization configuration.
- `Chain ID`: chain identifier to prevent replay attacks across chains.
- `Gas`: unit of EVM computation cost.
- `ABI`: contract interface definition used by apps.

## 4. Ethereum basics in this project

This project runs a private Ethereum-compatible network, not Ethereum mainnet.

Core components:

- Accounts (EOA and contract accounts)
- Transactions
- Blocks
- State (balance, nonce, storage)
- EVM

Read vs write:

- `Read` (`eth_call`): no real transaction, no state change.
- `Write` (`eth_sendRawTransaction`): real transaction, goes through consensus, changes state.

## 5. What Besu does here

Besu acts as:

- EVM execution client
- P2P node
- State manager
- RPC server

Current network:

- node-1: validator + RPC (`8545`)
- node-2: validator + RPC (`8546`)
- node-3: validator + RPC (`8547`)
- node-4: RPC-facing (`8548`)

P2P ports:

- `30303`, `30304`, `30305`, `30306`

## 6. What smart contracts do in this project

There are 2 contracts in `smart-contracts/contracts/`:

- `SimpleStorage.sol`: demo contract for deploy/call flow testing.
- `CertificateRegistry.sol`: main business contract.

`CertificateRegistry` supports:

- issuing certificates (`issueCertificate`)
- verifying by ID/hash
- revoking/reactivating certificates
- admin and issuer management

Important behavior:

- A deployed contract is not a background process like a server.
- Deploy means writing contract code to blockchain state.
- Contract logic executes only when a call/transaction is sent.

## 7. Backend to blockchain flow

1. Backend signs the transaction (for write operations).
2. Backend sends RPC request to node-4 (`http://localhost:8548`).
3. Node-4 receives and propagates tx over P2P.
4. QBFT validators reach consensus.
5. Block is written and replicated across all 4 nodes.
6. Backend reads receipt/events.

## 8. Important config

### 8.1 `.env`

```env
BESU_IMAGE=hyperledger/besu:latest
NETWORK_ID=1337
MIN_GAS_PRICE=0
```

### 8.2 `config/qbftConfigFile.json`

Chain initialization highlights:

- `chainId: 1337`
- `qbft.blockperiodseconds: 2`
- `qbft.requesttimeoutseconds: 4`
- `nodes.count: 4`

### 8.3 `docker-compose.yml`

Defines the 4 Besu nodes, RPC/P2P ports, data paths, genesis file usage, and API groups.

## 9. Quick run with `start.bat`

Current menu:

1. `Full setup`  
install dependencies + generate network if missing + start nodes + deploy contract

2. `Generate NEW network + deploy contract (no docker compose up/down)`  
regenerate network files + deploy contract, without auto start/stop of Docker Compose

3. `Health status`  
check network health + contract deployment status

4. `Exit`

## 10. Manual commands

### 10.1 Network

```bash
bash scripts/generate-network.sh
docker compose up -d
bash scripts/network-status.sh
docker compose down
```

### 10.1.1 Dokploy

Use [`docker-compose.dokploy.yml`](./docker-compose.dokploy.yml) for Dokploy instead of the local [`docker-compose.yml`](./docker-compose.yml).

Why:

- the local compose file expects host-generated `nodes/` content
- `nodes/` is gitignored, so Dokploy won't receive that state from Git
- the Dokploy compose file generates network config inside Docker volumes on first deploy
- chain data is persisted in named volumes, so redeploys do not wipe the network

Dokploy notes:

- create a Docker Compose application from this repository
- set the compose path to `docker-compose.dokploy.yml`
- provide the same environment variables as [`.env.dokploy.example`](./.env.dokploy.example)
- expose only the ports you actually need publicly, especially `8548`
- do not use "reset volumes" unless you intentionally want a brand new chain

### 10.2 Smart contracts

```bash
cd smart-contracts
npm install
npx hardhat compile
npx hardhat test
npx hardhat run scripts/deploy.js --network besu
```

## 11. How to verify contract deployment

Method 1: use `start.bat` option `3` (Health status).

Method 2: manual RPC:

- read `contractAddress` from `smart-contracts/certificate-contract.json`
- call `eth_getCode` on node-4
- if result is not `0x`, contract exists on the current chain

## 12. When you must redeploy

You must redeploy if:

- network was reset
- node data was deleted
- you are on a new chain but still using an old contract address

You do not need to redeploy if:

- you only ran `docker compose down` then `up` and node data remained intact

## 13. Short FAQ

### Q: Nodes are running but contract shows NOT FOUND?
A: The address belongs to an old chain. Redeploy on the current chain.

### Q: Do smart contracts run like servers?
A: No. They are not background processes. They execute only on call/tx.

### Q: If Docker is stopped, is the contract lost?
A: Not if node data is preserved. It becomes temporarily unreachable.

### Q: Is running tests mandatory before deploy?
A: Not mandatory, but at least run `compile`.

## 14. Operational notes

- Do not commit real private keys.
- Restrict admin APIs in non-local environments.
- If health check shows `NOT FOUND` after reset, redeploy and update backend config.
- Use node-4 as the backend RPC entry point.
