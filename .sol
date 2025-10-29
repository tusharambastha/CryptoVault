
pragma solidity ^0.8.0;

contract CryptoVault {
    
    address public owner;

    
    mapping(address => uint256) private balances;

    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    
    constructor() {
        owner = msg.sender;
    }


    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawn(msg.sender, _amount);
    }


    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
