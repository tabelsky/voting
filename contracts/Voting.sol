//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;


contract Voting {
    address private  owner;

    struct VoteRound {
        uint donated;
        uint64 startDate;
        bool finished;
        mapping (address => bool) voters;
        mapping (address => uint) candidates;
        
    }

    VoteRound[] voteRounds;

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns(address) {
        return owner;
        
    }

    function addVoteRound() public returns(uint) {
        require(msg.sender == owner, 'not enough privileges');
        VoteRound storage newVoteRound = voteRounds.push();
        newVoteRound.startDate = uint64(block.timestamp);
        return voteRounds.length;
    }

    function vote(uint voteRoundId, address candidate) public payable {
        require(msg.value >= 0.01 ether);
        require(!voteRounds[voteRoundId].voters[msg.sender]);
        voteRounds[voteRoundId].donated += msg.value;
        voteRounds[voteRoundId].voters[msg.sender] = true;
        voteRounds[voteRoundId].candidates[candidate] += 1;

    } 

    function getVotes() public view returns (mapping (address => uint) memory){
        return voteRounds[0].startDate;
    }

}
