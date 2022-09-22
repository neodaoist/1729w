// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineEssay} from "../src/1729Essay.sol";
import {Solenv} from "solenv/Solenv.sol";

contract MintEssayScript is Script {
    //
    function run() public {
        // Load config from .env
        Solenv.config();
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address multisig = vm.envAddress("MULTISIG_ADDRESS");
        address authorAddress = vm.envAddress("AUTHOR_ADDRESS");
        string memory essayUrl = vm.envString("ESSAY_URL");
        // generate hash for Essay markdown

        // upload Essay image to IPFS

        // upload Essay markdown to IPFS (archival URL)

        // generate Essay JSON metadata file

        // upload Essay JSON metadata file to IPFS

        // get already deployed Essay NFT contract
        SevenTeenTwentyNineEssay token = SevenTeenTwentyNineEssay(tokenAddress);

        // mint Essay NFT
        vm.broadcast(multisig);
        token.mint(authorAddress, essayUrl);

        // verify thangs look good (in what ways?)
    }
}
