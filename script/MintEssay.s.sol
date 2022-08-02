// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineEssay} from "../src/1729Essay.sol";

contract MintEssayScript is Script {
    //
    address tokenAddress = address(0xCAFE);
    address multisig = address(0x1729a);

    uint256 tokenId = 1; // BUMP ME

    function run() public {
        // generate hash for Essay markdown

        // upload Essay image to IPFS

        // upload Essay markdown to IPFS (archival URL)

        // generate Essay JSON metadata file

        // upload Essay JSON metadata file to IPFS

        // get already deployed Essay NFT contract
        SevenTeenTwentyNineEssay token = SevenTeenTwentyNineEssay(tokenAddress);

        // mint Essay NFT
        vm.broadcast(multisig);
        token.mint(1);

        // verify thangs look good (in what ways?)

    }
}
