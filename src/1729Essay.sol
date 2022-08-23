// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "openzeppelin-contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC2981} from "openzeppelin-contracts/token/common/ERC2981.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-contracts/utils/Counters.sol";

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//         _ _____ ____   ___    __    __      _ _                        //
//        / |___  |___ \ / _ \  / / /\ \ \_ __(_) |_ ___ _ __ ___         //
//        | |  / /  __) | (_) | \ \/  \/ / '__| | __/ _ \ '__/ __|        //
//        | | / /  / __/ \__, |  \  /\  /| |  | | ||  __/ |  \__ \        //
//        |_|/_/  |_____|  /_/    \/  \/ |_|  |_|\__\___|_|  |___/        //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

/// @title A collection of winning essays from 1729Writers
/// @author neodaoist, plaird
/// @notice A 1729Writers admin can mint and burn essay NFTs on this contract
contract OneSevenTwoNineEssay is Ownable, ERC721, ERC2981 {
    using Counters for Counters.Counter;

    struct EssayItem {
        address author;
        string url;
    }

    mapping(uint256 => EssayItem) public essays;
    Counters.Counter internal nextTokenId;

    constructor(address _multisig) ERC721("1729 Essay", "1729ESSAY") {
        transferOwnership(_multisig);
        nextTokenId.increment();  // start tokenId counter at 1
    }

    /// @dev see ERC2981
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return
        interfaceId == 0x2a55205a || // ERC165 Interface ID for ERC2981
        interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
        interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
        interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /// @notice Get the Essay NFT metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Essay NFT
    /// @return Fully-qualified URI of an Essay NFT, e.g., XYZ
    function tokenURI(uint256 id) public view override returns (string memory) {
        return essays[id].url;
    }

    /// @notice Mint a new token, using the next available token ID
    /// @param author the address of the writer, who will receive royalty payments
    /// @param url the URL containing the essay JSON metadata
    /// @return the tokenId for the newly minted token
    function mint(address author, string calldata url) public onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId.current();
        nextTokenId.increment();
        _mint(tokenId, author, url);
        return tokenId;
    }

    function _mint(uint256 _tokenId, address author, string calldata url) private onlyOwner {
        EssayItem memory essay = EssayItem(author, url);
        essays[_tokenId] = essay;
        _safeMint(owner(), _tokenId);
        _setTokenRoyalty(_tokenId, author, 1000);  // FIXME: Hardcoded
}

    /// @notice Returns the total of all tokens ever minted (includes tokens which have been burned)
    function totalSupply() public view returns (uint256) {
        return nextTokenId.current() - 1;
    }

    /// @notice Removes the specified tokenId's details
    function _burn(uint256 tokenId)
        internal
        override (ERC721)
    {
        delete essays[tokenId];
        super._burn(tokenId);
    }
    
    function burn(uint256 tokenId) public virtual onlyOwner {
        _burn(tokenId);
    }

}
