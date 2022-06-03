//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    uint private ownerFee;

    struct VoteRound {
        uint winnerShare;
        uint64 startTime;
        bool finished;
        address winner;
        uint maxVotes;
        mapping (address => bool) voters;
        mapping (address => uint) canditesId;
        address[] candidates;
        uint[] votes;
    }

    VoteRound[] private voteRounds;

    
    event VoteCreated(uint voteRoundId);
    event WinnerDefined(uint voteRoundId, address winnerAddresss);

    
    modifier unfinished(uint voteRoundId) {
        require(!voteRounds[voteRoundId].finished, 'voting has already been finished');
        _;
    }

    modifier voteRoundExists(uint voteRoundId) {
        require(voteRounds.length > voteRoundId, 'vote round does not exist');
        _;
    }

    function addVoteRound() public onlyOwner() {
        VoteRound storage voteRound = voteRounds.push();
        voteRound.startTime = uint64(block.timestamp);
        emit VoteCreated(voteRounds.length - 1);

    }

    function vote(
        uint voteRoundId, 
        address candidate
        ) public payable voteRoundExists(voteRoundId) unfinished(voteRoundId) {
        
        require(msg.value >= 0.01 ether, 'minimal donation is 0.01 ether');
        require(
            block.timestamp - voteRounds[voteRoundId].startTime < 259200,  
            'voting time was ended'
            );
        require(!voteRounds[voteRoundId].voters[msg.sender], 'user has already voted');
        
        uint voteFee = (msg.value * 10) / 100;

        voteRounds[voteRoundId].winnerShare += (msg.value - voteFee);
        ownerFee += voteFee;

        voteRounds[voteRoundId].voters[msg.sender] = true;

        uint candidateId = voteRounds[voteRoundId].canditesId[candidate];
        if (candidateId == 0) {
            voteRounds[voteRoundId].candidates.push(candidate);
            candidateId = voteRounds[voteRoundId].candidates.length;
            voteRounds[voteRoundId].canditesId[candidate] = candidateId;
            voteRounds[voteRoundId].votes.push(0);
        }

        voteRounds[voteRoundId].votes[candidateId-1] += 1;

        if (voteRounds[voteRoundId].votes[candidateId-1] > voteRounds[voteRoundId].maxVotes) {
            voteRounds[voteRoundId].winner = candidate;
            voteRounds[voteRoundId].maxVotes = voteRounds[voteRoundId].votes[candidateId-1];
        }
        
    } 

    function finish(uint voteRoundId) public voteRoundExists(voteRoundId) unfinished(voteRoundId) {
     
        require(block.timestamp - voteRounds[voteRoundId].startTime >= 259200, 'voting time was not ended');
     
        voteRounds[voteRoundId].finished = true;

        if (voteRounds[voteRoundId].maxVotes == 0) {
            return;
        }
        payable(voteRounds[voteRoundId].winner).transfer(voteRounds[voteRoundId].winnerShare);
        emit WinnerDefined(voteRoundId, voteRounds[voteRoundId].winner);
    }

    function withdrawal() public payable onlyOwner(){
        require(ownerFee > 0, 'not enough balance');
        payable(owner()).transfer(ownerFee);
        ownerFee = 0;
    }

    function getVoteRoundInfo(uint voteRoundId) public view  voteRoundExists(voteRoundId) returns(
        uint64, 
        bool, 
        address[] memory, 
        uint[] memory
        ) {
        
        return (
            voteRounds[voteRoundId].startTime, 
            voteRounds[voteRoundId].finished, 
            voteRounds[voteRoundId].candidates, 
            voteRounds[voteRoundId].votes
            );
    }
}
