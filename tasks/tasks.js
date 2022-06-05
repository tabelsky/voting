const { task } = require('hardhat/config')

require('@nomiclabs/hardhat-waffle')

const ROPSTEN_DEFAULT_CONTRACT_ADRESS = '0x81b89CEA9621972D80680e5ad12A8ae7168E717d'

async function getVoting (contract, hre) {
  contract = contract || ROPSTEN_DEFAULT_CONTRACT_ADRESS
  const Voting = await hre.ethers.getContractFactory('Voting')
  const voting = await Voting.attach(contract)
  return voting
}

task('createVote', 'Create vote')
  .addOptionalParam('contract', 'Contract addess')
  .setAction(async ({ contract }, hre) => {
    const voting = await getVoting(contract, hre)
    const response = await voting.addVoteRound()
    const voteRoundId = (await response.wait()).events[0].args[0].toNumber()
    console.log(voteRoundId)
  })

task('vote', 'Vote for address')
  .addOptionalParam('contract', 'Contract addess')
  .addParam('voteId', 'ID of a vote round')
  .addParam('candidate', 'Address of a candidate')
  .addOptionalParam('ammount', 'Amount of a daonation')
  .setAction(async ({ contract, voteId, candidate, amount }, hre) => {
    amount = amount ? hre.ethers.utils.parseEther(amount) : hre.ethers.utils.parseEther('0.01')
    const voting = await getVoting(contract, hre)

    await voting.vote(parseInt(voteId), candidate, { value: amount })
  })

task('voteInfo', 'Get info about vote round')
  .addOptionalParam('contract', 'Contract addess')
  .addParam('voteId', 'ID of a vote round')
  .setAction(async ({ contract, voteId }, hre) => {
    const voting = await getVoting(contract, hre)
    console.log(await voting.getVoteRoundInfo(parseInt(voteId)))
  })

task('finish', 'Finish a vote round')
  .addOptionalParam('contract', 'Contract addess')
  .addParam('voteId', 'ID of a vote round')
  .setAction(async ({ contract, voteId }, hre) => {
    const voting = await getVoting(contract, hre)
    await voting.finish(voteId)
  })

task('withdrawal', 'Withdraw from a contract')
  .addOptionalParam('contract', 'Contract addess')
  .setAction(async ({ contract }, hre) => {
    const voting = await getVoting(contract, hre)
    await voting.withdrawal()
  })

module.exports = {}
