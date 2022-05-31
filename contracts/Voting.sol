//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;


contract Voting {
    address public  owner;

    struct VoteRound {
        uint donated;
        uint64 startTime;
        bool finished;
        uint[] candidatesResults;
        
    }

    mapping (uint => mapping (address => bool)) voteRoundVoters; 
    mapping (uint => mapping (uint => address)) voteRoundCandidates;
    
    VoteRound[] public voteRounds;

    constructor() {
        owner = msg.sender;
    }

    function addVoteRound() public returns(uint) {
        require(msg.sender == owner, 'not enough privileges');
        voteRounds.push();
        voteRounds[voteRounds.length - 1].startTime = uint64(block.timestamp);
        return voteRounds.length - 1;
    }


    function vote(uint voteRoundId, address candidate) public payable {
        require(msg.value >= 0.01 ether, 'minimal donation is 0.01 ether');
        require(!voteRounds[voteRoundId].finished, 'voting was finished');
        require(voteRounds[voteRoundId].startTime - block.timestamp < 259200, 'voting time was ended');
        require(!voteRoundVoters[voteRoundId].voters[msg.sender], 'user has already voted');
        voteRounds[voteRoundId].donated += msg.value;
        voteRounds[voteRoundId].voters[msg.sender] = true;
        voteRounds[voteRoundId].candidates[candidate] += 1;
        if (voteRounds[voteRoundId].candidates[candidate] == 1) {
            voteRounds[voteRoundId].candidateAddresses.push(candidate);
        }
    } 


    function finish(uint voteRoundId) public returns(address) {
        VoteRound storage voteRound = voteRounds[voteRoundId];
        require(!voteRounds[voteRoundId].finished, 'voting has already been finished');
        require(voteRounds[voteRoundId].startTime - block.timestamp >= 259200, 'voting time was not ended');
        
        uint maxVotes = 0;
        address winner;
        address currentCandidate;

        for (uint i=0; i < voteRound.candidateAddresses.length; i++) {
            currentCandidate = voteRound.candidateAddresses[i];
            if (voteRound.candidates[currentCandidate] > maxVotes) {
                maxVotes = voteRound.candidates[currentCandidate];
                winner = currentCandidate;
            }
        }

        uint winnerShare = voteRound.donated / 90;
        payable(winner).transfer(winnerShare);
        return winner;
    }

    function obtainFee() public payable{
        require(msg.sender == owner, 'not enough privileges');
        payable(owner).transfer(address(this).balance);

    }

    function getVoteRoundInfo(uint voteRoundId) public view returns(uint, uint, bool, address[] memory, uint[] memory) {
        VoteRound storage voteRound = voteRounds[voteRoundId];
        uint  arrayLengtgh= voteRound.candidateAddresses.length;
        uint[] storage results;
        for (uint i=0; i < voteRound.candidateAddresses.length; i++) {
            results.push(voteRound.candidates[voteRound.candidateAddresses[i]]);

        }
        

        return (voteRound.donated,  voteRound.startTime, voteRound.finished, voteRound.candidates, results);

    }

    function test() public returns(VoteRound memory) {}

}

