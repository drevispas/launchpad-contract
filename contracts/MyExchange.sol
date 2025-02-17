// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("TokenA", "A") {
        _mint(msg.sender, 50*10);
    }
}

contract MyExchange is ERC20 {

    address public tokenAddress;
    TokenA tokenA;

    constructor(address _tokenAddress) ERC20("Exchange", "XCH") {
        tokenAddress = _tokenAddress;
        tokenA = TokenA(tokenAddress);
    }

    /*
    DEX user로부터 Ether를 받고 토큰으로 교환해 줌
    */
    function eitherToToken() public payable {
        address swapUser = msg.sender;
        uint eitherAmount = msg.value / 1 ether;
        // CSMM (Constant Sum Market Maker)
        uint tokenAmount = eitherAmount;
        // 토큰을 user에게 전달
        tokenA.transfer(swapUser, tokenAmount);
    }

    /*
    DEX user로부터 토큰을 받고 Ether로 교환해 줌
    */
    function tokenToEither(uint tokenAmount) public {
        address swapUser = msg.sender;
        uint eitherAmount = tokenAmount * 1 ether;
        // CSMM (Constant Sum Market Maker)
        tokenA.transferFrom(swapUser, address(this), tokenAmount);
        
        payable(swapUser).transfer(eitherAmount);
    }

    function addLiquidity(uint tokenAmount) payable public {
        uint eitherAmount = msg.value;
        require(eitherAmount == tokenAmount * 1 ether, "Should Ether = TokenA");
        address provider = msg.sender;
        // 사용자 토큰 A를 빼서 거래소 지갑으로 이동시킨다.
        tokenA.transferFrom(provider, address(this), tokenAmount);
        uint lpAmount = tokenAmount;
        // 사용자에게 LP토큰을 지급한다.
        _mint(provider, lpAmount);
    }

    function removeLiquidity(uint lpAmount) public {
        address provider = msg.sender;
        _burn(provider, lpAmount);
        uint tokenAmount = lpAmount;
        uint eitherAmount = lpAmount * 1 ether;
        // 사용자에게 Ether를 지급한다.
        payable(provider).transfer(eitherAmount);
        // 사용자에게 토큰 A를 지급한다.
        tokenA.transfer(provider, tokenAmount);
    }
}