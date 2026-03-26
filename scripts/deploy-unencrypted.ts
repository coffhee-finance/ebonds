import { ethers } from "hardhat";

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying with:", deployer.address);

  /*
  ------------------------
  Deploy Cappucino
  ------------------------
  */

  console.log("☕ Deploying Cappucino Bond contract...");

  const CappucinoFactory = await ethers.getContractFactory("Cappucino", deployer);

  const cappucino = await CappucinoFactory.deploy(
    "https://coffhee.finance/api/bonds/{id}.json"
  );

  await cappucino.waitForDeployment();

  const cappucinoAddress = await cappucino.getAddress();

  console.log("✅ Cappucino deployed:", cappucinoAddress);

  /*
  ------------------------
  Deploy Marketplace
  ------------------------
  */

  console.log("🏪 Deploying CoffheeMarketplace...");

  const MarketplaceFactory = await ethers.getContractFactory(
    "CoffheeMarketplace",
    deployer
  );

  const marketplace = await MarketplaceFactory.deploy(
    cappucinoAddress   // must be address
  );

  await marketplace.waitForDeployment();

  const marketplaceAddress = await marketplace.getAddress();

  console.log("✅ Marketplace deployed:", marketplaceAddress);

  console.log("🎉 Deployment Complete");
}

main().catch((error) => {
  console.error("❌ Deployment failed:");
  console.error(error);
  process.exit(1);
});