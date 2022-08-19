// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

//import {IERC2981} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";
import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "openzeppelin-contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC2981} from "openzeppelin-contracts/token/common/ERC2981.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
//import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
//import {IERC165} from "openzeppelin-contracts/utils/introspection/IERC165.sol";

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
contract OneSevenTwoNineEssay is Ownable, ERC721, ERC2981 {
    //using SafeMath for uint256;
    //

    struct EssayItem {
        address author;
        string url;
    }

    mapping(uint256 => EssayItem) public essays;

    constructor(address _multisig) ERC721("1729 Essay", "1729ESSAY") {
        transferOwnership(_multisig);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
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
        return essays[id].url;
    }

/* Use zepplin 2981
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount) {
          return (essays[tokenId].author, salePrice * essays[tokenId].royalty / 1000);
    } */


    function mint(uint256 _tokenId, address author, string calldata url) public onlyOwner {
        EssayItem memory essay = EssayItem(author, url);
        essays[_tokenId] = essay;
        _safeMint(owner(), _tokenId);
        _setTokenRoyalty(_tokenId, author, 1000);  // FIXME: Hardcoded
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

    function _burn(uint256 tokenId)
        internal
        override (ERC721)
    {
        super._burn(tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                        Temporary
    //////////////////////////////////////////////////////////////*/

    function burn(uint256 tokenId) public virtual onlyOwner {
        _burn(tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                        EIP 2981
    //////////////////////////////////////////////////////////////*/

/* Use zepplin 2981
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        public
        view
        override (ERC2981)
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = owner(); // SECONDARY_SALES_ROYALTY_PAYOUT_ADDRESS
        royaltyAmount =
            (_salePrice * SECONDARY_SALES_ROYALTY_PERCENTAGE) / 10000; // same for all tokens
    }
*/

}
