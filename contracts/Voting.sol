//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;


contract Voting {

    address public owner;
    uint private ownerFee;

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

    constructor() {
        owner = msg.sender;
    }

    modifier unfinished(uint voteRoundId) {
      require(!voteRounds[voteRoundId].finished, 'voting has already been finished');
      _;
    }

    modifier isOwner() {
        require(msg.sender == owner, 'not enough privileges');
        _;
    }

    modifier voteRoundExists(uint voteRoundId) {
        require(voteRounds.length > voteRoundId, 'vote round does not exist');
        _;
    }


    function addVoteRound() public isOwner() {
        VoteRound storage voteRound = voteRounds.push();
        voteRound.startTime = uint64(block.timestamp);
        emit VoteCreated(voteRounds.length - 1);

    }


    function vote(uint voteRoundId, address candidate) public payable voteRoundExists(voteRoundId) unfinished(voteRoundId) {
        require(msg.value >= 0.01 ether, 'minimal donation is 0.01 ether');
        unchecked {
            require(block.timestamp - voteRounds[voteRoundId].startTime < 259200, 'voting time was ended');
        }
        
        require(!voteRounds[voteRoundId].voters[msg.sender], 'user has already voted');
        voteRounds[voteRoundId].donated += msg.value;
        ownerFee += (msg.value * 10) / 100;
        voteRounds[voteRoundId].voters[msg.sender] = true;
        voteRounds[voteRoundId].candidates[candidate] += 1;
        if (voteRounds[voteRoundId].candidates[candidate] == 1) {
            voteRounds[voteRoundId].candidateAddresses.push(candidate);
        }
    } 


    function finish(uint voteRoundId) public voteRoundExists(voteRoundId) unfinished(voteRoundId) {
        unchecked {
             require(block.timestamp - voteRounds[voteRoundId].startTime >= 259200, 'voting time was not ended');
        }
        
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
        voteRounds[voteRoundId].finished = true;

        if (maxVotes == 0) {
            return;
        }

        uint winnerShare = (voteRounds[voteRoundId].donated * 90)/100;
        payable(winner).transfer(winnerShare);
        emit WinnerDefined(voteRoundId, winner);
    }

    function withdrawal() public payable isOwner(){
        require(ownerFee > 0, 'not enough balance');
        payable(owner).transfer(ownerFee);
        ownerFee = 0;

    }

    function getVoteRoundInfo(uint voteRoundId) public view  voteRoundExists(voteRoundId) returns(uint64, bool, address[] memory, uint[] memory)  {
        
        uint[] memory votes = new uint[](voteRounds[voteRoundId].candidateAddresses.length);

        for (uint i=0; i < voteRounds[voteRoundId].candidateAddresses.length; i++) {
            votes[i] = voteRounds[voteRoundId].candidates[voteRounds[voteRoundId].candidateAddresses[i]];
        }

        return (voteRounds[voteRoundId].startTime, voteRounds[voteRoundId].finished, voteRounds[voteRoundId].candidateAddresses, votes);

    }

}

