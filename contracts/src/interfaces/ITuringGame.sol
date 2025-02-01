// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ITuringGame {

    struct Game {
        uint32 id;
        uint256 bet;
        uint256 deadline;
        PlayerData player1;
        PlayerData player2;
    }

    struct PlayerData {
        address player;
        bool guessed;
    }

    error LowBet();
    error IncorrectBet();
    error LowTuringTokenBalance();

    event GameCreated(uint32 indexed gameId, address creator, uint256 bet);
}
