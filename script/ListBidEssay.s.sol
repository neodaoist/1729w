// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {SevenTeenTwentyNineEssay} from "../src/1729Essay.sol";
import {Solenv} from "solenv/Solenv.sol";

contract ListBidEssayScript is Script {
    //
    function run() public {
        // Load config from .env
        Solenv.config();
        address TOKEN_ADDRESS = vm.envAddress("TOKEN_ADDRESS");
        address MULTISIG_ADDRESS = vm.envAddress("MULTISIG_ADDRESS");
        address AUCTION_HOUSE_ADDRESS = vm.envAddress("AUCTION_HOUSE_ADDRESS");
        address MODULE_MANAGER_ADDRESS = vm.envAddress("MODULE_MANAGER_ADDRESS");
        address TRANSFER_HELPER_ADDRESS = vm.envAddress("TRANSFER_HELPER_ADDRESS");
        uint256 TOKEN_ID = vm.envUint("TOKEN_ID");
        address AUTHOR_ADDRESS = vm.envAddress("AUTHOR_ADDRESS");
        uint256 AUCTION_DURATION = vm.envUint("AUCTION_DURATION");
        uint256 AUCTION_RESERVE_PRICE = vm.envUint("AUCTION_RESERVE_PRICE");
        uint256 BID_AMOUNT = vm.envUint("BID_AMOUNT");

        // set up auctionhouse
        ReserveAuctionCoreETH auctionHouse = ReserveAuctionCoreETH(AUCTION_HOUSE_ADDRESS);

        // get already deployed Essay NFT contract
        SevenTeenTwentyNineEssay nft = SevenTeenTwentyNineEssay(TOKEN_ADDRESS);

        // authorize zora contracts
        vm.startBroadcast();
        nft.setApprovalForAll(TRANSFER_HELPER_ADDRESS, true);
        ModuleManager(MODULE_MANAGER_ADDRESS).setApprovalForModule(AUCTION_HOUSE_ADDRESS, true);
        vm.stopBroadcast();

        // list essay
        vm.startBroadcast();
        auctionHouse.createAuction(
            TOKEN_ADDRESS, TOKEN_ID, AUCTION_DURATION, AUCTION_RESERVE_PRICE, AUTHOR_ADDRESS, block.timestamp
        );
        // verify listing
        (address seller, uint256 reservePrice, address fundsRecipient,,, uint256 duration,,) =
            auctionHouse.auctionForNFT(address(nft), 1);
        require(seller == MULTISIG_ADDRESS);
        require(reservePrice == AUCTION_RESERVE_PRICE);
        require(fundsRecipient == AUTHOR_ADDRESS);
        require(duration == AUCTION_DURATION);
        vm.stopBroadcast();

        // place bid on essay
        vm.startBroadcast();
        auctionHouse.createBid{value: BID_AMOUNT}(vm.envAddress("TOKEN_ADDRESS"), TOKEN_ID);
        vm.stopBroadcast();
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

    function setAuctionReservePrice(address _tokenContract, uint256 _tokenId, uint256 _reservePrice) public virtual;

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
