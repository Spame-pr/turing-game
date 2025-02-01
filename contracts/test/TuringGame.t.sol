// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/TuringGame.sol";
import {Test, console} from "forge-std/Test.sol";

contract TuringGameTest is Test {
    TuringGame public turingGame;

    function setUp() public {
        turingGame = new TuringGame();
    }

    function testCreateGame() public {
    }
}
