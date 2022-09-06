// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineProofOfContribution} from "../src/1729ProofOfContribution.sol";

// Issue 1729 Writers Proof of Contribution SBTs to writers for full participation
// Issue 1729 Writers Proof of Contribution SBTs to writers for partial participation
// Issue 1729 Writers Proof of Contribution SBTs to the winning writers
// Issue 1729 Writers Proof of Contribution SBTs to members for reading/voting
// Issue 1729 Writers Proof of Contribution SBTs to members for bidding in any of the Essay NFT auctions

contract IssueSBTScript is Script {
    //
    address sbtAddress = 0xb824007bF78162F5299a079ebFCA7C2C342Ad2f4;

    string sbtName = "Cohort 2 - Fully Participating Writer";
    string sbtURI = "ipfs://bafkreig43xs7tesmeb2cvawkvacxxf6fc3l5xha3pycpoulvacog7klzxm";

    address[] issuees;

    function setUp() public {
        issuees = new address[](3);

        issuees[0] = 0xCC1ed849AF02c295Edf56DF1bd00f8664A4F55f1;
        issuees[1] = address(0xA);
        issuees[2] = address(0xB);
    }

    function run() public {
        SevenTeenTwentyNineProofOfContribution sbt = SevenTeenTwentyNineProofOfContribution(sbtAddress);

        vm.startBroadcast();
        sbt.createContribution(sbtName, sbtURI);
        sbt.issueBatch(issuees, 1);
        vm.stopBroadcast();
    }
}
