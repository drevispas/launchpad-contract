// src/contracts/governance/ProposalStorage.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LaunchpadGovernorStorage {
    // Structure to store proposal details
    struct ProposalDetails {
        address[] targets;        // Contract addresses to call
        uint256[] values;        // ETH values to send with calls
        bytes[] calldatas;       // Function call data
        string description;      // Proposal description
        uint256 voteStart;      // Start time of voting
        uint256 voteEnd;        // End time of voting
        bool executed;          // Whether the proposal has been executed
        mapping(address => bool) hasVoted;  // Track who has voted
        uint256 forVotes;      // Number of votes in favor
        uint256 againstVotes;  // Number of votes against
    }

    // Mapping from proposal ID to proposal details
    mapping(uint256 => ProposalDetails) public proposals;

    // Function to store a new proposal
    function storeProposal(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        uint256 voteStart,
        uint256 voteEnd
    ) external {
        ProposalDetails storage proposal = proposals[proposalId];
        proposal.targets = targets;
        proposal.values = values;
        proposal.calldatas = calldatas;
        proposal.description = description;
        proposal.voteStart = voteStart;
        proposal.voteEnd = voteEnd;
        proposal.executed = false;
    }
}