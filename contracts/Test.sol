// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8;
 
import "@openzeppelin/contracts/access/Ownable.sol";
 
contract WelcomeToWeb3 is Ownable(msg.sender) {
 
    string message = "Welcome to Web3";
    
    function contractGreeting() public view returns(string memory) {
    return message;
    }
    
    function changeGreetingMessage(string memory _message) public onlyOwner {
    message = _message;
    }
}