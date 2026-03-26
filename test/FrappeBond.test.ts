import { expect } from "chai";
import { ethers } from "hardhat";
import { FrappeBond } from "../typechain-types";

describe("FrappeBond", function () {

  let bond: FrappeBond;
  let owner: any;

  beforeEach(async () => {
    [owner] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("FrappeBond");
    bond = await Factory.deploy();
    await bond.waitForDeployment();
  });

  it("Operator approval works", async () => {
    await bond.setApprovalFor(owner.address, true);
    expect(
      await bond.isApprovedFor(owner.address, owner.address)
    ).to.equal(true);
  });

  it("Stores confidential data", async () => {

    await expect(
      bond.setConfidentialData(0, 0, "0x1234")
    ).to.be.reverted; // no balance
  });

});