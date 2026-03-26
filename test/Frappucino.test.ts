import { expect } from "chai";
import { ethers } from "hardhat";
import { Frappucino, FrappeBond } from "../typechain-types";

describe("Frappucino", function () {

  let frapp: Frappucino;
  let bond: FrappeBond;
  let owner: any;

  beforeEach(async () => {

    [owner] = await ethers.getSigners();

    const Bond = await ethers.getContractFactory("FrappeBond");
    bond = await Bond.deploy();
    await bond.waitForDeployment();

    const Frapp = await ethers.getContractFactory("Frappucino");
    frapp = await Frapp.deploy(await bond.getAddress());
    await frapp.waitForDeployment();
  });

  it("Deploys correctly", async () => {
    expect(await frapp.bondContract())
      .to.equal(await bond.getAddress());
  });

  it("Confidential transfer reverts for zero address", async () => {
    await expect(
      frapp.confidentialTransfer(
        ethers.ZeroAddress,
        0,
        1
      )
    ).to.be.revertedWith("Invalid recipient");
  });

});