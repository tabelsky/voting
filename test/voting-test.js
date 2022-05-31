const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", function () {

let owner;
let user_1;
let voting;

beforeEach(async function() {
  [owner, user_1] = await ethers.getSigners()
  const Voting = await ethers.getContractFactory("Voting", owner);
  voting = await Voting.deploy()
  await voting.deployed()
  console.log(voting.address)
}) 

  it("Should return the new greeting once it's changed", async function () {

    await voting.owner()
  });
});
