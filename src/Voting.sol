// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract voting is Ownable, AccessControl {
    error Voting__votingIsStarted();
    error Voting__votingIsNotStarted();

    event candidateAdded(string name, string party);
    event voterRegistered(address account, string aadharNumber);

    bytes32 private constant ROLE = keccak256("ADMIN");
    mapping(string => bool) private s_voterToRegister;
    mapping(string => bool) private s_voterToVoted;
    mapping(string => bool) private s_candidateExist;
    mapping(uint256 id => Candidate) private s_candidate;
    mapping(string => Voter) private s_voter;
    uint256 public totalCandidate = 0;
    uint256 public totalVoters = 0;
    uint256 public totalVotes = 0;
    uint256 s_duration;
    uint256 s_startTime;
    bool start = false;

    struct Candidate {
        uint256 id;
        uint256 voteCount;
        string name;
        string party;
    }

    struct Voter {
        address voter;
        string adharNumber;
        uint256 votedCandidateId;
        uint256 voteCount;
    }

    constructor() Ownable(msg.sender) {
        grantRole(ROLE, owner());
    }

    function addCandidte(string memory _name, string memory _party) external onlyOwner onlyRole(ROLE) {
        verifyCandidate(_name);
        totalCandidate = totalCandidate + 1;
        s_candidateExist[_name] = true;
        s_candidate[totalCandidate] = Candidate(totalCandidate, 0, _name, _party);
        emit candidateAdded(_name, _party);
    }

    function addVoter(address _account, string memory _aadharNumber) external onlyOwner onlyRole(ROLE) {
        verifyVoter(_aadharNumber);
        totalVoters = totalVoters + 1;
        s_voterToRegister[_aadharNumber] = true;
        s_voter[_aadharNumber] = Voter(_account,_aadharNumber,0,0);
        emit voterRegistered(_account, _aadharNumber);
    }

    function startVoting(uint256 _duration) external onlyOwner onlyRole(ROLE) {
        checkForVotingStatus();
        s_duration = _duration;
        start = true;
        s_startTime = block.timestamp;
    }

    function endVoting() external onlyOwner onlyRole(ROLE) {
        if(!start) {
            revert Voting__votingIsNotStarted();
        }
        require(block.timestamp >= s_startTime + s_duration, "voting duration is not completed");
        s_duration = 0;
        start = false;
        s_startTime = 0;
    }

    function verifyCandidate(string memory _name) public view {
        checkForVotingStatus();
        require(!_candidateExist(_name), "Candidate is already exist");
    }

    function getCandidate(uint256 id) external view returns(Candidate memory) {
        return s_candidate[id];
    }

    function getVoter(string memory _aadharNumber) external view returns(Voter memory) {
        return s_voter[_aadharNumber];
    }

    function _candidateExist(string memory name) private view returns(bool) {
        return s_candidateExist[name];
    } 

    function checkForVotingStatus() public view {
        if (start) {
            revert Voting__votingIsStarted();
        }
    }

    function verifyVoter(string memory _aadharNumber) public view {
        checkForVotingStatus();
        require(!_voterExist(_aadharNumber), "Voter is already exist");
    }

    function _voterExist(string memory _aadharNumber) private view returns(bool) {
        return s_voterToRegister[_aadharNumber];
    }
}
