// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/ITuringGame.sol";

contract TuringGame is ITuringGame {
    uint32 private nextGameID;
    mapping(uint32 => Game) private games;

    address public constant TURING_TOKEN = address(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    address public constant WETH = address(0x4200000000000000000000000000000000000006);


}
