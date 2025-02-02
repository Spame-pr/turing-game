// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "../src/TuringGame.sol";
import {Script, console} from "forge-std/Script.sol";

contract TuringGameDScript is Script {
    function run() public {
        uint256 user1 = vm.envUint("PK");
        uint256 user2 = vm.envUint("PK2");

        TuringGame turingGame = TuringGame(0x803d92FA9c82d533E808E6038A84EBca5E36fC1C);
        ITuringGame.Game memory game2 = turingGame.getGame(20);


//        vm.startBroadcast(user1);
//        uint32 gameId = turingGame.createGame{value: 0.001 ether}(0.001 ether);
//        vm.stopBroadcast();
//
//        vm.startBroadcast(user2);
//        turingGame.joinGame{value: 0.001 ether}(gameId);
//        vm.stopBroadcast();
//
//        vm.startBroadcast(user1);
//        turingGame.vote(gameId, 1);
//        vm.stopBroadcast();
//
//
//        vm.startBroadcast(user2);
//        turingGame.vote(gameId, 1);
//        vm.stopBroadcast();

    }
}
