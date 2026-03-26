import { expect } from "chai";
import { ethers } from "hardhat";
import { CoffheeMarketplace, Mock1155 } from "../typechain-types";

describe("CoffheeMarketplace", function () {

  let market: CoffheeMarketplace;
  let token: Mock1155;
  let owner: any;
  let buyer: any;

  beforeEach(async () => {

    [owner, buyer] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Mock1155");
    token = await Token.deploy();
    await token.waitForDeployment();

    await token.mint(owner.address, 1, 100);

    const Market = await ethers.getContractFactory("CoffheeMarketplace");
    market = await Market.deploy();
    await market.waitForDeployment();

    await token.setApprovalForAll(await market.getAddress(), true);
  });

  it("Only owner can list", async () => {
    await expect(
      market.connect(buyer).list(
        await token.getAddress(), 1, 10, 1
      )
    ).to.be.reverted;
  });

  it("Lists correctly", async () => {
    await expect(
      market.list(await token.getAddress(), 1, 10, 1)
    ).to.emit(market, "Listed");
  });

  it("Buys correctly", async () => {
    await market.list(await token.getAddress(), 1, 10, 1);

    await expect(
      market.connect(buyer).buy(0, 5, { value: 5 })
    ).to.emit(market, "Purchased");

    expect(await token.balanceOf(buyer.address, 1)).to.equal(5);
  });

  it("Rejects incorrect ETH", async () => {
    await market.list(await token.getAddress(), 1, 10, 1);

    await expect(
      market.connect(buyer).buy(0, 5, { value: 4 })
    ).to.be.revertedWith("Incorrect ETH sent");
  });

  it("Cancels listing", async () => {
    await market.list(await token.getAddress(), 1, 10, 1);

    await expect(market.cancel(0))
      .to.emit(market, "Cancelled");
  });

});