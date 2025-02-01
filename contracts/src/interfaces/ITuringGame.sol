// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ITuringGame {

    struct Game {
        uint32 id;
        uint256 bet;

        mapping (address => uint) players;
    }

}
