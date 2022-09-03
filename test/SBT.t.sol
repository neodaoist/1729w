// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SevenTeenTwentyNineProofOfContribution} from "../src/1729ProofOfContribution.sol";

import "forge-std/Test.sol";
import "./Fixtures.sol";

contract SBTTest is Test {
    //
    SevenTeenTwentyNineProofOfContribution sbt;

    TestAddresses addresses;
    address[] issuees;
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
                        Create Contribution / URI Storage
    //////////////////////////////////////////////////////////////*/

    function test_createContribution() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.createContribution(CONTRIB2, URI2);
        sbt.createContribution(CONTRIB3, URI3);
        sbt.createContribution(CONTRIB4, URI4);
        sbt.createContribution(CONTRIB5, URI5);

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

        vm.prank(addresses.randomEOA);
        sbt.createContribution(CONTRIB1, URI1);
    }

    /*//////////////////////////////////////////////////////////////
                        Issuing
    //////////////////////////////////////////////////////////////*/

    function test_issue() public {
        vm.expectEmit(true, true, true, true);
        emit Events.Issue(address(sbt), addresses.writer1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        assertTrue(sbt.hasToken(addresses.writer1, 1));
    }

    function test_issue_whenNotOwner_shouldRevert() public {
        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.randomEOA);
        sbt.issue(addresses.writer1, 1);
    }

    function test_issue_whenContributionDoesNotExist_shouldRevert() public {
        vm.expectRevert("SBT: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.issue(addresses.writer1, 1);
    }

    function test_issue_whenPersonAlreadyHoldsSBTOfSameContribution_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        
        vm.expectRevert("SBT: a person can only receive one SBT per contribution");
        
        sbt.issue(addresses.writer1, 1);
    }

    function test_issue_whenMultipleContributionsToSamePerson() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.createContribution(CONTRIB2, URI2);
        sbt.createContribution(CONTRIB3, URI3);

        // no revert bc different contributions
        sbt.issue(addresses.writer1, 1);
        sbt.issue(addresses.writer1, 2);
        sbt.issue(addresses.writer1, 3);
    }

    function test_issueBatch() public {
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        for (uint256 i = 0; i < issuees.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), issuees[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(issuees, 1);

        for (uint256 j = 0; j < issuees.length; j++) {
            assertTrue(sbt.hasToken(issuees[j], 1));
        }
    }

    function test_issueBatch_whenNotOwner_shouldRevert() public {
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.randomEOA);
        sbt.issueBatch(issuees, 1);
    }

    function test_issueBatch_whenContributionDoesNotExist_shouldRevert() public {
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.expectRevert("SBT: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.issueBatch(issuees, 1);
    }

    /*//////////////////////////////////////////////////////////////
                        Revoking
    //////////////////////////////////////////////////////////////*/

    function test_revoke() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        vm.expectEmit(true, true, true, true);
        emit Events.Revoke(address(sbt), addresses.writer1, 1, "did something naughty");

        sbt.revoke(addresses.writer1, 1, "did something naughty");

        assertFalse(sbt.hasToken(addresses.writer1, 1));
    }

    function test_revoke_whenNotOwner_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.randomEOA);
        sbt.revoke(addresses.writer1, 1, "did something naughty");
    }

    function test_revoke_whenContributionDoesNotExist_shouldRevert() public {
        vm.expectRevert("SBT: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.revoke(addresses.writer1, 1, "did something naughty");
    }

    function test_revokeBatch() public {
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
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
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(issuees, 1);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.randomEOA);
        sbt.revokeBatch(issuees, 1, "did something naughty");
    }

    function test_revokeBatch_whenContributionDoesNotExist_shouldRevert() public {
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.expectRevert("SBT: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.revokeBatch(issuees, 1, "did something naughty");
    }

    /*//////////////////////////////////////////////////////////////
                        Rejecting
    //////////////////////////////////////////////////////////////*/

    function test_reject() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        assertTrue(sbt.hasToken(addresses.writer1, 1));

        vm.expectEmit(true, true, true, true);
        emit Events.Reject(addresses.writer1, 1);

        vm.prank(addresses.writer1);
        sbt.reject(1);

        assertFalse(sbt.hasToken(addresses.writer1, 1));
    }

    function test_reject_whenContributionDoesNotExist_shouldRevert() public {
        vm.expectRevert("SBT: no matching contribution found");

        vm.prank(addresses.writer1);
        sbt.reject(1);    
    }

    function test_reject_whenNotOwnerOfToken_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        vm.expectRevert("SBT: no matching soulbound token found");

        vm.prank(addresses.writer2);
        sbt.reject(1);    
    }

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function test_hasToken() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        assertTrue(sbt.hasToken(addresses.writer1, 1));
    }

    function test_hasTokenBatch() public {
        issuees = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(issuees, 1);

        bool[] memory hasTokens = sbt.hasTokenBatch(issuees, 1);

        assertEq(hasTokens.length, issuees.length);
        for (uint256 i = 0; i < issuees.length; i++) {
            assertTrue(hasTokens[i]);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Nontransferability
    //////////////////////////////////////////////////////////////*/

    function test_safeTransferFrom_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        vm.expectRevert("SBT: soulbound tokens are nontransferable");

        vm.prank(addresses.writer1);
        sbt.safeTransferFrom(addresses.writer1, addresses.writer2, 1, 1, "");
    }

    function test_safeBatchTransferFrom_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.createContribution(CONTRIB2, URI2);
        sbt.createContribution(CONTRIB3, URI3);
        sbt.issue(addresses.writer1, 1);
        sbt.issue(addresses.writer1, 2);
        sbt.issue(addresses.writer1, 3);
        vm.stopPrank();

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1;
        amounts[1] = 2;
        amounts[2] = 3;

        vm.expectRevert("SBT: soulbound tokens are nontransferable");

        vm.prank(addresses.writer1);
        sbt.safeBatchTransferFrom(addresses.writer1, addresses.writer2, ids, amounts, "");
    }

    /*//////////////////////////////////////////////////////////////
                        ERC1155 Spec Adherance
    //////////////////////////////////////////////////////////////*/

    function test_issue_AdheresToERC1155Spec() public {
        vm.expectEmit(true, true, true, true);
        emit Events.TransferSingle(addresses.multisig, address(0), addresses.writer1, 1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
    }

    // TODO issueBatch, revoke, revokeBatch

    function test_hasToken_AdheresToERC1155Spec() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        assertEq(sbt.balanceOf(addresses.writer1, 1), 1);
        assertTrue(sbt.hasToken(addresses.writer1, 1));
    }

    // TODO hasTokenBatch
}

// TODO DRY up via an Event-specific library
library Events {
    //

    /*//////////////////////////////////////////////////////////////
                        SBT
    //////////////////////////////////////////////////////////////*/

    event Issue(address indexed _issuer, address indexed _issuee, uint256 indexed _tokenId);

    event Revoke(address indexed _revoker, address indexed _revokee, uint256 indexed _tokenId, string _reason);

    event Reject(address indexed _rejecter, uint256 indexed _tokenId);

    /*//////////////////////////////////////////////////////////////
                        ERC1155
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
}
