// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineProofOfContribution} from "../src/1729ProofOfContribution.sol";
import {Solenv} from "solenv/Solenv.sol";

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
contract CreateSBTScript is Script {

    function run() public {
        // Load config from .env
        Solenv.config();
        address SBT_CONTRACT_ADDRESS = vm.envAddress("SBT_CONTRACT_ADDRESS");
        string memory SBT_TITLE = vm.envString("SBT_TITLE");
        string memory IMAGE_URI = vm.envString("IMAGE_URI");

        SevenTeenTwentyNineProofOfContribution sbt = SevenTeenTwentyNineProofOfContribution(SBT_CONTRACT_ADDRESS);

        vm.startBroadcast();
        sbt.createContribution(SBT_TITLE, IMAGE_URI);
        //sbt.issueBatch(issuees, 1);
        vm.stopBroadcast();
    }
}
