const hre = require('hardhat');
const fs = require('fs');

async function main() {
  console.log('🔗 Interacting with SimpleStorage Contract\n');

  // Load deployment info
  const deploymentsFile = 'deployments.json';
  if (!fs.existsSync(deploymentsFile)) {
    console.error('❌ No deployments found. Please deploy the contract first.');
    process.exit(1);
  }
  const gasPrice = hre.ethers.parseUnits('1', 'gwei');

  const deployments = JSON.parse(fs.readFileSync(deploymentsFile, 'utf8'));
  const latestDeployment = deployments[deployments.length - 1];
  const contractAddress = latestDeployment.contractAddress;

  console.log('Contract Address:', contractAddress);
  console.log('Network:', hre.network.name);
  console.log('');

  // Get contract instance
  const SimpleStorage = await hre.ethers.getContractFactory('SimpleStorage');
  const simpleStorage = SimpleStorage.attach(contractAddress);

  // Get signer
  const [signer] = await hre.ethers.getSigners();
  console.log('Interacting as:', signer.address);
  console.log('');

  // Read current value
  console.log('📖 Reading current value...');
  const currentValue = await simpleStorage.get();
  console.log('Current stored value:', currentValue.toString());
  console.log('');
  const txOptions = { gasPrice };
  // Update value
  console.log('✏️  Setting new value to 123...');
  const setTx = await simpleStorage.set(123, txOptions);
  console.log('Transaction sent:', setTx.hash);
  const setReceipt = await setTx.wait();
  console.log('Transaction confirmed in block:', setReceipt.blockNumber);
  console.log('Gas used:', setReceipt.gasUsed.toString());
  console.log('Updated value:', (await simpleStorage.get()).toString());
  console.log('');

  // Increment value
  console.log('➕ Incrementing value...');
  const incTx = await simpleStorage.increment(txOptions);
  console.log('Transaction sent:', incTx.hash);
  await incTx.wait();
  console.log(
    'New value after increment:',
    (await simpleStorage.get()).toString()
  );
  console.log('');

  // Decrement value
  console.log('➖ Decrementing value...');
  const decTx = await simpleStorage.decrement(txOptions);
  await decTx.wait();
  console.log(
    'New value after decrement:',
    (await simpleStorage.get()).toString()
  );
  console.log('');

  // Query events
  console.log('📜 Recent DataStored events:');
  const filter = simpleStorage.filters.DataStored();
  const events = await simpleStorage.queryFilter(filter, -20);

  if (events.length === 0) {
    console.log('  No events found');
  } else {
    events.forEach((event, index) => {
      console.log(`  Event ${index + 1}:`);
      console.log(`    Value: ${event.args.newValue}`);
      console.log(`    Setter: ${event.args.setter}`);
      console.log(
        `    Timestamp: ${new Date(
          Number(event.args.timestamp) * 1000
        ).toISOString()}`
      );
      console.log(`    Block: ${event.blockNumber}`);
      console.log(`    Tx Hash: ${event.transactionHash}`);
      console.log('');
    });
  }

  // Get contract owner
  console.log('👤 Contract Information:');
  console.log('  Owner:', await simpleStorage.owner(txOptions));
  console.log('  Current Value:', (await simpleStorage.get()).toString());

  console.log('\n✅ Interaction completed successfully!');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('❌ Interaction failed:', error);
    process.exit(1);
  });
