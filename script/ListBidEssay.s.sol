// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {OneSevenTwoNineEssay} from "../src/1729Essay.sol";

contract ListBidEssayScript is Script {
    //
    address TOKEN_ADDRESS = address(0x5FbDB2315678afecb367f032d93F642f64180aa3);  // FIXME: Local
    address MULTISIG_ADDRESS = address(0x3653Cd49a47Ca29d4df701449F281B29CbA9e1ce);  // Rinkeby
    address AUCTION_HOUSE_ADDRESS = address(0x3feAf4c06211680e5969A86aDB1423Fc8AD9e994);  // Rinkeby
    address MODULE_MANAGER_ADDRESS = address(0xa248736d3b73A231D95A5F99965857ebbBD42D85);  // Rinkeby
    address TRANSFER_HELPER_ADDRESS = address(0x029AA5a949C9C90916729D50537062cb73b5Ac92);  // Rinkeby

    // Parameters
    uint256 TOKEN_ID = 1;
    address AUTHOR_ADDRESS = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);  // Local
    uint256 AUCTION_DURATION = 3 days;
    uint256 AUCTION_RESERVE_PRICE = 0.1 ether;
    uint256 BID_AMOUNT = 0.1 ether;


    function run() public {
        // set up auctionhouse
        ReserveAuctionCoreETH auctionHouse = ReserveAuctionCoreETH(AUCTION_HOUSE_ADDRESS);

        // get already deployed Essay NFT contract
        OneSevenTwoNineEssay nft = OneSevenTwoNineEssay(TOKEN_ADDRESS);

        // authorize zora contracts
        nft.setApprovalForAll(TRANSFER_HELPER_ADDRESS, true);
        ModuleManager(MODULE_MANAGER_ADDRESS).setApprovalForModule(
            AUCTION_HOUSE_ADDRESS, true
        );

        // list essay
        auctionHouse.createAuction(
            TOKEN_ADDRESS,
            TOKEN_ID,
            AUCTION_DURATION,
            AUCTION_RESERVE_PRICE,
            AUTHOR_ADDRESS,
            block.timestamp
        );

        // verify listing
        (
            address seller,
            uint256 reservePrice,
            address fundsRecipient,
            ,
            ,
            uint256 duration,
            ,
        ) = auctionHouse.auctionForNFT(address(nft), 1);
        assert(seller == MULTISIG_ADDRESS);
        assert(reservePrice == AUCTION_RESERVE_PRICE);
        assert(fundsRecipient == AUTHOR_ADDRESS);
        assert(duration == AUCTION_DURATION);

        // place bid on essay
        auctionHouse.createBid{value: 0.1 ether}(TOKEN_ADDRESS, TOKEN_ID);

        // verify bid
        (
            ,
            ,
            ,
            uint96 highestBid,
            address highestBidder,
            ,
            ,
        ) = auctionHouse.auctionForNFT(address(nft), 1);

        assert(highestBid == BID_AMOUNT);
        assert(highestBidder == MULTISIG_ADDRESS);

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
    )
        public
        virtual;

    function setAuctionReservePrice(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _reservePrice
    )
        public
        virtual;

    function cancelAuction(address _tokenContract, uint256 _tokenId)
        public
        virtual;

    function createBid(address _tokenContract, uint256 _tokenId)
        public
        payable
        virtual;

    function settleAuction(address _tokenContract, uint256 _tokenId)
        public
        virtual;

    /// @dev ERC-721 token contract => ERC-721 token id => Auction
    mapping(address => mapping(uint256 => Auction)) public auctionForNFT;
}

abstract contract ModuleManager {
    function setApprovalForModule(address _moduleAddress, bool _approved)
        public
        virtual;
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