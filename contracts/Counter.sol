// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract Counter is Ownable {

    // (요구사항)
    // - ETH 입금할 때마다 숫자가 1 증가
    // - 관리자는 리셋할 수도 있고 ETH 송금할 수도 있음
    // 1. Data
    //  - value: private (contract의 밸런스)
    //  - owner: public
    // 2. Actions
    //  - getValue: public
    //  - increment: public, payable (이게 있어야 eth를 받을 수 있음)
    //  - reset: public (owner라도 외우에 있기 때문에 열려있어야 함), owner만 호출
    //  - withdraw: public, owner만 호
    // 3. Events
    //  - log resets

    uint private value = 0;
    
    event Reset(address owner, uint currentValue);

    modifier minimumCost(uint cost) {
        require(msg.value >= cost * 1 ether, "Should send 1 either cost");
        _;
    }

    function getValue() public view returns (uint){
        return value;
    }

    function increment() public payable minimumCost(1) {
        value++;
    }

    function reset() public onlyOwner {
        emit Reset(msg.sender, value);
        value = 0;
    }

    function widthdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}