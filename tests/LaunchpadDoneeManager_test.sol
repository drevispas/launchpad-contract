// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/LaunchpadDoneeManager.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract LaunchpadDoneeManagerTest {

    LaunchpadDoneeManager private launchpadManager;
    address private owner;
    address private testDonee1;
    address private testDonee2;

    string[] private testTags;
    string[] private testSocialLinks;



    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        owner = address(this);
        testDonee1 = address(0x1111111111111111111111111111111111111111);
        testDonee2 = address(0x2222222222222222222222222222222222222222);

        testTags = new string[](3);
        testTags[0] = "endangered";
        testTags[1] = "animal";

        testSocialLinks = new string[](4);
        testSocialLinks[0] = "https://x.com/111";
        testSocialLinks[1] = "https://y.com/111";
        testSocialLinks[2] = "https://z.com/111";
    }

    function beforeEach() public {
        launchpadManager = new LaunchpadDoneeManager();
    }

    function testAddDonee() public {
        launchpadManager.addDonee(
            testDonee1,
            "Donee1", 
            "Donee1's project", 
            "Donne1 is awsome.", 
            testTags, 
            testSocialLinks
        );
        // todo: string[] 은 어떻게 받지?
        (
            string memory name,
            string memory projectTitle,
            string memory description,
            bool isActive,
            uint256 lastUpdated
        ) = launchpadManager.donees(testDonee1);
        Assert.equal(name, "Donee1", "Name should match");
        Assert.equal(isActive, true, "Donee should be active");
        Assert.equal(launchpadManager.getDoneeCount(), 1, "Donee count should be 1");
    }

    function testUpdateDonee() public {
        // First add a donee
        launchpadManager.addDonee(
            testDonee1,
            "John Doe",
            "Test Project",
            "Test Description",
            testTags,
            testSocialLinks
        );
        
        // Then update it
        launchpadManager.updateDonee(
            testDonee1,
            "Jane Doe",
            "Updated Project",
            "Updated Description",
            testTags,
            testSocialLinks
        );
        
        (string memory name,,,bool isActive,) = launchpadManager.donees(testDonee1);
        Assert.equal(name, "Jane Doe", "Updated name should match");
        Assert.equal(isActive, true, "Donee should remain active");
    }

    function testToggleDoneeStatus() public {
        // Add a donee first
        launchpadManager.addDonee(
            testDonee1,
            "John Doe",
            "Test Project",
            "Test Description",
            testTags,
            testSocialLinks
        );
        
        // Toggle status
        launchpadManager.toggleDoneeStatus(testDonee1);
        Assert.equal(launchpadManager.isDoneeActive(testDonee1), false, "Status should be toggled to inactive");
        
        // Toggle status back
        launchpadManager.toggleDoneeStatus(testDonee1);
        Assert.equal(launchpadManager.isDoneeActive(testDonee1), true, "Status should be toggled back to active");
    }

    function testFailDuplicateDonee() public {
        launchpadManager.addDonee(
            testDonee1,
            "John Doe",
            "Test Project",
            "Test Description",
            testTags,
            testSocialLinks
        );
        
        // This should fail
        try launchpadManager.addDonee(
            testDonee1,
            "Duplicate Donee",
            "Test Project",
            "Test Description",
            testTags,
            testSocialLinks
        ) {
            Assert.ok(false, "Should have failed on duplicate donee");
        } catch Error(string memory error) {
            Assert.equal(error, "Donee already exists", "Wrong error message");
        }
    }

    function testFailNonExistentDoneeUpdate() public {
        try launchpadManager.updateDonee(
            testDonee2,
            "Non Existent",
            "Test Project",
            "Test Description",
            testTags,
            testSocialLinks
        ) {
            Assert.ok(false, "Should have failed on non-existent donee");
        } catch Error(string memory error) {
            Assert.equal(error, "Donee does not exist", "Wrong error message");
        }
    }

    // Assertions:
    // Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    // Assert.ok(2 == 2, 'should be true');
    // Assert.greaterThan(uint(2), uint(1), "2 should be greater than to 1");
    // Assert.lesserThan(uint(2), uint(3), "2 should be lesser than to 3");
    // Assert.notEqual(uint(1), uint(1), "1 should not be equal to 1");
    // Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
    // Assert.equal(msg.value, 100, "Invalid value");
}