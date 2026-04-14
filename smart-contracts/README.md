# Smart Contracts Deployment (Besu)

## 1) Configure environment for server deployment

Copy `.env.example` to `.env` and set values:

```powershell
Copy-Item .env.example .env
```

Required variables:

- `BESU_RPC_URL`: RPC URL of the Besu node running on server
- `BESU_CHAIN_ID`: chain id (default `1337`)
- `DEPLOYER_PRIVATE_KEY`: private key used to deploy contract

Optional:

- `BESU_GAS_PRICE`: gas price in wei (private network can use `0`)
- `BACKEND_RESOURCES_DIR`: backend resource directory for auto-copy

## 2) Deploy contract

```powershell
npm install
npm run compile
npm run deploy:besu
```

Output files after deploy:

- `certificate-contract.json`: contract address + ABI
- `backend-blockchain-config.json`: backend-friendly network/contract config
- `certificate-deployments.json`: deployment history

If `BACKEND_RESOURCES_DIR` is set, deploy script auto-copies:

- `certificate-contract.json` -> `<BACKEND_RESOURCES_DIR>/certificate-contract.json`
- `backend-blockchain-config.json` -> `<BACKEND_RESOURCES_DIR>/blockchain-config.json`

## 3) Backend integration

Backend should read these files from resource folder:

- `certificate-contract.json`
- `blockchain-config.json`

Then restart backend service.
