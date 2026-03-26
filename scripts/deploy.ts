import { ethers } from "hardhat";

async function main() {

  const [deployer] = await ethers.getSigners();

  if (!deployer) {
    throw new Error("No deployer found. Check hardhat.config.ts accounts.");
  }

  console.log("--------------------------------------------------");
  console.log("Deploying Coffhee Finance Contracts");
  console.log("Network:", (await ethers.provider.getNetwork()).name);
  console.log("Deployer:", deployer.address);
  console.log("--------------------------------------------------");

  /* ========================================================= */
  /*                1️⃣ Deploy ERC3475 Bond Contract            */
  /* ========================================================= */

  console.log("Deploying FrappeBond...");

  const FrappeBondFactory = await ethers.getContractFactory("FrappeBond", deployer);
  const frappeBond = await FrappeBondFactory.deploy();

  await frappeBond.waitForDeployment();

  const frappeBondAddress = await frappeBond.getAddress();

  console.log("✅ FrappeBond deployed:", frappeBondAddress);

  /* ========================================================= */
  /*              2️⃣ Deploy Encrypted ERC1155 Wrapper          */
  /* ========================================================= */

  console.log("Deploying Frappucino (Encrypted ERC1155)...");

  const FrappucinoFactory = await ethers.getContractFactory("Frappucino", deployer);
  const frappucino = await FrappucinoFactory.deploy(frappeBondAddress);

  await frappucino.waitForDeployment();

  const frappucinoAddress = await frappucino.getAddress();

  console.log("✅ Frappucino deployed:", frappucinoAddress);

  /* ========================================================= */
  /*           3️⃣ Deploy Non-Encrypted ERC1155 Wrapper         */
  /* ========================================================= */

  console.log("Deploying Cappucino (ERC1155 Wrapper)...");

  const CappucinoFactory = await ethers.getContractFactory("Cappucino", deployer);
  const cappucino = await CappucinoFactory.deploy(frappeBondAddress);

  await cappucino.waitForDeployment();

  const cappucinoAddress = await cappucino.getAddress();

  console.log("✅ Cappucino deployed:", cappucinoAddress);

  /* ========================================================= */
  /*                  4️⃣ Deploy Marketplace                    */
  /* ========================================================= */

  console.log("Deploying CoffheeMarketplace...");

  const MarketplaceFactory = await ethers.getContractFactory("CoffheeMarketplace", deployer);
  const marketplace = await MarketplaceFactory.deploy();

  await marketplace.waitForDeployment();

  const marketplaceAddress = await marketplace.getAddress();

  console.log("✅ CoffheeMarketplace deployed:", marketplaceAddress);

  console.log("--------------------------------------------------");
  console.log("🎉 Deployment Complete");
  console.log("--------------------------------------------------");

  console.log("FrappeBond:", frappeBondAddress);
  console.log("Frappucino:", frappucinoAddress);
  console.log("Cappucino:", cappucinoAddress);
  console.log("Marketplace:", marketplaceAddress);

  console.log("--------------------------------------------------");
}

main().catch((error) => {
  console.error("❌ Deployment failed:");
  console.error(error);
  process.exitCode = 1;
});