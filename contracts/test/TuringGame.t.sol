// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TuringGame} from "../src/TuringGame.sol";

contract TuringGameTest is Test {
    TuringGame public turingGame;

    function setUp() public {
        turingGame = new TuringGame();
    }

    function createGame() public {
        turingGame.createGame(1);
    }
}
