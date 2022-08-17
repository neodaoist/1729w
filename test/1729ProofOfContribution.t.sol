// SPDX-License-Identifier: UNLICENSED
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
        sbt.issue(address(0xA), 1);
        assertEq(sbt.balanceOf(address(0xA), 1), 1);
    }
}