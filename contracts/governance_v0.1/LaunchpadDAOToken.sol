// src/contracts/token/LaunchpadDAOToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";  // Add this import

contract LaunchpadDAOToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("LaunchpadDAO Token", "LAUNCH") ERC20Permit("LaunchpadDAO Token") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    // Override _update as before
    function _update(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    // Fix the nonces override by specifying both parent contracts
    function nonces(address owner) 
        public 
        view 
        virtual 
        override(ERC20Permit, Nonces) 
        returns (uint256) 
    {
        return super.nonces(owner);
    }
}