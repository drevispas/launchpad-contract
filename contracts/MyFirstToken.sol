// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract MyFirstToken {

    string public name = "My First Token";
    string public symbol = "MFT";
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

    /*
    사용자 A가 DEX 를 통해서 토큰 X, Y를 swap 하려고 할 때,
    토큰 스왑에 대해서 approve 창이 뜸. 이것이 source token 안에 allowances[owner][dex] 를 설정하는 과정임
    allowances 가 설정되면 DEX 가 X.transferFrom(owner, dex, amount), Y.transfer(owner, amount) 을 호출
    */
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


}