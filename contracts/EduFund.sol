// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EduFund - A Decentralized Scholarship Management System
 * @dev Developed by Tushar Ambastha | Unique Project
 */

contract EduFund {
    address public admin;
    uint256 public scholarshipCounter;

    struct Scholarship {
        uint256 id;
        string name;
        string description;
        uint256 totalAmount;
        uint256 availableAmount;
        uint256 minEligibilityScore;
        bool isActive;
        address creator;
    }

    struct Student {
        address wallet;
        string name;
        uint256 score;
        bool registered;
    }

    mapping(uint256 => Scholarship) public scholarships;
    mapping(address => Student) public students;
    mapping(uint256 => address[]) public applicants;

    event ScholarshipCreated(uint256 indexed id, string name, uint256 amount);
    event StudentRegistered(address indexed student, string name);
    event Applied(address indexed student, uint256 indexed scholarshipId);
    event ScholarshipAwarded(uint256 indexed scholarshipId, address indexed student, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyScholarCreator(uint256 _id) {
        require(msg.sender == scholarships[_id].creator, "Only creator can manage this scholarship");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerStudent(string memory _name, uint256 _score) public {
        require(!students[msg.sender].registered, "Student already registered");
        students[msg.sender] = Student(msg.sender, _name, _score, true);
        emit StudentRegistered(msg.sender, _name);
    }

    function createScholarship(
        string memory _name,
        string memory _description,
        uint256 _amount,
        uint256 _minEligibilityScore
    ) public payable {
        require(msg.value == _amount, "Fund must match scholarship amount");

        scholarshipCounter++;
        scholarships[scholarshipCounter] = Scholarship(
            scholarshipCounter,
            _name,
            _description,
            _amount,
            _amount,
            _minEligibilityScore,
            true,
            msg.sender
        );

        emit ScholarshipCreated(scholarshipCounter, _name, _amount);
    }

    function applyForScholarship(uint256 _id) public {
        require(students[msg.sender].registered, "Student not registered");
        require(scholarships[_id].isActive, "Scholarship inactive");
        require(students[msg.sender].score >= scholarships[_id].minEligibilityScore, "Not eligible");

        applicants[_id].push(msg.sender);
        emit Applied(msg.sender, _id);
    }

    function awardScholarship(uint256 _id, address _student, uint256 _amount)
        public
        onlyScholarCreator(_id)
    {
        Scholarship storage s = scholarships[_id];
        require(s.isActive, "Scholarship inactive");
        require(s.availableAmount >= _amount, "Insufficient funds");
        require(students[_student].registered, "Student not registered");

        s.availableAmount -= _amount;
        payable(_student).transfer(_amount);

        emit ScholarshipAwarded(_id, _student, _amount);
    }

    function deactivateScholarship(uint256 _id) public onlyScholarCreator(_id) {
        scholarships[_id].isActive = false;
    }

    function withdrawFunds(uint256 _id, uint256 _amount) public onlyScholarCreator(_id) {
        Scholarship storage s = scholarships[_id];
        require(!s.isActive, "Deactivate scholarship first");
        require(s.availableAmount >= _amount, "Insufficient funds");

        s.availableAmount -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function getApplicants(uint256 _id) public view returns (address[] memory) {
        return applicants[_id];
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
