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

    // Issue initial 1729 Writers Proof of Contribution SBTs to participating members
    // Issue 1729 Writers Proof of Contribution SBTs to writers for full participation
    // Issue 1729 Writers Proof of Contribution SBTs to writers for partial participation
    // Issue 1729 Writers Proof of Contribution SBTs to members for voting
    // Issue 1729 Writers Proof of Contribution SBTs to the winning writers
    // 

    function test_IssueSingle() public {
        vm.expectEmit(true, true, true, true);
        emit Events.IssueSingle(address(sbt), address(0xA), 1, 1);

        sbt.issue(address(0xA), 1);
        assertEq(sbt.balanceOf(address(0xA), 1), 1);
    }

    // TODO fix biz logic — batch issuance is about single SBT to multiple people, not vice versa
    function test_IssueBatch() public {
        address[] memory issuees = new address[](2);
        issuees[0] = address(0xA);
        issuees[1] = address(0xB);

        sbt.issueBatch(issuees, 1);

        assertEq(sbt.balanceOf(address(0xA), 1), 1);
        assertEq(sbt.balanceOf(address(0xB), 1), 1);
    }
}

// TODO DRY up
library Events {
    event IssueSingle(
        address indexed _issuer,
        address indexed _issuee,
        uint256 _tokenID,
        uint256 _value
    );

    // event IssueBatch(
    //     address indexed _issuer,
    //     address indexed _issuee,
    //     uint256[] _tokenIDs,
    //     uint256[] _values
    // );

    // event RevokeSingle(
    //     address indexed _revoker,
    //     address indexed _revokee,
    //     uint256 _tokenID,
    //     uint256 _value
    // );

    // event RevokeBatch(
    //     address indexed _revoker,
    //     address indexed _revokee,
    //     uint256[] _tokenIDs,
    //     uint256[] _values
    // );
}
