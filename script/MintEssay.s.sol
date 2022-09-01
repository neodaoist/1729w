// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {OneSevenTwoNineEssay} from "../src/1729Essay.sol";

contract MintEssayScript is Script {
    //
    address tokenAddress = address(0x5FbDB2315678afecb367f032d93F642f64180aa3);
    address multisig = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address authorAddress = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    string essayUrl = "https://testurl";



    function run() public {
        // generate hash for Essay markdown

        // upload Essay image to IPFS

        // upload Essay markdown to IPFS (archival URL)

        // generate Essay JSON metadata file

        // upload Essay JSON metadata file to IPFS

        // get already deployed Essay NFT contract
        OneSevenTwoNineEssay token = OneSevenTwoNineEssay(tokenAddress);

        // mint Essay NFT
        vm.broadcast(multisig);
        token.mint(authorAddress, essayUrl);

        // verify thangs look good (in what ways?)

    }
}
