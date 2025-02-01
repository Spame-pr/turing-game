// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/TuringGame.sol";
import {Script, console} from "forge-std/Script.sol";

contract TuringGameScript is Script {
    function run() public {
        uint256 admin = vm.envUint("PK");

        vm.startBroadcast(admin);
        TuringGame tgBotContract = new TuringGame();
        vm.stopBroadcast();
    }
}
