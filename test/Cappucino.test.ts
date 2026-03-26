import { expect } from "chai";
import { ethers } from "hardhat";
import { Cappucino, MockERC3475 } from "../typechain-types";

describe("Cappucino", function () {

  let capp: Cappucino;
  let mock: MockERC3475;
  let owner: any;

  beforeEach(async () => {

    [owner] = await ethers.getSigners();

    const Mock = await ethers.getContractFactory("MockERC3475");
    mock = await Mock.deploy();
    await mock.waitForDeployment();

    const Capp = await ethers.getContractFactory("Cappucino");
    capp = await Capp.deploy(await mock.getAddress());
    await capp.waitForDeployment();
  });

  it("Wraps bond correctly", async () => {

    await mock.mint(owner.address, 100);

    await expect(
      capp.wrap(0, 0, 50)
    ).to.emit(capp, "BondWrapped");

    expect(await capp.balanceOf(owner.address, 0)).to.equal(1);
  });

  it("Unwrap burns and returns bond", async () => {

    await mock.mint(owner.address, 100);
    await capp.wrap(0, 0, 50);

    await expect(
      capp.unwrap(0)
    ).to.emit(capp, "BondUnwrapped");

    expect(await capp.balanceOf(owner.address, 0)).to.equal(0);
  });

  it("Reverts unwrap if not owner", async () => {
    await expect(capp.unwrap(999)).to.be.reverted;
  });

});