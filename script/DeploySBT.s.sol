// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineProofOfContribution} from "../src/1729ProofOfContribution.sol";

contract DeploySBTScript is Script {
    //

    address multisig = 0xf068e6F80fA1d55A27be3408cbdad3fCDa704514;

    function run() public {
        vm.broadcast();
        new SevenTeenTwentyNineProofOfContribution(multisig);
    }
}
