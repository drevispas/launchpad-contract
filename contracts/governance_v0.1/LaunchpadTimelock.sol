// src/contracts/governance/LaunchpadTimelock.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract LaunchpadTimelock is TimelockController {
    // Constructor: Set up the timelock with initial admin and minimum delay
    constructor(
        uint256 minDelay,        // Minimum delay before execution
        address[] memory proposers,  // Addresses that can propose
        address[] memory executors,  // Addresses that can execute
        address admin              // Admin address
    ) TimelockController(
        minDelay,
        proposers,
        executors,
        admin
    ) {}
}