// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SevenTeenTwentyNineProofOfContribution} from "../../src/1729ProofOfContribution.sol";

import "forge-std/Test.sol";
import "./Fixtures.sol";

contract SevenTeenTwentyNineProofOfContributionTest is Test {
    //
    SevenTeenTwentyNineProofOfContribution sbt;

    TestAddresses addresses;
    address[] contributors;
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
        // assert events are emitted correctly
        vm.expectEmit(true, true, true, true);
        emit Events.NewContribution(1, CONTRIB1, URI1);
        vm.expectEmit(true, true, true, true);
        emit Events.NewContribution(2, CONTRIB2, URI2);
        vm.expectEmit(true, true, true, true);
        emit Events.NewContribution(3, CONTRIB3, URI3);
        vm.expectEmit(true, true, true, true);
        emit Events.NewContribution(4, CONTRIB4, URI4);
        vm.expectEmit(true, true, true, true);
        emit Events.NewContribution(5, CONTRIB5, URI5);

        vm.startPrank(addresses.multisig);
        uint256 tokenId1 = sbt.createContribution(CONTRIB1, URI1);
        uint256 tokenId2 = sbt.createContribution(CONTRIB2, URI2);
        uint256 tokenId3 = sbt.createContribution(CONTRIB3, URI3);
        uint256 tokenId4 = sbt.createContribution(CONTRIB4, URI4);
        uint256 tokenId5 = sbt.createContribution(CONTRIB5, URI5);

        // assert token ID increments correctly
        assertEq(tokenId1, 1);
        assertEq(tokenId2, 2);
        assertEq(tokenId3, 3);
        assertEq(tokenId4, 4);
        assertEq(tokenId5, 5);

        (string memory contributionName1,) = sbt.contributions(1);
        (string memory contributionName2,) = sbt.contributions(2);
        (string memory contributionName3,) = sbt.contributions(3);
        (string memory contributionName4,) = sbt.contributions(4);
        (string memory contributionName5,) = sbt.contributions(5);

        // assert contribution name is stored correctly
        assertEq(contributionName1, CONTRIB1);
        assertEq(contributionName2, CONTRIB2);
        assertEq(contributionName3, CONTRIB3);
        assertEq(contributionName4, CONTRIB4);
        assertEq(contributionName5, CONTRIB5);

        // assert contribution URI is stored correctly
        // note that we don't test the URI storage in the struct directly, because
        // this is exercised via the uri(uint256) override which is checked here
        assertEq(sbt.uri(1), URI1);
        assertEq(sbt.uri(2), URI2);
        assertEq(sbt.uri(3), URI3);
        assertEq(sbt.uri(4), URI4);
        assertEq(sbt.uri(5), URI5);
    }

    function test_createContribution_whenNotOwner_shouldRevert() public {
        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.random);
        sbt.createContribution(CONTRIB1, URI1);
    }

    function test_createContribution_whenEmptyName_shouldRevert() public {
        vm.expectRevert("ProofOfContribution: contribution name cannot be empty");

        vm.prank(addresses.multisig);
        sbt.createContribution("", URI1);
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

        vm.prank(addresses.random);
        sbt.issue(addresses.writer1, 1);
    }

    function test_issue_whenContributionDoesNotExist_shouldRevert() public {
        vm.expectRevert("ProofOfContribution: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.issue(addresses.writer1, 1);
    }

    function test_issue_whenPersonAlreadyHoldsSBTOfSameContribution_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        vm.expectRevert("ProofOfContribution: a person can only receive one soulbound token per contribution");

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
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3, addresses.writer4, addresses.writer5];

        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), contributors[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);

        for (uint256 j = 0; j < contributors.length; j++) {
            assertTrue(sbt.hasToken(contributors[j], 1));
        }
    }

    function test_issueBatch_whenNotOwner_shouldRevert() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.random);
        sbt.issueBatch(contributors, 1);
    }

    function test_issueBatch_whenContributionDoesNotExist_shouldRevert() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.expectRevert("ProofOfContribution: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.issueBatch(contributors, 1);
    }

    function test_issueBatch_when100Recipients() public {
        contributors = [
            addresses.writer1,
            addresses.writer2,
            addresses.writer3,
            addresses.writer4,
            addresses.writer5,
            addresses.writer6,
            addresses.writer7,
            addresses.writer8,
            addresses.writer9,
            addresses.writer10,
            addresses.writer11,
            addresses.writer12,
            addresses.writer13,
            addresses.writer14,
            addresses.writer15,
            addresses.writer16,
            addresses.writer17,
            addresses.writer18,
            addresses.writer19,
            addresses.writer20,
            addresses.writer21,
            addresses.writer22,
            addresses.writer23,
            addresses.writer24,
            addresses.writer25,
            addresses.writer26,
            addresses.writer27,
            addresses.writer28,
            addresses.writer29,
            addresses.writer30,
            addresses.writer31,
            addresses.writer32,
            addresses.writer33,
            addresses.writer34,
            addresses.writer35,
            addresses.writer36,
            addresses.writer37,
            addresses.writer38,
            addresses.writer39,
            addresses.writer40,
            addresses.writer41,
            addresses.writer42,
            addresses.writer43,
            addresses.writer44,
            addresses.writer45,
            addresses.writer46,
            addresses.writer47,
            addresses.writer48,
            addresses.writer49,
            addresses.writer50,
            addresses.writer51,
            addresses.writer52,
            addresses.writer53,
            addresses.writer54,
            addresses.writer55,
            addresses.writer56,
            addresses.writer57,
            addresses.writer58,
            addresses.writer59,
            addresses.writer60,
            addresses.writer61,
            addresses.writer62,
            addresses.writer63,
            addresses.writer64,
            addresses.writer65,
            addresses.writer66,
            addresses.writer67,
            addresses.writer68,
            addresses.writer69,
            addresses.writer70,
            addresses.writer71,
            addresses.writer72,
            addresses.writer73,
            addresses.writer74,
            addresses.writer75,
            addresses.writer76,
            addresses.writer77,
            addresses.writer78,
            addresses.writer79,
            addresses.writer80,
            addresses.writer81,
            addresses.writer82,
            addresses.writer83,
            addresses.writer84,
            addresses.writer85,
            addresses.writer86,
            addresses.writer87,
            addresses.writer88,
            addresses.writer89,
            addresses.writer90,
            addresses.writer91,
            addresses.writer92,
            addresses.writer93,
            addresses.writer94,
            addresses.writer95,
            addresses.writer96,
            addresses.writer97,
            addresses.writer98,
            addresses.writer99,
            addresses.writer100
        ];

        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), contributors[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);

        for (uint256 j = 0; j < contributors.length; j++) {
            assertTrue(sbt.hasToken(contributors[j], 1));
        }
    }

    function test_issueBatch_whenGreaterThan100Recipients_shouldRevert() public {
        contributors = [
            addresses.writer1,
            addresses.writer2,
            addresses.writer3,
            addresses.writer4,
            addresses.writer5,
            addresses.writer6,
            addresses.writer7,
            addresses.writer8,
            addresses.writer9,
            addresses.writer10,
            addresses.writer11,
            addresses.writer12,
            addresses.writer13,
            addresses.writer14,
            addresses.writer15,
            addresses.writer16,
            addresses.writer17,
            addresses.writer18,
            addresses.writer19,
            addresses.writer20,
            addresses.writer21,
            addresses.writer22,
            addresses.writer23,
            addresses.writer24,
            addresses.writer25,
            addresses.writer26,
            addresses.writer27,
            addresses.writer28,
            addresses.writer29,
            addresses.writer30,
            addresses.writer31,
            addresses.writer32,
            addresses.writer33,
            addresses.writer34,
            addresses.writer35,
            addresses.writer36,
            addresses.writer37,
            addresses.writer38,
            addresses.writer39,
            addresses.writer40,
            addresses.writer41,
            addresses.writer42,
            addresses.writer43,
            addresses.writer44,
            addresses.writer45,
            addresses.writer46,
            addresses.writer47,
            addresses.writer48,
            addresses.writer49,
            addresses.writer50,
            addresses.writer51,
            addresses.writer52,
            addresses.writer53,
            addresses.writer54,
            addresses.writer55,
            addresses.writer56,
            addresses.writer57,
            addresses.writer58,
            addresses.writer59,
            addresses.writer60,
            addresses.writer61,
            addresses.writer62,
            addresses.writer63,
            addresses.writer64,
            addresses.writer65,
            addresses.writer66,
            addresses.writer67,
            addresses.writer68,
            addresses.writer69,
            addresses.writer70,
            addresses.writer71,
            addresses.writer72,
            addresses.writer73,
            addresses.writer74,
            addresses.writer75,
            addresses.writer76,
            addresses.writer77,
            addresses.writer78,
            addresses.writer79,
            addresses.writer80,
            addresses.writer81,
            addresses.writer82,
            addresses.writer83,
            addresses.writer84,
            addresses.writer85,
            addresses.writer86,
            addresses.writer87,
            addresses.writer88,
            addresses.writer89,
            addresses.writer90,
            addresses.writer91,
            addresses.writer92,
            addresses.writer93,
            addresses.writer94,
            addresses.writer95,
            addresses.writer96,
            addresses.writer97,
            addresses.writer98,
            addresses.writer99,
            addresses.writer100,
            addresses.writer101
        ];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);

        vm.expectRevert("SBT: can not issue more than 100 SBTs in a single transaction");

        sbt.issueBatch(contributors, 1);
    }

    /*//////////////////////////////////////////////////////////////
                        Issuing with value
    //////////////////////////////////////////////////////////////*/

    function test_issueWithValue() public {
        vm.deal(addresses.multisig, 1 ether);

        // check event is emitted
        vm.expectEmit(true, true, true, true);
        emit Events.Issue(address(sbt), addresses.writer1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue{value: 0.1 ether}(addresses.writer1, 1);

        // check ether balance and token ownership
        assertEq(addresses.writer1.balance, 0.1 ether);
        assertTrue(sbt.hasToken(addresses.writer1, 1));
    }

    // @fuzz
    function test_issueWithValue(uint256 _value) public {
        uint256 amountOfEther = bound(_value, 0, 100) * 1 ether; // test up to 100 ether
        vm.deal(addresses.multisig, amountOfEther);

        // check event is emitted
        vm.expectEmit(true, true, true, true);
        emit Events.Issue(address(sbt), addresses.writer1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue{value: amountOfEther}(addresses.writer1, 1);

        // check ether balance and token ownership
        assertEq(addresses.writer1.balance, amountOfEther);
        assertTrue(sbt.hasToken(addresses.writer1, 1));
    }

    function test_issueWithValue_whenRecipientAlreadyHasEther() public {
        vm.deal(addresses.multisig, 1 ether);
        vm.deal(addresses.writer1, 1 ether);

        // check event is emitted
        vm.expectEmit(true, true, true, true);
        emit Events.Issue(address(sbt), addresses.writer1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue{value: 0.1 ether}(addresses.writer1, 1);

        // check ether balance and token ownership
        assertEq(addresses.writer1.balance, 1.1 ether);
        assertTrue(sbt.hasToken(addresses.writer1, 1));
    }

    function test_issueBatchWithValue() public {
        // issue 5 ether to 5 contributors
        vm.deal(addresses.multisig, 5 ether);
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3, addresses.writer4, addresses.writer5];

        // check events are emitted
        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), contributors[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch{value: 5 ether}(contributors, 1);

        // check ether balances and token ownership
        for (uint256 j = 0; j < contributors.length; j++) {
            assertEq(contributors[j].balance, 1 ether);
            assertTrue(sbt.hasToken(contributors[j], 1));
        }
    }

    function test_issueBatchWithValue_whenLeftover() public {
        // issue 10 ether to 97 contributors
        vm.deal(addresses.multisig, 10 ether);
        contributors = [
            addresses.writer1,
            addresses.writer2,
            addresses.writer3,
            addresses.writer4,
            addresses.writer5,
            addresses.writer6,
            addresses.writer7,
            addresses.writer8,
            addresses.writer9,
            addresses.writer10,
            addresses.writer11,
            addresses.writer12,
            addresses.writer13,
            addresses.writer14,
            addresses.writer15,
            addresses.writer16,
            addresses.writer17,
            addresses.writer18,
            addresses.writer19,
            addresses.writer20,
            addresses.writer21,
            addresses.writer22,
            addresses.writer23,
            addresses.writer24,
            addresses.writer25,
            addresses.writer26,
            addresses.writer27,
            addresses.writer28,
            addresses.writer29,
            addresses.writer30,
            addresses.writer31,
            addresses.writer32,
            addresses.writer33,
            addresses.writer34,
            addresses.writer35,
            addresses.writer36,
            addresses.writer37,
            addresses.writer38,
            addresses.writer39,
            addresses.writer40,
            addresses.writer41,
            addresses.writer42,
            addresses.writer43,
            addresses.writer44,
            addresses.writer45,
            addresses.writer46,
            addresses.writer47,
            addresses.writer48,
            addresses.writer49,
            addresses.writer50,
            addresses.writer51,
            addresses.writer52,
            addresses.writer53,
            addresses.writer54,
            addresses.writer55,
            addresses.writer56,
            addresses.writer57,
            addresses.writer58,
            addresses.writer59,
            addresses.writer60,
            addresses.writer61,
            addresses.writer62,
            addresses.writer63,
            addresses.writer64,
            addresses.writer65,
            addresses.writer66,
            addresses.writer67,
            addresses.writer68,
            addresses.writer69,
            addresses.writer70,
            addresses.writer71,
            addresses.writer72,
            addresses.writer73,
            addresses.writer74,
            addresses.writer75,
            addresses.writer76,
            addresses.writer77,
            addresses.writer78,
            addresses.writer79,
            addresses.writer80,
            addresses.writer81,
            addresses.writer82,
            addresses.writer83,
            addresses.writer84,
            addresses.writer85,
            addresses.writer86,
            addresses.writer87,
            addresses.writer88,
            addresses.writer89,
            addresses.writer90,
            addresses.writer91,
            addresses.writer92,
            addresses.writer93,
            addresses.writer94,
            addresses.writer95,
            addresses.writer96,
            addresses.writer97
        ];

        // check events are emitted
        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), contributors[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch{value: 10 ether}(contributors, 1);

        // check ether balances and token ownership
        uint256 expectedAmountReceived = 10 ether / contributors.length;
        uint256 expectedAmountLeftover = 10 ether % contributors.length;

        for (uint256 j = 0; j < contributors.length; j++) {
            assertApproxEqRel(contributors[j].balance, expectedAmountReceived, 0.01e18); // within 1%
            assertTrue(sbt.hasToken(contributors[j], 1));
        }
        assertEq(addresses.multisig.balance, expectedAmountLeftover);
    }

    // @fuzz
    function test_issueBatchWithValue_whenLeftover(uint256 _value) public {
        uint256 amountOfEther = bound(_value, 0, 100) * 1 ether; // test up to 100 ether

        // issue ether to 11 contributors
        vm.deal(addresses.multisig, amountOfEther);
        contributors = [
            addresses.writer1,
            addresses.writer2,
            addresses.writer3,
            addresses.writer4,
            addresses.writer5,
            addresses.writer6,
            addresses.writer7,
            addresses.writer8,
            addresses.writer9,
            addresses.writer10,
            addresses.writer11
        ];

        // check events are emitted
        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Issue(address(sbt), contributors[i], 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch{value: amountOfEther}(contributors, 1);

        // check ether balances and token ownership
        uint256 expectedAmountReceived = amountOfEther / contributors.length;
        uint256 expectedAmountLeftover = amountOfEther % contributors.length;

        for (uint256 j = 0; j < contributors.length; j++) {
            assertApproxEqRel(contributors[j].balance, expectedAmountReceived, 0.01e18); // within 1%
            assertTrue(sbt.hasToken(contributors[j], 1));
        }
        assertEq(addresses.multisig.balance, expectedAmountLeftover);
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

        vm.prank(addresses.random);
        sbt.revoke(addresses.writer1, 1, "did something naughty");
    }

    function test_revoke_whenContributionDoesNotExist_shouldRevert() public {
        vm.expectRevert("ProofOfContribution: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.revoke(addresses.writer1, 1, "did something naughty");
    }

    function test_revokeBatch() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);

        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.Revoke(address(sbt), contributors[i], 1, "did something naughty");
        }

        sbt.revokeBatch(contributors, 1, "did something naughty");

        for (uint256 j = 0; j < contributors.length; j++) {
            assertFalse(sbt.hasToken(contributors[j], 1));
        }
    }

    function test_revokeBatch_whenNotOwner_shouldRevert() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(addresses.random);
        sbt.revokeBatch(contributors, 1, "did something naughty");
    }

    function test_revokeBatch_whenContributionDoesNotExist_shouldRevert() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.expectRevert("ProofOfContribution: no matching contribution found");

        vm.prank(addresses.multisig);
        sbt.revokeBatch(contributors, 1, "did something naughty");
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
        vm.expectRevert("ProofOfContribution: no matching contribution found");

        vm.prank(addresses.writer1);
        sbt.reject(1);
    }

    function test_reject_whenNotOwnerOfToken_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        vm.expectRevert("ProofOfContribution: no matching soulbound token found");

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

    function test_hasToken_whenContributionDoesNotExist_shouldRevert() public {
        vm.expectRevert("ProofOfContribution: no matching contribution found");

        sbt.hasToken(addresses.writer1, 1);
    }

    function test_hasTokenBatch() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);

        bool[] memory hasTokens = sbt.hasTokenBatch(contributors, 1);

        assertEq(hasTokens.length, contributors.length);
        for (uint256 i = 0; i < contributors.length; i++) {
            assertTrue(hasTokens[i]);
        }
    }

    function test_hasTokenBatch_whenContributionDoesNotExist_shouldRevert() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];
        
        vm.expectRevert("ProofOfContribution: no matching contribution found");

        sbt.hasTokenBatch(contributors, 1);
    }

    /*//////////////////////////////////////////////////////////////
                        Nontransferability
    //////////////////////////////////////////////////////////////*/

    function test_safeTransferFrom_shouldRevert() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        vm.expectRevert("ProofOfContribution: soulbound tokens are nontransferable");

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

        vm.expectRevert("ProofOfContribution: soulbound tokens are nontransferable");

        vm.prank(addresses.writer1);
        sbt.safeBatchTransferFrom(addresses.writer1, addresses.writer2, ids, amounts, "");
    }

    function test_setApprovalForAll_shouldRevert() public {
        vm.expectRevert("ProofOfContribution: soulbound tokens are nontransferable");

        sbt.setApprovalForAll(addresses.random, true);
    }

    function test_isApprovedForAll_shouldRevert() public {
        vm.expectRevert("ProofOfContribution: soulbound tokens are nontransferable");

        sbt.isApprovedForAll(addresses.writer1, addresses.random);
    }

    /*//////////////////////////////////////////////////////////////
                        ERC1155 Spec Tests (minus transferability)
    //////////////////////////////////////////////////////////////*/

    function test_issue_adheresToERC1155Spec() public {
        vm.expectEmit(true, true, true, true);
        emit Events.TransferSingle(addresses.multisig, address(0), addresses.writer1, 1, 1);

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
    }

    function test_issueBatch_adheresToERC1155Spec() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.TransferSingle(addresses.multisig, address(0), contributors[i], 1, 1);
        }

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);
    }

    function test_issue_adheresToERC1155Spec_viaBalanceOfBatch() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.createContribution(CONTRIB2, URI2);
        sbt.createContribution(CONTRIB3, URI3);
        sbt.issue(addresses.writer1, 1);
        sbt.issue(addresses.writer1, 2);
        sbt.issue(addresses.writer1, 3);
        sbt.issue(addresses.writer2, 1);
        // don't issue SBT 2 to writer 2
        sbt.issue(addresses.writer2, 3);
        // don't issue SBT 1 to writer 3
        sbt.issue(addresses.writer3, 2);
        sbt.issue(addresses.writer3, 3);
        vm.stopPrank();

        address[] memory accounts = new address[](9);
        accounts[0] = addresses.writer1;
        accounts[1] = addresses.writer1;
        accounts[2] = addresses.writer1;
        accounts[3] = addresses.writer2;
        accounts[4] = addresses.writer2;
        accounts[5] = addresses.writer2;
        accounts[6] = addresses.writer3;
        accounts[7] = addresses.writer3;
        accounts[8] = addresses.writer3;

        uint256[] memory ids = new uint256[](9);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        ids[3] = 1;
        ids[4] = 2;
        ids[5] = 3;
        ids[6] = 1;
        ids[7] = 2;
        ids[8] = 3;

        uint256[] memory expected = new uint256[](9);
        expected[0] = 1;
        expected[1] = 1;
        expected[2] = 1;
        expected[3] = 1;
        expected[4] = 0; // writer 2 does not own SBT 2
        expected[5] = 1;
        expected[6] = 0; // writer 3 does not own SBT 1
        expected[7] = 1;
        expected[8] = 1;

        assertEq(sbt.balanceOfBatch(accounts, ids), expected);
    }

    function test_hasToken_adheresToERC1155Spec() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        assertEq(sbt.balanceOf(addresses.writer1, 1), 1); // ERC1155 native function
        assertTrue(sbt.hasToken(addresses.writer1, 1)); // SBT specific function
    }

    function test_hasTokenBatch_adheresToERC1155Spec() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);

        bool[] memory hasTokens = sbt.hasTokenBatch(contributors, 1); // SBT specific function

        for (uint256 i = 0; i < contributors.length; i++) {
            assertEq(sbt.balanceOf(contributors[i], 1), 1); // ERC1155 native function
            assertTrue(hasTokens[i]);
        }
    }

    function test_revoke_adheresToERC1155Spec() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);

        vm.expectEmit(true, true, true, true);
        emit Events.TransferSingle(addresses.multisig, addresses.writer1, address(0), 1, 1);

        sbt.revoke(addresses.writer1, 1, "did something naughty");
    }

    function test_revokeBatch_adheresToERC1155Spec() public {
        contributors = [addresses.writer1, addresses.writer2, addresses.writer3];

        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issueBatch(contributors, 1);

        for (uint256 i = 0; i < contributors.length; i++) {
            vm.expectEmit(true, true, true, true);
            emit Events.TransferSingle(addresses.multisig, contributors[i], address(0), 1, 1);
        }

        sbt.revokeBatch(contributors, 1, "did something naughty");
    }

    function test_reject_adheresToERC1155Spec() public {
        vm.startPrank(addresses.multisig);
        sbt.createContribution(CONTRIB1, URI1);
        sbt.issue(addresses.writer1, 1);
        vm.stopPrank();

        // note that the operator in the ERC1155 TransferSingle event which gets emitted is
        // the address which owned the SBT, not the contract owner as in revoke / revokeBatch
        vm.expectEmit(true, true, true, true);
        emit Events.TransferSingle(addresses.writer1, addresses.writer1, address(0), 1, 1);

        vm.prank(addresses.writer1);
        sbt.reject(1);
    }
}

library Events {
    //

    /*//////////////////////////////////////////////////////////////
                        SBT
    //////////////////////////////////////////////////////////////*/

    event NewContribution(uint256 indexed tokenId, string contributionName, string contributionUri);

    event Issue(address indexed issuer, address indexed issuee, uint256 indexed tokenId);

    event Revoke(address indexed revoker, address indexed revokee, uint256 indexed tokenId, string reason);

    event Reject(address indexed rejecter, uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                        ERC1155
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
}
