// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

contract DeployVoting is Script {
    Voting voting;

    function run() external returns (Voting) {
        vm.startBroadcast();
        voting = new Voting();
        vm.stopBroadcast();
        return voting;
    }
}
