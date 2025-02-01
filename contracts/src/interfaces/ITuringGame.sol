// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ITuringGame {

    struct Game {
        uint32 id;
        uint256 bet;
        uint256 deadline;
        bool validated;
        PlayerData player1;
        PlayerData player2;
    }

    struct PlayerData {
        address addr;
        bool voted;
        uint8 guessId;
        bool guessed;
    }

    error LowBet();
    error IncorrectBet();
    error LowTuringTokenBalance();
    error AlreadyInGame();
    error GameStarted();
    error GameEnded();
    error NotGamePlayer();
    error GameInProgress();
    error AlreadyVoted();
    error FailedEthSend();

    event GameCreated(uint32 indexed gameId, address creator, uint256 bet);
    event Joined(uint32 indexed gameId, address joiner);
    event Vote(uint32 indexed gameId, uint8 guessId);
    event GameValidated(uint32 indexed gameId, bool player1Guessed, bool player2Guessed);
}
