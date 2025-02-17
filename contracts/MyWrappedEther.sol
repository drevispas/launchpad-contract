// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract MyWrappedEther {

    string public name = "My Wrapped Ether Token";
    string public symbol = "MWET";
    uint public decimals = 18;
    uint public totalSupply = 0;

    mapping(address owner => uint balance) public balances;
    mapping(address owner => mapping(address spender => uint amount)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    modifier enoughBalance(address owner, uint amount) {
        require(balances[owner] >= amount, "Not enought balance");
        _;
    }

    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    function transfer(address to, uint amount) public enoughBalance(msg.sender, amount) returns (bool successful) {
        address from = msg.sender;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function transferFrom(address owner, address to, uint amount) public enoughBalance(owner, amount) returns (bool) {
        address spender = msg.sender;
        require(allowances[owner][spender] >= amount, "Not enough allowance");
        balances[owner] -= amount;
        balances[to] += amount;
        allowances[owner][spender] -= amount;
        emit Transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        address owner = msg.sender;
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return allowances[owner][spender];
    }

    // ETH -> MWET
    function deposit() public payable returns (bool) {
        address owner = msg.sender;
        uint ethAmount = msg.value;
        uint amount = ethAmount;
        totalSupply += amount;
        balances[owner] += amount;
        emit Transfer(address(0), owner, amount);
        return true;
    }

    // MWET -> ETH
    function withdraw(uint amount) public enoughBalance(msg.sender, amount) returns (bool) {
        address owner = msg.sender;
        uint ethAmount = amount;
        totalSupply -= amount;
        balances[owner] -= amount;
        payable(owner).transfer(ethAmount);
        emit Transfer(owner, address(0), amount);
        return true;
    }
}