// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoVault {
    // Address of the contract owner
    address public owner;

    // Mapping to store balances of each user
    mapping(address => uint256) private balances;

    // Events for logging actions
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // Constructor: sets deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    // Function 1: Deposit Ether into the vault
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // Function 2: Withdraw Ether from the vault
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    // Function 3: Check user’s personal balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
