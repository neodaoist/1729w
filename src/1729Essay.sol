// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "openzeppelin-contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC2981} from "openzeppelin-contracts/token/common/ERC2981.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

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
/// @dev XYZ
contract SevenTeenTwentyNineEssay is ERC721, ERC721URIStorage, ERC2981, Ownable {
    //

    // mapping(address => uint256)
    // mapping(address => uint256) writerPrimarySaleEarnings;

    uint16 private constant NETWORK_STATE_PROTOCOL_FEE_PERCENTAGE = 1000; // in bips
    uint16 private constant SECONDARY_SALES_ROYALTY_PERCENTAGE = 1000; // in bips

    constructor(address _multisig) ERC721("F1729 Essay", "F1729ESSAY") {
        transferOwnership(_multisig);
    }

    /*//////////////////////////////////////////////////////////////
                        Mint Essay and Distribute Earnings
    //////////////////////////////////////////////////////////////*/

    // function mintEssay(uint256 _tokenId, address _writerAddress) public onlyOwner {
    //     writerPrimarySaleEarnings[_writerAddress] = 0 ether;
    //     _safeMint(owner(), _tokenId);
    // }

    // function distributeEarnings() public {

    // }

    /*//////////////////////////////////////////////////////////////
                        OZ
    //////////////////////////////////////////////////////////////*/

    function _baseURI() internal pure override returns (string memory) {
        return "https://nftstorage.link/ipfs/bafybeiblfxmzzzhllcappbk5t2ujmmton5wfkmaujueqrvluh237bpzale/";
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                        Temporary
    //////////////////////////////////////////////////////////////*/

    function mint(uint256 tokenId) public virtual onlyOwner {
        _mint(owner(), tokenId);
    }

    function burn(uint256 tokenId) public virtual onlyOwner {
        _burn(tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                        TODO fix both below
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                        EIP 2981
    //////////////////////////////////////////////////////////////*/

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        override(ERC2981)
        public
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = owner(); // SECONDARY_SALES_ROYALTY_PAYOUT_ADDRESS
        royaltyAmount = (_salePrice * SECONDARY_SALES_ROYALTY_PERCENTAGE) / 10000; // same for all tokens
    }

    /*//////////////////////////////////////////////////////////////
                        EIP 165
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
