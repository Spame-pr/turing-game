// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/TuringGame.sol";
import "../src/interfaces/ITuringGame.sol";
import {Test, console} from "forge-std/Test.sol";

contract TuringGameTest is Test {
    TuringGame public turingGame;
    address public admin;
    address public player1;
    address public player2;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("base"), 25788855);
        admin = makeAddr("admin");
        vm.prank(admin);
        turingGame = new TuringGame();

        player1 = makeAddr("player1");
        player2 = makeAddr("player2");

        vm.deal(admin, 1 ether);
        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);

        deal(turingGame.TURING_TOKEN(), player1, 10000 ether);
    }

    function test_createGame_success() public {
        vm.prank(player1);
        turingGame.createGame{value: 0.1 ether}(0.1 ether);
    }

    function test_createGame_bet_fail() public {
        vm.expectRevert(ITuringGame.LowBet.selector);
        turingGame.createGame(1);

        vm.expectRevert(ITuringGame.IncorrectBet.selector);
        turingGame.createGame{value: 1 ether}(2 ether);
    }

    function test_joinGame_success() public {
        vm.prank(player1);
        uint32 gameId = turingGame.createGame{value: 0.1 ether}(0.1 ether);

        vm.prank(player2);
        turingGame.joinGame{value: 0.1 ether}(gameId);
    }

    function test_joinGame_fail() public {
        vm.prank(player1);
        uint32 gameId = turingGame.createGame{value: 0.1 ether}(0.1 ether);

        vm.expectRevert(ITuringGame.AlreadyInGame.selector);
        vm.prank(player1);
        turingGame.joinGame{value: 0.1 ether}(gameId);

        vm.prank(player2);
        turingGame.joinGame{value: 0.1 ether}(gameId);

        vm.expectRevert(ITuringGame.GameStarted.selector);
        turingGame.joinGame{value: 0.1 ether}(gameId);
    }

    function test_joinGame_bet_fail() public {
        vm.prank(player1);
        uint32 gameId = turingGame.createGame{value: 0.1 ether}(0.1 ether);

        vm.expectRevert(ITuringGame.IncorrectBet.selector);
        vm.prank(player2);
        turingGame.joinGame{value: 0.2 ether}(gameId);
    }

    function test_vote_success() public {
        vm.prank(player1);
        uint32 gameId = turingGame.createGame{value: 0.1 ether}(0.1 ether);

        ITuringGame.Game memory game = turingGame.getGame(gameId);
        assertEq(game.player1.addr, player1);

        vm.prank(player2);
        turingGame.joinGame{value: 0.1 ether}(gameId);

        ITuringGame.Game memory game2 = turingGame.getGame(gameId);

        assertEq(game2.player2.addr, player2);

        vm.prank(player1);
        turingGame.vote(gameId, 1);


        vm.prank(player2);
        turingGame.vote(gameId, 1);

        vm.prank(admin);
        turingGame.validateVotes(gameId, 1, 0, 0.01 ether);
    }

    function test_setMinTuringBalance_success() public {
        vm.prank(admin);
        turingGame.setMinTuringBalance(1 ether);
        assertEq(turingGame.minTuringBalance(), 1 ether);
    }

    function test_withdraw_success() public {
        vm.prank(player1);
        uint32 gameId = turingGame.createGame{value: 0.1 ether}(0.1 ether);

        ITuringGame.Game memory game = turingGame.getGame(gameId);
        assertEq(game.player1.addr, player1);

        vm.prank(player2);
        turingGame.joinGame{value: 0.1 ether}(gameId);
        assertEq(address(turingGame).balance, 0.2 ether);

        vm.prank(admin);
        turingGame.withdraw();

        assertEq(address(turingGame).balance, 0);
    }
}
