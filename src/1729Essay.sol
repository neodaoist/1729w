// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";

struct Essay {
    uint8 cohort;
    uint8 week;
    uint16 voteCount; // NOTE moved to here from end for more efficient storage
    string name;
    string image;
    string description;
    string contentHash; // TODO switch to fixed-size bytes array
    string writerName;
    string writerAddress; // TODO switch to address
    string publicationURL;
    string archivalURL;
}

/// @title An essay from the 1729 writers union
/// @author neodaoist, plaird
/// @notice A 1729w admin can mint and burn essay NFTs on this contract
/// @dev XYZ
contract OneSevenTwoNineEssay is ERC721 {
    //
    constructor() ERC721("1729 Essay", "1729ESSAY") {}

    /// @notice Get the Essay NFT metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Essay NFT
    /// @return Fully-qualified URI of an Essay NFT, e.g., XYZ
    function tokenURI(uint256 id) public view override returns (string memory) {
        return
            '{"Cohort": 2,"Week": 3,"Vote Count": 1337,"Name": "Save the World","Image": "XYZ","Description": "ABC","Content Hash": "DEF","Writer Name": "Susmitha87539319","Writer Address": "0xCAFE","Publication URL": "https://testpublish.com/savetheworld","Archival URL": "ipfs://xyzxyzxyz"}';
    }
}
