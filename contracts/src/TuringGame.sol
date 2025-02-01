// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ITuringGame.sol";

contract TuringGame is ITuringGame, Ownable {
    uint256 public minTuringBalance = 1 ether;

    uint32 private nextGameID;
    mapping(uint32 => Game) private games;

    address public constant TURING_TOKEN = address(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    address public constant WETH = address(0x4200000000000000000000000000000000000006);
    uint128 public constant MIN_BET = 0.001 ether;

    constructor() Ownable(msg.sender) {}

    function createGame(uint256 bet) public payable returns (uint32)  {
        if (bet < MIN_BET) revert LowBet();
        if (bet != msg.value) revert IncorrectBet();
        //_checkTuringBalance();

        uint32 _currentID = nextGameID;

        unchecked {
            nextGameID += 1;
        }

        Game storage game = games[_currentID];
        game.id = _currentID;
        game.bet = bet;
        game.deadline = 0;
        game.player1 = PlayerData(msg.sender, false);

        emit GameCreated(_currentID, msg.sender, bet);

        return _currentID;
    }

    function joinGame(uint32 gameId) public payable {
        Game storage game = games[gameId];

        if (game.bet != msg.value) revert IncorrectBet();
        game.player2 = PlayerData(msg.sender, false);
    }

    function vote(uint32 gameId, address user) public {
        Game storage game = games[gameId];

        if (game.player1.player == msg.sender) {
            game.player1.guessed = game.player2.player == user;
        } else if (game.player2.player == msg.sender) {
            game.player2.guessed = game.player1.player == user;
        }
    }

//    function _checkTuringBalance() private view {
//        if (IERC20(TURING_TOKEN).balanceOf(msg.sender) < minTuringBalance) revert LowTuringTokenBalance();
//    }
}
