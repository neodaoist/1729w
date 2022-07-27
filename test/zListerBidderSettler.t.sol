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

    function setUp() public {
        vm.createSelectFork("https://ropsten.infura.io/v3/3b59d7ee7a5f4378911a8a8789911ed1", 12673131);

        auctionHouse = ReserveAuctionCoreETH(address(0xF57A73D355680Df3945Da7853A1F1F9149C7DA4D));

        nft = new SevenTeenTwentyNineEssay(multisig);
        vm.prank(multisig);
        nft.mint(1);

        settler = new zListerBidderSettler(
            multisig,
            address(0xF57A73D355680Df3945Da7853A1F1F9149C7DA4D) // Zora v3 Reserve Auction CoreETH – Ropsten
        );
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

    function testListIsOnlyOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");

        settler.list(address(nft), 1, writer1);
    }

    function testListWhenNotTokenOwnerOrOperatorShouldFail() public {
        vm.expectRevert("ONLY_TOKEN_OWNER_OR_OPERATOR");

        vm.prank(multisig);
        settler.list(address(nft), 1, writer1);
    }

    // function testBid() public {
        
    // }

    // function testSettleAsWinner() public {
        
    // }

    // function testSettleAsLoser() public {
        
    // }
}
