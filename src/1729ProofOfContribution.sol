// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC1155} from "solmate/tokens/ERC1155.sol";

contract OneSevenTwoNineProofOfContribution is ERC1155 {

    constructor() {}
    
    function uri(uint256) public view override returns (string memory) {
        return "";
    }
}
