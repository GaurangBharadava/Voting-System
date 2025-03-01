// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployVoting} from "../script/DepolyVoting.s.sol";
import {Voting} from "../src/Voting.sol";

contract TestVoting is Test {
    event candidateAdded(string name, string party);

    DeployVoting public deployer;
    Voting public voting;

    address public owner;
    address user1;
    address user2;
    address user3;
    address user4;
    address user5;

    function setUp() public {
        deployer = new DeployVoting();
        voting = deployer.run();
        owner = voting.owner();
    }

    function makeAddresses() private {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
        user5 = makeAddr("user5");
    }

    function testOwnerhasAdminRole() public view {
        assertEq(voting.hasRole(voting.role(), voting.owner()), true);
    }

    function testAddCandidate() public {
        vm.startPrank(owner);
        vm.expectEmit();
        emit candidateAdded("Gaurang", "HEXXA");
        voting.addCandidte("Gaurang", "HEXXA");
        vm.stopPrank();
        console.log("Candidate at id 1:", voting.getCandidate(1).name);
    }

    function testNonAuthorizedCanNotAddCandidate() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.expectRevert();
        voting.addCandidte("Gaurang", "HEXXA");
        vm.stopPrank();
    }

    function testStartVotingAndEndVoting() public {
        vm.startPrank(owner);
        voting.startVoting(1 days);
        assertEq(voting.start(), true);
        assertEq(voting.s_duration(), 1 days);
        vm.warp(1 days + 1);
        voting.endVoting();
        assertEq(voting.start(), false);
        vm.stopPrank();
    }

    function testCandidateCanNotAdded() public {
        vm.startPrank(owner);
        voting.startVoting(2 days);
        assertEq(voting.start(), true);
        assertEq(voting.s_duration(), 2 days);
        vm.expectRevert();
        voting.addCandidte("Anshuman", "Axon");
        vm.stopPrank();
    }

    function testRegisterVoter() public {
        vm.startPrank(owner);
        address user = makeAddr("user");
        voting.addVoter(address(user), "9143505346943");
        assertEq(voting.totalVoters(), 1);
        assertEq(voting.getVoter("9143505346943").voter, address(user));
        vm.stopPrank();
    }

    function testCanNotRegisterVoterInBeetweenVoting() public {
        vm.startPrank(owner);
        address user = makeAddr("user");
        voting.startVoting(1 days);
        vm.expectRevert();
        voting.addVoter(address(user), "9143505346943");
        vm.stopPrank();
    }

    function testNonOwnerCannotStartVoting() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.expectRevert();
        voting.startVoting(1 days);
        vm.stopPrank();
    }

    function testNonOwnerCannotEndVoting() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.expectRevert();
        voting.startVoting(1 days);
        vm.warp(1 days + 1);
        vm.expectRevert();
        voting.endVoting();
        vm.stopPrank();
    }

    function testDuplicatePrevention() public {
        vm.startPrank(owner);
        voting.addCandidte("Gaurang", "HEXXA");
        vm.expectRevert();
        voting.addCandidte("Gaurang", "HEXXA");
        address user = makeAddr("user");
        voting.addVoter(address(user), "9143505346943");
        vm.expectRevert();
        voting.addVoter(address(user), "9143505346943");
        vm.stopPrank();
    }

    function testVote() public {
        vm.startPrank(owner);
        voting.addCandidte("Gaurang", "HEXXA");
        voting.addCandidte("Anshuman", "Axon");
        voting.addCandidte("Manav", "BRDV");
        voting.addCandidte("Madhav", "OXAOXA");
        makeAddresses();
        voting.addVoter(address(user1), "9143505346943");
        voting.addVoter(address(user2), "9143505546943");
        voting.addVoter(address(user3), "9143502346943");
        voting.addVoter(address(user4), "9143505356943");
        voting.addVoter(address(user5), "9143515346943");
        vm.stopPrank();

        vm.prank(user1);
        voting.vote(1);
        vm.prank(user2);
        voting.vote(3);
        vm.prank(user3);
        voting.vote(2);
        vm.prank(user4);
        voting.vote(1);
        vm.prank(user5);
        voting.vote(2);

        assertEq(voting.getCandidate(1).voteCount, 2);
        assertEq(voting.getCandidate(2).voteCount, 2);
        assertEq(voting.getCandidate(3).voteCount, 1);
        assertEq(voting.getCandidate(4).voteCount, 0);
        assertEq(voting.totalVoters(), 5);
        assertEq(voting.totalCandidate(), 4);
        assertEq(voting.totalVotes(), 5);
    }

    function testVoterCanNotVoteMultipleTime() public {
        vm.startPrank(owner);
        voting.addCandidte("Gaurang", "HEXXA");
        voting.addCandidte("Anshuman", "Axon");
        voting.addCandidte("Manav", "BRDV");
        voting.addCandidte("Madhav", "OXAOXA");
        makeAddresses();
        voting.addVoter(address(user1), "9143505346943");
        voting.addVoter(address(user2), "9143505546943");
        voting.addVoter(address(user3), "9143502346943");
        voting.addVoter(address(user4), "9143505356943");
        voting.addVoter(address(user5), "9143515346943");
        vm.stopPrank();

        vm.prank(user1);
        voting.vote(1);
        vm.prank(user2);
        voting.vote(3);
        vm.expectRevert();
        vm.prank(user2);
        voting.vote(1);
        vm.prank(user3);
        voting.vote(2);
        vm.prank(user4);
        voting.vote(1);
        vm.prank(user5);
        voting.vote(2);
    }
}
