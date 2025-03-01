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

    function setUp() public {
        deployer = new DeployVoting();
        voting = deployer.run();
        owner = voting.owner();
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
}
