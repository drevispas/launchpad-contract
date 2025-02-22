// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LaunchpadDoneeManager is Ownable(msg.sender) {

    // Struct to store donee information
    struct Donee {
        string name;
        string projectTitle;
        string description;
        string[] tags;
        string[] socialLinks;
        bool isActive;
        uint256 lastUpdated;
    }
    
    // State variables
    mapping(address => Donee) public donees;
    address[] public doneeAddresses;
    
    // Events for tracking donee management
    event DoneeAdded(address doneeAddress, string name);
    event DoneeUpdated(address doneeAddress);
    event DoneeStatusChanged(address doneeAddress, bool isActive);
    
    // Function to add new donee
    function addDonee(
        address doneeAddress,
        string memory name,
        string memory projectTitle,
        string memory description,
        string[] memory tags,
        string[] memory socialLinks
    ) external onlyOwner {
        require(donees[doneeAddress].lastUpdated == 0, "Donee already exists");
        
        donees[doneeAddress] = Donee({
            name: name,
            projectTitle: projectTitle,
            description: description,
            tags: tags,
            socialLinks: socialLinks,
            isActive: true,
            lastUpdated: block.timestamp
        });
        
        doneeAddresses.push(doneeAddress);
        emit DoneeAdded(doneeAddress, name);
    }
    
    // Function to update donee information
    function updateDonee(
        address doneeAddress,
        string memory name,
        string memory projectTitle,
        string memory description,
        string[] memory tags,
        string[] memory socialLinks
    ) external onlyOwner {
        require(donees[doneeAddress].lastUpdated != 0, "Donee does not exist");
        
        Donee storage donee = donees[doneeAddress];
        donee.name = name;
        donee.projectTitle = projectTitle;
        donee.description = description;
        donee.tags = tags;
        donee.socialLinks = socialLinks;
        donee.lastUpdated = block.timestamp;
        
        emit DoneeUpdated(doneeAddress);
    }
    
    // Function to toggle donee status
    function toggleDoneeStatus(address doneeAddress) external onlyOwner {
        require(donees[doneeAddress].lastUpdated != 0, "Donee does not exist");
        
        donees[doneeAddress].isActive = !donees[doneeAddress].isActive;
        emit DoneeStatusChanged(doneeAddress, donees[doneeAddress].isActive);
    }
    
    // Function to check if donee is active
    function isDoneeActive(address doneeAddress) external view returns (bool) {
        return donees[doneeAddress].isActive;
    }
    
    // Function to get all donee addresses
    function getAllDoneeAddresses() external view returns (address[] memory) {
        return doneeAddresses;
    }
    
    // Function to get donee count
    function getDoneeCount() external view returns (uint256) {
        return doneeAddresses.length;
    }
}