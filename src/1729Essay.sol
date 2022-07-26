// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";

/// @title An essay from the 1729 writers union
/// @author neodaoist, plaird
/// @notice A 1729w admin can mint and burn essay NFTs on this contract
/// @dev XYZ
contract SevenTeenTwentyNineEssay is ERC721 {
    //

    // address network_state;
    // mapping(address => uint256) primary sale earnings;
    // network state tax rate / protocol fee
    // secondary sale royalty rate

    address private constant SECONDARY_SALES_ROYALTY_PAYOUT_ADDRESS = address(0x1729a); // TODO 1729w multisig
    uint16 private constant SECONDARY_SALES_ROYALTY_PERCENTAGE = 1000; // in basis points

    constructor() ERC721("1729 Essay", "1729ESSAY") {}

    /// @notice Get the Essay NFT metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Essay NFT
    /// @return Fully-qualified URI of an Essay NFT, e.g., XYZ
    function tokenURI(uint256 id) public view override returns (string memory) {
        return
            '{"Cohort": 2,"Week": 3,"Vote Count": 1337,"Name": "Save the World","Image": "XYZ","Description": "ABC","Content Hash": "DEF","Writer Name": "Susmitha87539319","Writer Address": "0xCAFE","Publication URL": "https://testpublish.com/savetheworld","Archival URL": "ipfs://xyzxyzxyz"}';
    }

    /*//////////////////////////////////////////////////////////////
                        Temporary
    //////////////////////////////////////////////////////////////*/

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                        EIP 2981
    //////////////////////////////////////////////////////////////*/

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    ) {
        receiver = SECONDARY_SALES_ROYALTY_PAYOUT_ADDRESS;
        royaltyAmount = (_salePrice * SECONDARY_SALES_ROYALTY_PERCENTAGE) / 10000; // same for all tokens
    }

    /*//////////////////////////////////////////////////////////////
                        EIP 165
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(ERC721)
        returns (bool)
    {
        return
            interfaceId == 0x7f5828d0 || // ERC165 Interface ID for ERC173
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC165
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC721Metadata TODO will we use ?
            interfaceId == 0x2a55205a; // ERC165 Interface ID for ERC2981
    }
}
