// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {OneSevenTwoNineEssay} from "../src/1729Essay.sol";

contract MintEssayScript is Script {
    //
    address tokenAddress = 0x193d1e3500E1937dF922C91030bf86cb443aaDDe;  // Rinkeby
    address multisig = 0x3653Cd49a47Ca29d4df701449F281B29CbA9e1ce;  //  Rinkeby
    address authorAddress = 0xc7737DD9059651a5058b9e0c1E34029B7B677a44;  // Rinkeby
    string essayUrl = "ipfs://bafkreihqq5g7ygkqst4j2in57ghi56ry2tdr35nqqf5bqp3z5lzw7qa5na";



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
