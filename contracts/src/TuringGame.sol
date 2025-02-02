// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ITuringGame.sol";

contract TuringGame is ITuringGame, Ownable {
    uint256 public minTuringBalance = 10000 ether;

    uint32 private nextGameID;
    mapping(uint32 => Game) private games;
//0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
    address public constant TURING_TOKEN = address(0x52b492a33E447Cdb854c7FC19F1e57E8BfA1777D);
    uint128 public constant MIN_BET = 0.001 ether;

    constructor() Ownable(msg.sender) {}

    function createGame(uint256 bet) public payable returns (uint32)  {
        if (bet < MIN_BET) revert LowBet();
        if (bet != msg.value) revert IncorrectBet();
        _checkTuringBalance();

        uint32 _currentID = nextGameID;

        unchecked {
            nextGameID += 1;
        }

        Game storage game = games[_currentID];
        game.id = _currentID;
        game.bet = bet;
        game.deadline = 0;
        game.player1 = PlayerData(msg.sender, false, 0, false);

        emit GameCreated(_currentID, msg.sender, bet);

        return _currentID;
    }

    function joinGame(uint32 gameId) public payable {
        Game storage game = games[gameId];

        if (game.player1.addr == msg.sender) revert AlreadyInGame();
        if (game.player2.addr != address(0)) revert GameStarted();
        if (game.bet != msg.value) revert IncorrectBet();

        game.player2 = PlayerData(msg.sender, false, 0, false);
        game.deadline = block.timestamp + 3 minutes;

        emit Joined(gameId, msg.sender);
    }

    function vote(uint32 gameId, uint8 guessId) public {
        Game storage game = games[gameId];
        _validateVote(game);

        if (game.player1.addr == msg.sender) {
            game.player1.guessId = guessId;
            game.player1.voted = true;
        } else if (game.player2.addr == msg.sender) {
            game.player2.guessId = guessId;
            game.player2.voted = true;
        }

        emit Vote(gameId, guessId);
    }

    function validateVotes(uint32 gameId, uint8 player1, uint8 player2, uint256 adminExcess) onlyOwner public {
        Game storage game = games[gameId];

        if (game.deadline < block.timestamp && (!game.player1.voted || !game.player2.voted)) revert GameInProgress();

        game.player1.guessed = game.player1.guessId == player2;
        game.player2.guessed = game.player2.guessId == player1;
        game.validated = true;

        _sendEth(owner(), adminExcess);

        uint256 totalGameBet = (game.bet * 2) - adminExcess;

        if (game.player1.guessed && game.player2.guessed) {
            uint256 amount = totalGameBet / 2;

            _sendEth(game.player1.addr, amount);
            _sendEth(game.player2.addr, amount);
        } else if (game.player1.guessed) {
            _sendEth(game.player1.addr, totalGameBet);
        } else if (game.player2.guessed) {
            _sendEth(game.player2.addr, totalGameBet);
        } else {
            _sendEth(owner(), totalGameBet);
        }

        emit GameValidated(gameId, game.player1.guessed, game.player2.guessed);
    }

    function getGame(uint32 gameId) public view returns (Game memory) {
        return games[gameId];
    }

    function setMinTuringBalance(uint256 balance) onlyOwner public {
        minTuringBalance = balance;
    }

    function withdraw() onlyOwner public {
        _sendEth(owner(), address(this).balance);
    }

    function _validateVote(Game storage game) private view {
        if (block.timestamp > game.deadline) revert GameEnded();
        if (game.player1.addr != address(0) && game.player2.addr != address(0) && msg.sender != game.player1.addr && msg.sender != game.player2.addr) revert NotGamePlayer();
        if (msg.sender == game.player1.addr && game.player1.voted) revert AlreadyVoted();
        if (msg.sender == game.player2.addr && game.player2.voted) revert AlreadyVoted();
    }

    function _checkTuringBalance() private view {
        if (IERC20(TURING_TOKEN).balanceOf(msg.sender) < minTuringBalance) revert LowTuringTokenBalance();
    }

    function _sendEth(address account, uint256 amount) private {
        (bool success,) = account.call{value: amount}("");
        if (!success) revert FailedEthSend();
    }
}
