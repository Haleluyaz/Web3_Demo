// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract SmartFunding {
    address public tokenAddress;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }
}