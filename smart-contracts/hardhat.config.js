require('@nomicfoundation/hardhat-toolbox');

module.exports = {
  solidity: {
    version: '0.8.28', // Use this or your project's Solidity version configured in Hardhat
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    besu: {
      url: 'http://localhost:8548', // Node-4 RPC endpoint
      chainId: 1337,
      accounts: [
        '0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63',
      ],
      gasPrice: 0,
      gas: 10000000,
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
};
