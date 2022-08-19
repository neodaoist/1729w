// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {OneSevenTwoNineProofOfContribution} from
    "../src/1729ProofOfContribution.sol";

contract OneSevenTwoNineProofOfContributionTest is Test {
    //
    OneSevenTwoNineProofOfContribution contribution;

    function setUp() public {
        contribution = new OneSevenTwoNineProofOfContribution();
    }

    function testFirst() public {
        assertEq(contribution.uri(0), "");
    }
}
