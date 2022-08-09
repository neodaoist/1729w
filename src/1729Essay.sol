// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";
//import {ERC165Storage} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165Storage.sol";
import {IERC2981} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

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
contract OneSevenTwoNineEssay is ERC721, IERC2981 {
    using SafeMath for uint256;
    //

    bytes2 public royaltyMills;

    /// @param _royaltyMills royalty for this contract, in thousandths (tenths of percent)
    constructor(bytes2 _royaltyMills) ERC721("1729 Essay", "1729ESSAY") {
        royaltyMills = _royaltyMills;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
        return
        interfaceId == 0x2a55205a || // ERC165 Interface ID for ERC2981
        interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
        interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
        interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }


    // Use implementation from OpenZepplin that supports _registerInterface

    /// @notice Get the Essay NFT metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Essay NFT
    /// @return Fully-qualified URI of an Essay NFT, e.g., XYZ
    function tokenURI(uint256 id) public view override returns (string memory) {
        return
            '{"Cohort": 2,"Week": 3,"Vote Count": 1337,"Name": "Save the World","Image": "XYZ","Description": "ABC","Content Hash": "DEF","Writer Name": "Susmitha87539319","Writer Address": "0xCAFE","Publication URL": "https://testpublish.com/savetheworld","Archival URL": "ipfs://xyzxyzxyz"}';
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount) {
          return (0xCAFE, royaltyAmount / 10);
    }
}
