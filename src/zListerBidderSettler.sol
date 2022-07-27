// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

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

/// @title
/// @author
/// @notice
/// @dev
contract zListerBidderSettler is Ownable {
    //

    // TODO ensure state vars are ordered optimally

    address private immutable multisig;
    ReserveAuctionCoreETH auctionHouse;

    uint32 AUCTION_DURATION = 3 days;
    uint96 AUCTION_RESERVE_PRICE = 0.1 ether;

    constructor(address _multisig, address _zReserveAuction) {
        multisig = _multisig;
        auctionHouse = ReserveAuctionCoreETH(_zReserveAuction);

        // TODO TBD if want to move both Zora v3 approvals here somehow

        transferOwnership(multisig);
    }

    function list(
        address _contractAddress,
        uint256 _tokenId,
        address _writerAddress
    ) public onlyOwner {
        auctionHouse.createAuction(
            _contractAddress,
            _tokenId,
            AUCTION_DURATION,
            AUCTION_RESERVE_PRICE,
            _writerAddress,
            block.timestamp
        );
    }

    function bid(address _contractAddress, uint256 _tokenId) public payable onlyOwner {
        auctionHouse.createBid{value: msg.value}(_contractAddress, _tokenId);
    }

    function settle(address _contractAddress, uint256 _tokenId) public payable onlyOwner {
        auctionHouse.settleAuction(_contractAddress, _tokenId);
    }
}

abstract contract ReserveAuctionCoreETH {
    //
    function createAuction(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _reservePrice,
        address _sellerFundsRecipient,
        uint256 _startTime
    ) public virtual;

    function setAuctionReservePrice(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _reservePrice
    ) public virtual;

    function cancelAuction(address _tokenContract, uint256 _tokenId) public virtual;

    function createBid(address _tokenContract, uint256 _tokenId) public payable virtual;

    function settleAuction(address _tokenContract, uint256 _tokenId) public virtual;

    /// @dev ERC-721 token contract => ERC-721 token id => Auction
    mapping(address => mapping(uint256 => Auction)) public auctionForNFT;
}

abstract contract ModuleManager {
    function setApprovalForModule(address _moduleAddress, bool _approved) public virtual;
}

struct Auction {
    address seller;
    uint96 reservePrice;
    address sellerFundsRecipient;
    uint96 highestBid;
    address highestBidder;
    uint32 duration;
    uint32 startTime;
    uint32 firstBidTime;
}
