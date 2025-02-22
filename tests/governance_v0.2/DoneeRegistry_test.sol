// src/contracts/test/TestDoneeRegistry.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../contracts/governance_v0.2/DoneeRegistry.sol";

/**
 * @title TestDoneeRegistry
 * @notice Test contract for DoneeRegistry functionality
 * @dev Uses assert statements for testing. Run in Remix IDE with deployment of both contracts
 */
contract TestDoneeRegistry {
    // Test contract instances
    DoneeRegistry private doneeRegistry;
    
    // Test addresses (will be filled with msg.sender and derived addresses)
    address private admin;
    address private registrar;
    address private testDonee1;
    address private testDonee2;
    
    // Test data
    string private constant TEST_NAME = "Test Charity";
    string private constant TEST_DESCRIPTION = "A test charity organization";
    string[] private testSocialLinks;
    
    // Events for test results
    event TestResult(string testName, bool passed);
    
    constructor() {
        // Initialize test addresses
        admin = msg.sender;
        registrar = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, "registrar")))));
        testDonee1 = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, "donee1")))));
        testDonee2 = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, "donee2")))));
        
        // Initialize test data
        testSocialLinks = new string[](2);
        testSocialLinks[0] = "https://twitter.com/testcharity";
        testSocialLinks[1] = "https://testcharity.org";
        
        // Deploy DoneeRegistry
        doneeRegistry = new DoneeRegistry(admin);
    }

    /**
     * @notice Runs all tests in sequence
     */
    function runAllTests() external {
        testInitialState();
        testRoleManagement();
        testDoneeRegistration();
        testDoneeUpdate();
        testDonationRecording();
        testDeactivation();
        testEnumeration();
        testPausability();
    }

    /**
     * @notice Tests the initial state of the contract
     */
    function testInitialState() public {
        bool hasAdminRole = doneeRegistry.hasRole(doneeRegistry.DEFAULT_ADMIN_ROLE(), admin);
        emit TestResult("Initial Admin Role Check", hasAdminRole);
        
        uint256 totalDonees = doneeRegistry.getTotalDonees();
        emit TestResult("Initial Donee Count", totalDonees == 0);
    }

    /**
     * @notice Tests role management functionality
     */
    function testRoleManagement() public {
        // Grant registrar role
        doneeRegistry.grantRole(doneeRegistry.REGISTRAR_ROLE(), registrar);
        
        bool hasRegistrarRole = doneeRegistry.hasRole(doneeRegistry.REGISTRAR_ROLE(), registrar);
        emit TestResult("Registrar Role Assignment", hasRegistrarRole);
    }

    /**
     * @notice Tests donee registration process
     */
    function testDoneeRegistration() public {
        // Switch to registrar account (simulate in Remix by changing account)
        doneeRegistry.registerDonee(
            testDonee1,
            TEST_NAME,
            TEST_DESCRIPTION,
            testSocialLinks
        );
        
        DoneeRegistry.DoneeInfo memory info = doneeRegistry.getDoneeInfo(testDonee1);
        
        bool registrationSuccessful = 
            keccak256(abi.encodePacked(info.name)) == keccak256(abi.encodePacked(TEST_NAME)) &&
            info.walletAddress == testDonee1 &&
            info.isActive == true;
            
        emit TestResult("Donee Registration", registrationSuccessful);
    }

    /**
     * @notice Tests donee information update functionality
     */
    function testDoneeUpdate() public {
        string memory newName = "Updated Charity";
        string memory newDescription = "Updated description";
        
        doneeRegistry.updateDoneeInfo(
            testDonee1,
            newName,
            newDescription,
            testSocialLinks
        );
        
        DoneeRegistry.DoneeInfo memory info = doneeRegistry.getDoneeInfo(testDonee1);
        
        bool updateSuccessful = 
            keccak256(abi.encodePacked(info.name)) == keccak256(abi.encodePacked(newName)) &&
            keccak256(abi.encodePacked(info.description)) == keccak256(abi.encodePacked(newDescription));
            
        emit TestResult("Donee Update", updateSuccessful);
    }

    /**
     * @notice Tests donation recording functionality
     */
    function testDonationRecording() public {
        uint256 donationAmount = 1000;
        
        doneeRegistry.recordDonation(testDonee1, donationAmount);
        
        DoneeRegistry.DoneeInfo memory info = doneeRegistry.getDoneeInfo(testDonee1);
        emit TestResult("Donation Recording", info.totalReceived == donationAmount);
    }

    /**
     * @notice Tests donee deactivation functionality
     */
    function testDeactivation() public {
        doneeRegistry.deactivateDonee(testDonee1);
        
        DoneeRegistry.DoneeInfo memory info = doneeRegistry.getDoneeInfo(testDonee1);
        emit TestResult("Donee Deactivation", info.isActive == false);
    }

    /**
     * @notice Tests enumeration functions
     */
    function testEnumeration() public {
        // Register another donee for testing
        doneeRegistry.registerDonee(
            testDonee2,
            "Second Charity",
            "Another test charity",
            testSocialLinks
        );
        
        uint256 totalDonees = doneeRegistry.getTotalDonees();
        address[] memory allDonees = doneeRegistry.getAllDonees();
        
        bool enumerationCorrect = 
            totalDonees == 2 &&
            allDonees.length == 2;
            
        emit TestResult("Donee Enumeration", enumerationCorrect);
    }

    /**
     * @notice Tests pause functionality
     */
    function testPausability() public {
        // Test pause
        doneeRegistry.pause();
        
        bool testPassed = true;
        try doneeRegistry.registerDonee(
            address(0x123),
            "Test",
            "Test",
            testSocialLinks
        ) {
            testPassed = false; // Should not reach here
        } catch {
            // Expected to catch error
        }
        
        // Unpause for other tests
        doneeRegistry.unpause();
        
        emit TestResult("Pausability", testPassed);
    }

    /**
     * @notice Helper function to verify expected revert cases
     * @param testName Name of the test case
     * @param shouldRevert Whether the test should revert
     * @param testCode Function to execute
     */
    function expectRevert(
        string memory testName,
        bool shouldRevert,
        function() external testCode
    ) internal {
        bool testPassed = false;
        try testCode() {
            testPassed = !shouldRevert;
        } catch {
            testPassed = shouldRevert;
        }
        emit TestResult(testName, testPassed);
    }
}