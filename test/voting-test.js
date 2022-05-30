const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Voting = await ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    
    await voting.deployed();
    console.log(await voting.getOwner());
    expect(await voting.getOwner()).to.equal(voting.deployTransaction.from)
    await voting.addVoteRound()
    console.log(await voting.getVotes())
  });
});
