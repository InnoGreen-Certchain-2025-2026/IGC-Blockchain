require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

const rpcUrl = process.env.BESU_RPC_URL || "http://localhost:8548";
const chainId = Number(process.env.BESU_CHAIN_ID || 1337);
const deployerPrivateKey =
  process.env.DEPLOYER_PRIVATE_KEY ||
  "0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63";
const gasPrice = Number(process.env.BESU_GAS_PRICE || 0);
const headerSecret = process.env.X_HEADER_SECRET;

module.exports = {
  solidity: {
    version: "0.8.28", // Use this or your project's Solidity version configured in Hardhat
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    besu: {
      url: rpcUrl,
      chainId,
      accounts: [deployerPrivateKey],
      httpHeaders: headerSecret
        ? {
            "X-HEADER-SECRET": headerSecret,
          }
        : {},
      gasPrice,
      gas: 10000000,
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
