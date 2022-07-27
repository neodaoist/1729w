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
    address private immutable multisig;
    ReserveAuctionCoreETH auctionHouse;

    uint256 AUCTION_DURATION = 3 days;
    uint256 AUCTION_RESERVE_PRICE = 0.1 ether;

    constructor(address _multisig, address _zReserveAuction) {
        multisig = _multisig;
        auctionHouse = ReserveAuctionCoreETH(_zReserveAuction);

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

    function createBid(address _tokenContract, uint256 _tokenId) public virtual;

    function settleAuction(address _tokenContract, uint256 _tokenId) public virtual;

    /// @dev ERC-721 token contract => ERC-721 token id => Auction
    mapping(address => mapping(uint256 => Auction)) public auctionForNFT;
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
