const { expect } = require("chai");
const { ethers } = require("hardhat");

async function createVoteRound(voting) {
  return (await (await voting.addVoteRound()).wait()).events[0].args[0]
}

describe("Voting", function () {

let owner;
let user_1;
let voting;

beforeEach(async function() {
  [owner, voter_1, voter_2, candidate_1, candidate_2] = await ethers.getSigners()
  const Voting = await ethers.getContractFactory("Voting", owner);
  voting = await Voting.deploy();
  await voting.deployed();

}) 

  it("check constructor", async function () {
    expect(await voting.owner()).to.equal(owner.address);
  });

  it('only owner is able to create votes', async function () {
    
    expect(voting.connect(voter_1).addVoteRound()).to.be.revertedWith('not enough privileges');
  })

  it('check create vote', async function() {
    let voteId = await createVoteRound(voting);
    expect(voteId).to.equal(0);
    voteId = await createVoteRound(voting);
    expect(voteId).to.equal(1);
  })

  it('check just_create_vote', async function() {
    let voteId = await createVoteRound(voting);
    let now = parseInt(Date.now() / 1000);
    let [creationTime, finished, adresses, results] =  await voting.getVoteRoundInfo(voteId);
    expect(creationTime).to.be.at.least(now);
    expect(creationTime).to.be.below(now+1000);
  })

  it ('check doble vote from one voter', async function() {
    let voteRoundId = await createVoteRound(voting);
    await (await voting.connect(voter_1).vote(voteRoundId, candidate_1.address, {value: ethers.utils.parseEther("1.0")}));
    // await (await voting.connect(voter_1).vote(voteRoundId, candidate_1.address, {value: ethers.utils.parseEther("1.0")}));
    expect(voting.connect(voter_1).vote(voteRoundId, candidate_2.address, {value: ethers.utils.parseEther("1.0")})).to.be.revertedWith('user has already voted');

  })

});
