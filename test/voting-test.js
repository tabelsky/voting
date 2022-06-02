const { ethers } = require("hardhat");
const chai = require("chai");
const { solidity } = require("ethereum-waffle");
chai.use(solidity);
const { expect } = chai;

const bigAmount = ethers.utils.parseEther("0.01")
const smallAmount = ethers.utils.parseEther("0.001")


const zip = (arr, ...arrs) => {
  return arr.map((val, i) => arrs.reduce((a, arr) => [...a, arr[i]], [val]));
}

async function createVoteRound(voting) {
  return (await (await voting.addVoteRound()).wait()).events[0].args[0]
}


async function vote(voting, voteRoundId, voter, candidate) {
  await voting.connect(voter).vote(voteRoundId, candidate.address, {value: bigAmount});
}


async function increaseBlockchaonTime(time) {
  await ethers.provider.send("evm_increaseTime", [time]);
  await ethers.provider.send("evm_mine");
}


function getNow() {
  return parseInt(Date.now() / 1000)
}


describe("Voting", function () {
  let owner, voter_1, voter_2, voter_3, voter_4, candidate_1, candidate_2, voting


beforeEach(async function() {
  [owner, voter_1, voter_2, voter_3, voter_4, candidate_1, candidate_2] = await ethers.getSigners()
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

  it('check just created vote', async function() {
    let voteId = await createVoteRound(voting);
    let now = getNow();
    let [creationTime, finished, adresses, results] =  await voting.getVoteRoundInfo(voteId);
    expect(creationTime).to.be.at.least(now);
    expect(creationTime).to.be.below(now+1000);
  })

  it('check doble vote from one voter', async function() {
    let voteRoundId = await createVoteRound(voting);
    await voting.connect(voter_1);
    await (voting.vote(voteRoundId, candidate_1.address, {value: bigAmount}));
    expect(voting.vote(voteRoundId, candidate_2.address, {value: bigAmount})).to.be.revertedWith('user has already vote');

  })

  it('check small donation', async function() {
    let voteRoundId = await createVoteRound(voting);
    await voting.connect(voter_1);
    expect(voting.vote(voteRoundId, candidate_2.address, {value: smallAmount})).to.be.revertedWith('minimal donation is 0.01 ether');

  }) 

  it('check voting time', async function() {
    let voteRoundId = await createVoteRound(voting);
    await increaseBlockchaonTime(259201);
    await voting.connect(voter_1);
    expect(voting.vote(voteRoundId, candidate_2.address, {value: bigAmount})).to.be.revertedWith('voting time was ended');

  })
  
  it('check finish before 3 days had gone', async function() {
    let voteRoundId = await createVoteRound(voting);
    await vote(voting, voteRoundId, voter_1, candidate_1);
    expect(voting.finish(voteRoundId)).to.be.revertedWith('voting time was not ended');
  })

  it('check vote results', async function() {
    let voteRoundId = await createVoteRound(voting);
    await vote(voting, voteRoundId, voter_1, candidate_1);   
    await vote(voting, voteRoundId, voter_2, candidate_1);
    await vote(voting, voteRoundId, voter_3, candidate_1);
    await vote(voting, voteRoundId, voter_4, candidate_2);
    let voteResults = await voting.getVoteRoundInfo(voteRoundId);
    expect(voteResults[1]).to.equal(false);
    voteResults = Object.fromEntries(zip(voteResults[2], voteResults[3]));
    expect(voteResults[candidate_1.address]).to.equal(3);
    expect(voteResults[candidate_2.address]).to.equal(1);
  })

  it('check finish', async function() {
    let voteRoundId = await createVoteRound(voting);
    await vote(voting, voteRoundId, voter_1, candidate_1);   
    await increaseBlockchaonTime(259201);
    
    await voting.finish(voteRoundId);
    const balaneAfter = await ethers.provider.getBalance(candidate_1.address);
    
    expect(balaneAfter).to.equal(ethers.utils.parseEther("10000.009"));
    
    const voteResults = await voting.getVoteRoundInfo(voteRoundId);
    expect(voteResults[1]).to.equal(true);
    
  })

  it('check finish no votes', async function () {
    let voteRoundId = await createVoteRound(voting);
    await increaseBlockchaonTime(259201);
    expect((await (await voting.finish(voteRoundId)).wait()).events.length).to.equal(0);
    
  })

  it('check empty withdraw', async function () {
    expect(voting.withdrawal()).to.be.revertedWith('not enough balance');
  })

  it('check withdraw', async function() {
    let voteRoundId = await createVoteRound(voting);
    await vote(voting, voteRoundId, voter_1, candidate_1);
    
  })



});
