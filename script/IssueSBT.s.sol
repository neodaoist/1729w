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

    address sbtAddress = 0x420668ef51a9FaF4333f4243203AE6d2F573a660;
    address writer1 = 0xCC1ed849AF02c295Edf56DF1bd00f8664A4F55f1;

    string sbtName = "Cohort 2 - Fully Participating Writer";
    string sbtURI = "ipfs://bafkreig43xs7tesmeb2cvawkvacxxf6fc3l5xha3pycpoulvacog7klzxm";
    
    // function setUp() public {}

    function run() public {
        SevenTeenTwentyNineProofOfContribution sbt = SevenTeenTwentyNineProofOfContribution(sbtAddress);

        vm.startBroadcast();
        sbt.createContribution(sbtName, sbtURI);
        sbt.issue(writer1, 1);
        vm.stopBroadcast();
    }
}
