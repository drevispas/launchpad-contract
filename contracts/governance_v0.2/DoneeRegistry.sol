// src/contracts/registry/DoneeRegistry.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title DoneeRegistry
 * @notice Manages registration and information for donation recipients in the launchpad ecosystem
 * @dev Implements role-based access control and pausable functionality for security
 */
contract DoneeRegistry is AccessControl, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

    // Struct to store donee information
    struct DoneeInfo {
        string name;                // Name of the donee organization or individual
        string description;         // Detailed description of the donee
        string[] socialLinks;       // Array of social media or website links
        address walletAddress;      // Wallet address to receive donations
        uint256 totalReceived;      // Total amount of tokens received through donations
        bool isActive;             // Flag to indicate if the donee is currently active
        uint256 registrationDate;   // Timestamp when the donee was registered
    }

    // State variables
    EnumerableSet.AddressSet private _registeredDonees;           // Set of registered donee addresses
    mapping(address => DoneeInfo) private _doneeInfo;            // Mapping from donee address to their information

    // Events
    event DoneeRegistered(address indexed donee, string name, uint256 timestamp);
    event DoneeUpdated(address indexed donee, string name, uint256 timestamp);
    event DoneeDeactivated(address indexed donee, uint256 timestamp);
    event DonationReceived(address indexed donee, uint256 amount, uint256 timestamp);

    /**
     * @dev Constructor to initialize the contract and set up initial roles
     * @param admin Address of the initial admin
     */
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    /**
     * @notice Registers a new donee in the system
     * @param donee Address of the donee to register
     * @param name Name of the donee
     * @param description Description of the donee
     * @param socialLinks Array of social media links
     * @dev Only accounts with REGISTRAR_ROLE can register new donees
     */
    function registerDonee(
        address donee,
        string memory name,
        string memory description,
        string[] memory socialLinks
    ) external onlyRole(REGISTRAR_ROLE) whenNotPaused {
        require(donee != address(0), "Invalid donee address");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(!_registeredDonees.contains(donee), "Donee already registered");

        DoneeInfo storage newDonee = _doneeInfo[donee];
        newDonee.name = name;
        newDonee.description = description;
        newDonee.socialLinks = socialLinks;
        newDonee.walletAddress = donee;
        newDonee.isActive = true;
        newDonee.registrationDate = block.timestamp;
        newDonee.totalReceived = 0;

        _registeredDonees.add(donee);

        emit DoneeRegistered(donee, name, block.timestamp);
    }

    /**
     * @notice Updates information for an existing donee
     * @param donee Address of the donee to update
     * @param name Updated name
     * @param description Updated description
     * @param socialLinks Updated social links
     */
    function updateDoneeInfo(
        address donee,
        string memory name,
        string memory description,
        string[] memory socialLinks
    ) external onlyRole(REGISTRAR_ROLE) whenNotPaused {
        require(_registeredDonees.contains(donee), "Donee not registered");
        require(bytes(name).length > 0, "Name cannot be empty");

        DoneeInfo storage doneeInfo = _doneeInfo[donee];
        doneeInfo.name = name;
        doneeInfo.description = description;
        doneeInfo.socialLinks = socialLinks;

        emit DoneeUpdated(donee, name, block.timestamp);
    }

    /**
     * @notice Retrieves information about a specific donee
     * @param donee Address of the donee
     * @return DoneeInfo struct containing all donee information
     */
    function getDoneeInfo(address donee) external view returns (DoneeInfo memory) {
        require(_registeredDonees.contains(donee), "Donee not registered");
        return _doneeInfo[donee];
    }

    /**
     * @notice Records a donation received by a donee
     * @param donee Address of the donee
     * @param amount Amount of tokens received
     * @dev Only callable by authorized contracts (e.g., TreasuryVault)
     */
    function recordDonation(address donee, uint256 amount) 
        external 
        onlyRole(ADMIN_ROLE) 
        whenNotPaused 
    {
        require(_registeredDonees.contains(donee), "Donee not registered");
        require(_doneeInfo[donee].isActive, "Donee is not active");

        _doneeInfo[donee].totalReceived += amount;
        emit DonationReceived(donee, amount, block.timestamp);
    }

    /**
     * @notice Deactivates a donee from receiving further donations
     * @param donee Address of the donee to deactivate
     */
    function deactivateDonee(address donee) 
        external 
        onlyRole(ADMIN_ROLE) 
        whenNotPaused 
    {
        require(_registeredDonees.contains(donee), "Donee not registered");
        require(_doneeInfo[donee].isActive, "Donee already deactivated");

        _doneeInfo[donee].isActive = false;
        emit DoneeDeactivated(donee, block.timestamp);
    }

    /**
     * @notice Returns the total number of registered donees
     * @return uint256 Number of registered donees
     */
    function getTotalDonees() external view returns (uint256) {
        return _registeredDonees.length();
    }

    /**
     * @notice Returns a list of all registered donee addresses
     * @return Array of donee addresses
     */
    function getAllDonees() external view returns (address[] memory) {
        uint256 length = _registeredDonees.length();
        address[] memory donees = new address[](length);
        
        for (uint256 i = 0; i < length; i++) {
            donees[i] = _registeredDonees.at(i);
        }
        
        return donees;
    }

    /**
     * @notice Pauses all non-view functions in the contract
     * @dev Only callable by admin
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all non-view functions in the contract
     * @dev Only callable by admin
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}