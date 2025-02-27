// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract voting is Ownable, AccessControl {
    error Voting__cannotAddCandidateWhileVotingPeriod();

    event candidateAdded();

    bytes32 private constant ROLE = keccak256("ADMIN");
    mapping(address voter => bool registered) private s_voterToRegister;
    mapping(address voter => bool voted) private s_voterToVoted;
    mapping(string => bool) private s_candidateExist;
    uint256 public totalCandidate = 0;
    uint256 public totalVoters = 0;
    uint256 public totalVotes = 0;
    bool start = false;

    struct Candidate {
        uint256 id;
        uint256 voteCount;
        string name;
        string party;
    }

    mapping(uint256 id => Candidate) private s_candidate;

    constructor() Ownable(msg.sender) {
        grantRole(ROLE, msg.sender);
    }

    function addCandidte(string memory _name, string memory _party) external onlyOwner onlyRole(ROLE) {
        if (!start) {
            revert Voting__cannotAddCandidateWhileVotingPeriod();
        }
        require(!s_candidateExist[_name], "Candidate is already exist");
        totalCandidate = totalCandidate + 1;
        s_candidateExist[_name] = true;
        s_candidate[totalCandidate] = Candidate(totalCandidate, 0, _name, _party);
        emit candidateAdded();
    }
}
