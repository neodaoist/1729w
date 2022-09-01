// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SevenTeenTwentyNineProofOfContribution} from "../src/SevenTeenTwentyNineProofOfContribution.sol";

import "forge-std/Test.sol";
import "./Fixtures.sol";

contract SBTTest is Test {
    //
    SevenTeenTwentyNineProofOfContribution sbt;

    TestAddresses addresses;
    string URI1 = "ipfs://ABC/1";
    string URI2 = "ipfs://DEF/2";
    string URI3 = "ipfs://GHI/3";
    string URI4 = "ipfs://JKL/4";
    string URI5 = "ipfs://MNO/5";
    string CONTRIB1 = "Cohort 2 - fully participating writer";
    string CONTRIB2 = "Cohort 2 - partially participating writer";
    string CONTRIB3 = "Cohort 2 - reader/voter";
    string CONTRIB4 = "Cohort 2 - auction bidder";
    string CONTRIB5 = "Cohort 2 - winning writer";

    function setUp() public {
        addresses = getAddresses();
        sbt = new SevenTeenTwentyNineProofOfContribution(addresses.multisig);
    }

    /*//////////////////////////////////////////////////////////////
                        Issuing
    //////////////////////////////////////////////////////////////*/

    // TODO decide if we should enforce 1 credential of each type per user or support multiple / max
    // if yes — replace amount of 1 in SBT with something other than a magic number
    // if no — add to functions and events, consider adding an immutable constructor arg for max

    function test_issue() public {
        vm.expectEmit(true, true, true, true);
        emit Events.Issue(address(sbt), address(0xA), 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issue(address(0xA), 1);
        assertTrue(sbt.hasToken(address(0xA), 1));
    }

    function test_issue_whenNotOwner_shouldRevert() public {
        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.issue(address(0xA), 1);
    }

    function test_issue_whenContributionHasNotBeenCreated_shouldRevert() public {
        vm.expectRevert("SBT: No matching contribution found");

        vm.prank(addresses.multisig);
        sbt.issue(addresses.writer1, 1);
    }

    function test_issueBatch() public {
        address[] memory issuees = new address[](3);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);
        issuees[2] = address(0xC);

        for (uint256 i = 0; i < issuees.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), issuees[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issueBatch(issuees, 1);

        for (uint256 j = 0; j < issuees.length; j++) {
            assertTrue(sbt.hasToken(issuees[j], 1));
        }
    }

    function test_issueBatch_whenNotOwner_shouldRevert() public {
        address[] memory issuees = new address[](3);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);
        issuees[2] = address(0xC);

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.issueBatch(issuees, 1);
    }

    /*//////////////////////////////////////////////////////////////
                        Revoking
    //////////////////////////////////////////////////////////////*/

    function test_revoke() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issue(address(0xA), 1);

        vm.expectEmit(true, true, true, true);
        emit Events.Revoke(address(sbt), address(0xA), 1, "did something naughty");

        sbt.revoke(address(0xA), 1, "did something naughty");

        assertFalse(sbt.hasToken(address(0xA), 1));
    }

    function test_revoke_whenNotOwner_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issue(address(0xA), 1);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.revoke(address(0xA), 1, "did something naughty");
    }

    function test_revoke_whenContributionHasNotBeenCreated_shouldRevert() public {
        vm.expectRevert("SBT: No matching contribution found");

        vm.prank(addresses.multisig);
        sbt.revoke(addresses.writer1, 1, "did something naughty");
    }

    function test_revokeBatch() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);

        address[] memory issuees = new address[](3);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);
        issuees[2] = address(0xC);
        sbt.issueBatch(issuees, 1);

        for (uint256 i = 0; i < issuees.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Revoke(address(sbt), issuees[i], 1, "did something naughty");
        }

        sbt.revokeBatch(issuees, 1, "did something naughty");

        for (uint256 j = 0; j < issuees.length; j++) {
            assertFalse(sbt.hasToken(issuees[j], 1));
        }
    }    

    function test_revokeBatch_whenNotOwner_shouldRevert() public {
        address[] memory issuees = new address[](3);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);
        issuees[2] = address(0xC);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issueBatch(issuees, 1);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.revokeBatch(issuees, 1, "did something naughty");
    }

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function test_hasToken() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issue(address(0xA), 1);

        assertTrue(sbt.hasToken(address(0xA), 1));
    }

    function test_hasTokenBatch() public {
        address[] memory issuees = new address[](3);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);
        issuees[2] = address(0xC);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issueBatch(issuees, 1);

        bool[] memory hasTokens = sbt.hasTokenBatch(issuees, 1);

        assertEq(hasTokens.length, issuees.length);
        for (uint256 i = 0; i < issuees.length; i++) {
            assertTrue(hasTokens[i]);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Create Contribution / URI Storage
    //////////////////////////////////////////////////////////////*/

    function test_createContribution() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.createContribution(2, CONTRIB2, URI2);
        sbt.createContribution(3, CONTRIB3, URI3);
        sbt.createContribution(4, CONTRIB4, URI4);
        sbt.createContribution(5, CONTRIB5, URI5);

        (string memory contributionName1, , ) = sbt.contributions(1);
        (string memory contributionName2, , ) = sbt.contributions(2);
        (string memory contributionName3, , ) = sbt.contributions(3);
        (string memory contributionName4, , ) = sbt.contributions(4);
        (string memory contributionName5, , ) = sbt.contributions(5);

        assertEq(contributionName1, CONTRIB1);
        assertEq(contributionName2, CONTRIB2);
        assertEq(contributionName3, CONTRIB3);
        assertEq(contributionName4, CONTRIB4);
        assertEq(contributionName5, CONTRIB5);

        assertEq(sbt.uri(1), URI1);
        assertEq(sbt.uri(2), URI2);
        assertEq(sbt.uri(3), URI3);
        assertEq(sbt.uri(4), URI4);
        assertEq(sbt.uri(5), URI5);
    }

    function test_createContribution_whenNotOwner_shouldRevert() public {
        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // random EOA
        sbt.createContribution(1, CONTRIB1, URI1);
    }

    function test_createContribution_whenAlreadyExists_shouldRevert() public {    
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);

        vm.expectRevert("SBT: Contribution already created");

        sbt.createContribution(1, CONTRIB2, URI2);
    }

    /*//////////////////////////////////////////////////////////////
                        ERC1155 Spec Adherance
    //////////////////////////////////////////////////////////////*/

    function test_issue_AdheresToERC1155Spec() public {
        vm.expectEmit(true, true, true, true);
        emit Events.TransferSingle(addresses.multisig, address(0), address(0xA), 1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issue(address(0xA), 1);
    }

    // TODO issueBatch, revoke, revokeBatch

    function test_hasToken_AdheresToERC1155Spec() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(1, CONTRIB1, URI1);
        sbt.issue(address(0xA), 1);

        assertEq(sbt.balanceOf(address(0xA), 1), 1);
        assertTrue(sbt.hasToken(address(0xA), 1));
    }

    // TODO hasTokenBatch
}

// TODO DRY up via an Event-specific library
library Events {
    //

    /*//////////////////////////////////////////////////////////////
                        SBT
    //////////////////////////////////////////////////////////////*/

    event Issue(address indexed _issuer, address indexed _issuee, uint256 _tokenId);

    event Revoke(address indexed _revoker, address indexed _revokee, uint256 _tokenId, string _reason);

    /*//////////////////////////////////////////////////////////////
                        ERC1155
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
}
