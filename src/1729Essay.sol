// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";

/// @title An essay from the 1729 writers union
/// @author neodaoist, plaird
/// @notice A 1729w admin can mint and burn essay NFTs on this contract
/// @dev XYZ
contract OneSevenTwoNineEssay is ERC721 {

    constructor() ERC721("1729 Essay", "1729ESSAY") {}

    /// @notice Get the Essay NFT metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Essay NFT
    /// @return Fully-qualified URI of an Essay NFT, e.g., XYZ
    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }
}
