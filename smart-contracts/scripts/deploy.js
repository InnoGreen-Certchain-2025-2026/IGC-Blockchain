const hre = require('hardhat');
const fs = require('fs');

async function main() {
  console.log('🚀 Deploying CertificateRegistry Contract to Besu Network...\n');

  // Cấu hình
  const ISSUER_NAME = 'Trường Đại học Công nghiệp thành phố Hồ Chí Minh'; // Tên trường/đơn vị cấp

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log('📋 Deployment Information:');
  console.log('  Deployer Address:', deployer.address);

  // Check balance
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log('  Account Balance:', hre.ethers.formatEther(balance), 'ETH');

  // Get network info
  const network = await hre.ethers.provider.getNetwork();
  console.log('  Network:', network.name);
  console.log('  Chain ID:', network.chainId.toString());

  // Get current block
  const blockNumber = await hre.ethers.provider.getBlockNumber();
  console.log('  Current Block:', blockNumber);
  console.log('');

  // Deploy CertificateRegistry
  console.log('📝 Deploying CertificateRegistry contract...');
  console.log('  Issuer Name:', ISSUER_NAME);
  console.log('');

  const CertificateRegistry = await hre.ethers.getContractFactory(
    'CertificateRegistry'
  );

  const gasPrice = hre.ethers.parseUnits('1', 'gwei');

  const certificateRegistry = await CertificateRegistry.deploy(ISSUER_NAME, {
    gasPrice: gasPrice,
  });

  await certificateRegistry.waitForDeployment();

  const contractAddress = await certificateRegistry.getAddress();
  console.log('✅ CertificateRegistry deployed successfully!');
  console.log('  Contract Address:', contractAddress);

  // Verify deployment
  const deployedIssuerName = await certificateRegistry.issuerName();
  const deployedAdmin = await certificateRegistry.admin();
  const totalCerts = await certificateRegistry.totalCertificates();

  console.log('\n📊 Contract Verification:');
  console.log('  Issuer Name:', deployedIssuerName);
  console.log('  Admin Address:', deployedAdmin);
  console.log('  Total Certificates:', totalCerts.toString());

  // Get deployment transaction details
  const deploymentTx = certificateRegistry.deploymentTransaction();
  const receipt = await deploymentTx.wait();

  console.log('\n🔗 Deployment Transaction:');
  console.log('  Transaction Hash:', deploymentTx.hash);
  console.log('  Block Number:', receipt.blockNumber);
  console.log('  Gas Used:', receipt.gasUsed.toString());
  console.log(
    '  Gas Price:',
    hre.ethers.formatUnits(deploymentTx.gasPrice, 'gwei'),
    'Gwei'
  );
  console.log('  Status:', receipt.status === 1 ? '✅ Success' : '❌ Failed');

  // Save deployment info
  const deployment = {
    contractName: 'CertificateRegistry',
    contractAddress: contractAddress,
    network: network.name,
    chainId: network.chainId.toString(),
    deployer: deployer.address,
    issuerName: ISSUER_NAME,
    admin: deployedAdmin,
    blockNumber: receipt.blockNumber,
    transactionHash: deploymentTx.hash,
    gasUsed: receipt.gasUsed.toString(),
    gasPrice: deploymentTx.gasPrice.toString(),
    timestamp: new Date().toISOString(),
  };

  console.log('\n📄 Deployment Summary:');
  console.log(JSON.stringify(deployment, null, 2));

  // Save to file
  const deploymentsFile = 'certificate-deployments.json';
  let deployments = [];

  if (fs.existsSync(deploymentsFile)) {
    deployments = JSON.parse(fs.readFileSync(deploymentsFile, 'utf8'));
  }

  deployments.push(deployment);
  fs.writeFileSync(deploymentsFile, JSON.stringify(deployments, null, 2));

  console.log(`\n💾 Deployment info saved to ${deploymentsFile}`);

  // Save contract ABI
  const artifact = await hre.artifacts.readArtifact('CertificateRegistry');
  const contractInfo = {
    address: contractAddress,
    abi: artifact.abi,
    issuerName: ISSUER_NAME,
    deployedAt: new Date().toISOString(),
  };

  fs.writeFileSync(
    'certificate-contract.json',
    JSON.stringify(contractInfo, null, 2)
  );

  console.log('💾 Contract ABI saved to certificate-contract.json');

  console.log('\n🎉 Deployment completed successfully!');
  console.log('\n📋 Next Steps:');
  console.log('  1. Update backend application.yml with contract address:');
  console.log(`     blockchain.contracts.certificate-registry: "${contractAddress}"`);
  console.log('  2. Copy certificate-contract.json to backend/src/main/resources/');
  console.log('  3. Restart backend application');
  console.log('');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ Deployment failed:', error);
    process.exit(1);
  });