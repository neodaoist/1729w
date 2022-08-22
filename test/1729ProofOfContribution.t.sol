// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
// import {OneSevenTwoNineProofOfContribution} from "../src/1729ProofOfContribution.sol";
import {SBTExample} from "../src/SBTExample.sol";

contract SBTTest is Test {
    //
    // OneSevenTwoNineProofOfContribution contribution;
    SBTExample sbt;

    function setUp() public {
        // contribution = new OneSevenTwoNineProofOfContribution();
        sbt = new SBTExample();
    }

    // TODO add onlyOwner protection to Issuing and Revoking

    /*//////////////////////////////////////////////////////////////
                        Issuing
    //////////////////////////////////////////////////////////////*/

    // Issue initial 1729 Writers Proof of Contribution SBTs to participating members
    // Issue 1729 Writers Proof of Contribution SBTs to writers for full participation
    // Issue 1729 Writers Proof of Contribution SBTs to writers for partial participation
    // Issue 1729 Writers Proof of Contribution SBTs to members for voting
    // Issue 1729 Writers Proof of Contribution SBTs to the winning writers
    //

    // TODO should we enforce 1 credential of each type per user ?

    function test_issue() public {
        vm.expectEmit(true, true, true, true);
        emit Events.Issue(address(sbt), address(0xA), 1);

        sbt.issue(address(0xA), 1);
        assertTrue(sbt.hasToken(address(0xA), 1));
    }

    function test_issue_whenNotOwner_shouldRevert() public {
        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.issue(address(0xA), 1);
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
        sbt.issue(address(0xA), 1);

        vm.expectEmit(true, true, true, true);
        emit Events.Revoke(address(sbt), address(0xA), 1, "did something naughty");

        sbt.revoke(address(0xA), 1, "did something naughty");

        assertFalse(sbt.hasToken(address(0xA), 1));
    }

    function test_revoke_whenNotOwner_shouldRevert() public {
        sbt.issue(address(0xA), 1);

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.revoke(address(0xA), 1, "did something naughty");
    }

    function test_revokeBatch() public {
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

        sbt.issueBatch(issuees, 1);

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(address(0xABCD)); // from random EOA
        sbt.revokeBatch(issuees, 1, "did something naughty");
    }

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function test_hasToken() public {
        sbt.issue(address(0xA), 1);

        assertTrue(sbt.hasToken(address(0xA), 1));
    }

    function test_hasTokenBatch() public {
        address[] memory issuees = new address[](3);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);
        issuees[2] = address(0xC);

        sbt.issueBatch(issuees, 1);

        bool[] memory hasTokens = sbt.hasTokenBatch(issuees, 1);

        assertEq(hasTokens.length, issuees.length);
        for (uint256 i = 0; i < issuees.length; i++) {
            assertTrue(hasTokens[i]);
        }
    }

    // function test_allOwnersOf() public {

    // }

    // function test_allTokensOf() public {

    // }

    /*//////////////////////////////////////////////////////////////
                        ERC1155 Spec Adherance
    //////////////////////////////////////////////////////////////*/

    function test_issue_AdheresToERC1155Spec() public {
        vm.expectEmit(true, true, true, true);
        emit Events.TransferSingle(address(this), address(0), address(0xA), 1, 1);

        sbt.issue(address(0xA), 1);
    }

    function test_hasToken_AdheresToERC1155Spec() public {
        sbt.issue(address(0xA), 1);

        assertEq(sbt.balanceOf(address(0xA), 1), 1);
        assertTrue(sbt.hasToken(address(0xA), 1));
    }

    // TODO hasTokenBatch
    // TODO allOwnersOf
    // TODO allTokensOf
}

// TODO DRY up
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
