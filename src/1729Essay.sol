// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
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

/// @title A collection of winning essays from 1729 Writers
/// @author neodaoist
/// @author plaird
/// @notice A 1729 Writers admin can mint and burn essay NFTs on this contract
contract SevenTeenTwentyNineEssay is Ownable, ERC721 {
    //
    using Counters for Counters.Counter;

    struct EssayItem {
        address writer;
        bytes32 contentHash;
        string metadataUri;
    }

    mapping(uint256 => EssayItem) public essays;

    Counters.Counter internal nextTokenId;

    /*//////////////////////////////////////////////////////////////
                        Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(address _multisig) ERC721("1729 Writers Essay NFT", "1729ESSAY") {
        nextTokenId.increment(); // start tokenId counter at 1
        transferOwnership(_multisig);
    }

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the Essay NFT content hash
    /// @param tokenId The Token ID for a specific Essay NFT
    /// @return Sha256 hash of the Essay Markdown content
    function contentHash(uint256 tokenId) public view returns (bytes32) {
        return essays[tokenId].contentHash;
    }

    /// @notice Get the Essay NFT metadata URI
    /// @param tokenId The Token ID for a specific Essay NFT
    /// @return Fully-qualified URI of the Essay JSON metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return essays[tokenId].metadataUri;
    }

    /// @notice Returns the total of all tokens ever minted (includes tokens which have been burned)
    function totalSupply() public view returns (uint256) {
        return nextTokenId.current() - 1;
    }

    /// @notice Returns royalty info for a given token and sale price
    /// @dev Not using SafeMath here as the denominator is fixed and can never be zero,
    /// @dev but consider doing so if changing royalty percentage to a variable
    /// @return receiver the author's address
    /// @return royaltyAmount a fixed 10% royalty based on the sale price
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        return (essays[tokenId].writer, salePrice / 10);
    }

    /// @dev see ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC721) returns (bool) {
        return interfaceId == 0x2a55205a // ERC2981 -- royaltyInfo
            || interfaceId == 0x01ffc9a7 // ERC165 -- supportsInterface
            || interfaceId == 0x80ac58cd // ERC721 -- Non-Fungible Tokens
            || interfaceId == 0x5b5e139f; // ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint a new token, using the next available token ID
    /// @param _writer the address of the writer, who will receive royalty payments
    /// @param _contentHash the sha256 hash of the essay Markdown content
    /// @param _tokenUri the token URI of the essay JSON metadata
    /// @return the tokenId for the newly minted token
    function mint(address _writer, bytes32 _contentHash, string calldata _tokenUri) public onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId.current();
        nextTokenId.increment();
        EssayItem memory essay = EssayItem(_writer, _contentHash, _tokenUri);
        essays[tokenId] = essay;
        _safeMint(owner(), tokenId);

        return tokenId;
    }

    /// @notice Removes the specified tokenId's details
    function burn(uint256 tokenId) public virtual onlyOwner {
        delete essays[tokenId];
        super._burn(tokenId);
    }
}
