// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract OneSevenTwoNineEssay is ERC721 {

    constructor() ERC721("1729 Essay", "1729ESSAY") {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }
}
