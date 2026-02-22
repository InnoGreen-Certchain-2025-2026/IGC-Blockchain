# IGC Blockchain

Private blockchain network using Hyperledger Besu (QBFT) with 4 nodes, plus a `smart-contracts` workspace for deploying and testing contracts.

## Project Structure

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
|   `-- test/
|-- docker-compose.yml
`-- start.bat
```

## Requirements

- Docker Desktop (Docker Compose enabled)
- Windows PowerShell / CMD
- Git Bash or WSL (required for shell scripts in `scripts/`)
- Node.js + npm (for `smart-contracts/`)

## Quick Start (Windows)

1. Open terminal in project root.
2. Configure environment (already has default values):

```env
BESU_IMAGE=hyperledger/besu:latest
NETWORK_ID=1337
MIN_GAS_PRICE=0
```

3. Run:

```bat
start.bat
```

4. Use menu:
- `1` Reset network (regenerate genesis and node keys)
- `2` Start nodes
- `3` Stop nodes
- `4` Check network status

## CLI Usage (without menu)

Generate network files:

```bash
bash scripts/generate-network.sh
```

Start nodes:

```bash
docker compose up -d
```

Check status:

```bash
bash scripts/network-status.sh
```

Stop nodes:

```bash
docker compose down
```

## Node Endpoints

- Node 1 (Validator): `http://localhost:8545`
- Node 2 (Validator): `http://localhost:8546`
- Node 3 (Validator): `http://localhost:8547`
- Node 4 (RPC Node): `http://localhost:8548`

P2P ports: `30303`, `30304`, `30305`, `30306`

## Smart Contracts

`smart-contracts/` contains Hardhat setup and contract sources.

Install deps:

```bash
cd smart-contracts
npm install
```

Run tests:

```bash
npx hardhat test
```

Compile:

```bash
npx hardhat compile
```

Files included:
- `contracts/SimpleStorage.sol`
- `contracts/CertificateRegistry.sol`
- `test/CertificateRegistry.test.js`
- `scripts/deploy.js`
- `scripts/interact.js`

## Notes

- Folder `nodes/` is generated when running reset/generate scripts.
- `scripts/network-status.sh` checks block height and peer connectivity.
- If Bash is missing, options `1` and `4` in `start.bat` will not run.

## Troubleshooting

- Docker not running: start Docker Desktop, then retry.
- `bash` not found: install Git Bash or use WSL.
- Port conflict (`8545-8548` / `30303-30306`): stop conflicting services or adjust port mapping in `docker-compose.yml`.
