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

    function run() public {
        address[] memory SBT_RECIPIENTS = vm.envAddress("SBT_RECIPIENTS",",");
        address payable[] memory SBT_PAYABLES = new address payable[](SBT_RECIPIENTS.length);
        address SBT_CONTRACT_ADDRESS = vm.envAddress("SBT_CONTRACT_ADDRESS");
        uint256 TOKEN_ID = vm.envUint("TOKEN_ID");
        for(uint256 i = 0; i < SBT_RECIPIENTS.length; i++) {
            SBT_PAYABLES[i] = payable(SBT_RECIPIENTS[i]);
        }

        //assert(issuees == SBT_PAYABLES);
        SevenTeenTwentyNineProofOfContribution sbt = SevenTeenTwentyNineProofOfContribution(SBT_CONTRACT_ADDRESS);

        vm.startBroadcast();
        //sbt.createContribution(sbtName, sbtURI);
        sbt.issueBatch(SBT_PAYABLES, TOKEN_ID);
        vm.stopBroadcast();
    }
}
