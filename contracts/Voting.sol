//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;


contract Voting {
    address public  owner;

    event VoteCreated(uint voteRoundId);
    event WinnerDefined(uint voteRoundId, address winnerAddresss);
    
    struct VoteRound {
        uint donated;
        uint64 startTime;
        bool finished;
        mapping (address => bool) voters;
        mapping (address => uint) candidates ;
        address[] candidateAddresses;
    }

    VoteRound[] public voteRounds;
    uint voteRoundsCount;

    constructor() {
        owner = msg.sender;
        voteRoundsCount = 0;
    }

    function addVoteRound() public {
        require(msg.sender == owner, 'not enough privileges');
        VoteRound storage voteRound = voteRounds.push();
        voteRound.startTime = uint64(block.timestamp);
        emit VoteCreated(voteRounds.length - 1);

    }


    function vote(uint voteRoundId, address candidate) public payable {
        require(msg.value >= 0.01 ether, 'minimal donation is 0.01 ether');
        require(!voteRounds[voteRoundId].finished, 'voting was finished');
        require(voteRounds[voteRoundId].startTime - block.timestamp < 259200, 'voting time was ended');
        require(!voteRounds[voteRoundId].voters[msg.sender], 'user has already voted');
        voteRounds[voteRoundId].donated += msg.value;
        voteRounds[voteRoundId].voters[msg.sender] = true;
        voteRounds[voteRoundId].candidates[candidate] += 1;
        if (voteRounds[voteRoundId].candidates[candidate] == 1) {
            voteRounds[voteRoundId].candidateAddresses.push(candidate);
        }
    } 


    function finish(uint voteRoundId) public {
        require(!voteRounds[voteRoundId].finished, 'voting has already been finished');
        require(voteRounds[voteRoundId].startTime - block.timestamp >= 259200, 'voting time was not ended');
        
        uint maxVotes = 0;
        address winner;
        address currentCandidate;

        for (uint i=0; i < voteRounds[voteRoundId].candidateAddresses.length; i++) {
            currentCandidate = voteRounds[voteRoundId].candidateAddresses[i];
            if (voteRounds[voteRoundId].candidates[currentCandidate] > maxVotes) {
                maxVotes = voteRounds[voteRoundId].candidates[currentCandidate];
                winner = currentCandidate;
            }
        }

        uint winnerShare = voteRounds[voteRoundId].donated / 90;
        payable(winner).transfer(winnerShare);
        emit WinnerDefined(voteRoundId, winner);
    }

    function obtainFee() public payable{
        require(msg.sender == owner, 'not enough privileges');
        payable(owner).transfer(address(this).balance);

    }

    function getVoteRoundInfo(uint voteRoundId) public view returns(uint64, bool, address[] memory, uint[] memory) {
        uint[] memory votes;

        for (uint i=0; i < voteRounds[voteRoundId].candidateAddresses.length; i++) {
            votes[i] = voteRounds[voteRoundId].candidates[voteRounds[voteRoundId].candidateAddresses[i]];
        }

        return (voteRounds[voteRoundId].startTime, voteRounds[voteRoundId].finished, voteRounds[voteRoundId].candidateAddresses, votes);

    }

}

