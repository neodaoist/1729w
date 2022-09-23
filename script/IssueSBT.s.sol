// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineProofOfContribution} from "../src/1729ProofOfContribution.sol";

/**
 * @notice
 *
 * Issue 1729 Writers Proof of Contribution SBTs to writers, readers, voters, bidders, and community members
 *
 * Cohort 1
 * Cohort 2
 *
 * Winning Essay
 * Writer 100% / Writer^4 / Writer^3 / Writer^3 + Writer^3 / SUM(2*writer**3)
 * Writer
 * Reader
 * Voter
 * Auction Bidder
 */
contract IssueSBTScript is Script {
    //
    address sbtAddress = 0xb824007bF78162F5299a079ebFCA7C2C342Ad2f4;

    string sbtName = "Cohort 2 - Full Completion";
    string sbtURI = "ipfs://bafkreig43xs7tesmeb2cvawkvacxxf6fc3l5xha3pycpoulvacog7klzxm";

    address payable[] issuees =
        [payable(0xCC1ed849AF02c295Edf56DF1bd00f8664A4F55f1), payable(address(0xA)), payable(address(0xB))];

    function run() public {
        SevenTeenTwentyNineProofOfContribution sbt = SevenTeenTwentyNineProofOfContribution(sbtAddress);

        vm.startBroadcast();
        sbt.createContribution(sbtName, sbtURI);
        sbt.issueBatch(issuees, 1);
        vm.stopBroadcast();
    }
}
