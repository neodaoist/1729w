// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import "forge-std/Test.sol";

import {SevenTeenTwentyNineEssay} from "../src/1729Essay.sol";
import "../src/zListerBidderSettler.sol";

contract zListerBidderSettlerTest is Test {
    //
    SevenTeenTwentyNineEssay nft;
    ReserveAuctionCoreETH auctionHouse;

    zListerBidderSettler settler;

    address multisig = address(0x1729a);

    address writer1 = address(0xA);
    address writer2 = address(0xB);
    address writer3 = address(0xC);
    address writer4 = address(0xD);

    address otherBidder = address(0xBEEF);

    address constant ZORA_RESERVE_AUCTION_CORE_ETH_ROPSTEN =
        0xF57A73D355680Df3945Da7853A1F1F9149C7DA4D;
    address constant ZORA_ERC721_TRANSFER_HELPER_ROPSTEN =
        0x0afB6A47C303f85c5A6e0DC6c9b4c2001E6987ED;
    address constant ZORA_MODULE_MANAGER_ROPSTEN =
        0x3120f8A161bf8ae8C4287A66920E7Fd875b41805;

    function setUp() public {
        // create and select Ropsten fork, roll to block which has Zora v3 contracts
        vm.createSelectFork(
            "https://ropsten.infura.io/v3/3b59d7ee7a5f4378911a8a8789911ed1",
            12673131
        );

        // get Zora auction house
        auctionHouse =
            ReserveAuctionCoreETH(ZORA_RESERVE_AUCTION_CORE_ETH_ROPSTEN);

        // deploy Essay NFT contract and mint 1 token
        nft = new SevenTeenTwentyNineEssay(multisig);
        vm.startPrank(multisig);
        nft.mint(1);

        // deploy lister/bidder/settler
        settler =
        new zListerBidderSettler(multisig, ZORA_RESERVE_AUCTION_CORE_ETH_ROPSTEN);

        // grant both approvals necessary to run a Zora v3 reserve auction from the multisig:
        // - one approves Zora ERC721 Transfer Helper as an operator on the Essay NFT contract
        // - one approves Zora Reserve Auction Core ETH module on the Zora Module Manager contract
        nft.setApprovalForAll(ZORA_ERC721_TRANSFER_HELPER_ROPSTEN, true);
        ModuleManager(ZORA_MODULE_MANAGER_ROPSTEN).setApprovalForModule(
            ZORA_RESERVE_AUCTION_CORE_ETH_ROPSTEN, true
        );

        vm.stopPrank();
    }

    function testPreconditions() public {
        assertEq(nft.ownerOf(1), multisig);
    }

    function testList() public {
        vm.startPrank(multisig);
        nft.setApprovalForAll(address(settler), true);
        settler.list(address(nft), 1, writer1);

        (
            address seller,
            uint256 reservePrice,
            address fundsRecipient,
            ,
            ,
            uint256 duration,
            uint256 startTime,
        ) = auctionHouse.auctionForNFT(address(nft), 1);

        assertEq(seller, multisig);
        assertEq(reservePrice, 0.1 ether);
        assertEq(fundsRecipient, writer1);
        assertEq(duration, 3 days);
        assertEq(startTime, block.timestamp);
    }

    function testOnlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        settler.list(address(nft), 1, writer1);
        vm.expectRevert("Ownable: caller is not the owner");
        settler.bid{value: 0.1 ether}(address(nft), 1);
        vm.expectRevert("Ownable: caller is not the owner");
        settler.settle(address(nft), 1);
    }

    function testListWhenNotTokenOwnerOrOperatorShouldFail() public {
        vm.expectRevert("ONLY_TOKEN_OWNER_OR_OPERATOR");

        vm.prank(multisig);
        settler.list(address(nft), 1, writer1);
    }

    function testBid() public {
        startHoax(multisig, 1 ether);
        nft.setApprovalForAll(address(settler), true);
        settler.list(address(nft), 1, writer1);

        settler.bid{value: 0.1 ether}(address(nft), 1);

        (,,, uint96 highestBid, address highestBidder,,,) =
            auctionHouse.auctionForNFT(address(nft), 1);

        assertEq(highestBid, 0.1 ether);
        assertEq(highestBidder, address(settler)); // TODO this is a problem — the NFT will go to the settler contract
    }

    function testSettleAsWinner() public {
        startHoax(multisig, 1 ether);
        nft.setApprovalForAll(address(settler), true);
        settler.list(address(nft), 1, writer1);

        assertEq(multisig.balance, 1 ether);
        assertEq(writer1.balance, 0 ether);
        assertEq(nft.ownerOf(1), multisig);

        settler.bid{value: 0.1 ether}(address(nft), 1);

        // vm.warpFork(123); // NOTE I knew I was going to need fork warping soon !

        settler.settle(address(nft), 1);

        assertEq(multisig.balance, 0.9 ether);
        assertEq(writer1.balance, 0.1 ether);
        assertEq(nft.ownerOf(1), address(settler)); // reverting with AUCTION_NOT_OVER =)
    }
// function testSettleAsLoser() public {
} // }
