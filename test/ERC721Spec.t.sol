// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import "forge-std/Test.sol";
import {IERC721Receiver} from "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

import {SevenTeenTwentyNineEssay} from "../src/1729Essay.sol";

contract ERC721SpecTest is Test {
    //
    using stdStorage for StdStorage;

    SevenTeenTwentyNineEssay token;

    string constant EXPECTED_BASE_URI =
        "https://nftstorage.link/ipfs/bafybeibcrameoggj7i2y7yprniytdb5mp76kiukpl5omkancchb7q3uwv4";

    address multisig = address(0x1729a);
    address writer1 = address(0xA1);
    address writer2 = address(0xA2);
    address writer3 = address(0xA3);
    address writer4 = address(0xA4);

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setUp() public {
        token = new SevenTeenTwentyNineEssay(multisig);
    }

    function testInvariantMetadata() public {
        assertEq(token.name(), "1729 Essay");
        assertEq(token.symbol(), "1729ESSAY");
    }

    /*//////////////////////////////////////////////////////////////
                        Mint Essay and Distribute Earnings
    //////////////////////////////////////////////////////////////*/

    // function testMintEssay() public {
    //     vm.prank(multisig);
    //     token.mintEssay(1, writer1);

    //     assertEq(token.ownerOf(1), multisig);
    //     assertEq(token.writerOf(1), writer1);
    // }

    // function testMintEssayWhenNotOwnerShouldFail() public {

    // }

    // function testDistributeEarnings() public {

    // }

    /*//////////////////////////////////////////////////////////////
                        URI Storage
    //////////////////////////////////////////////////////////////*/

    function testURIStorage() public {
        vm.startPrank(multisig);
        token.mint(1);
        token.mint(2);
        token.mint(3);
        token.mint(4);

        assertEq(token.tokenURI(1), string(abi.encodePacked(EXPECTED_BASE_URI, "/1")));
        assertEq(token.tokenURI(2), string(abi.encodePacked(EXPECTED_BASE_URI, "/2")));
        assertEq(token.tokenURI(3), string(abi.encodePacked(EXPECTED_BASE_URI, "/3")));
        assertEq(token.tokenURI(4), string(abi.encodePacked(EXPECTED_BASE_URI, "/4")));
    }

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function testMint() public {
        vm.prank(multisig);
        token.mint(1337);

        assertEq(token.balanceOf(multisig), 1);
        assertEq(token.ownerOf(1337), multisig);
    }

    function testDoubleMintShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);

        vm.expectRevert("ERC721: token already minted");

        token.mint(1337);
    }

    function testMintFuzzy(uint256 id) public {
        vm.prank(multisig);
        token.mint(id);

        assertEq(token.balanceOf(multisig), 1);
    }

    function testMintWhenNotOwnerShouldFail() public {
        vm.expectRevert("Ownable: caller is not the owner");

        token.mint(1337);
    }

    ////////////////////////////////////////////////
    ////////////////    Burn    ////////////////////
    ////////////////////////////////////////////////

    function testBurn() public {
        vm.prank(multisig);
        token.mint(1337);
        vm.prank(multisig);
        token.burn(1337);

        assertEq(token.balanceOf(multisig), 0);

        vm.expectRevert("ERC721: invalid token ID");
        token.ownerOf(1337);
    }

    function testBurnUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        vm.prank(multisig);
        token.burn(1337);
    }

    function testDoubleBurnShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);

        token.burn(1337);

        vm.expectRevert("ERC721: invalid token ID");

        token.burn(1337);
    }

    function testBurnWhenNotOwnerShouldFail() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.expectRevert("Ownable: caller is not the owner");

        token.burn(1337);
    }

    function testBurnFuzzy(uint256 id) public {
        vm.prank(multisig);
        token.mint(id);
        vm.prank(multisig);
        token.burn(id);

        assertEq(token.balanceOf(multisig), 0);

        vm.expectRevert("ERC721: invalid token ID");
        token.ownerOf(id);
    }

    ////////////////////////////////////////////////
    ////////////////    Approve    /////////////////
    ////////////////////////////////////////////////

    function testApprove() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.expectEmit(true, true, true, true);
        emit Approval(multisig, address(0xBABE), 1337);

        vm.prank(multisig);
        token.approve(address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0xBABE));
    }

    function testMultipleApprove() public {
        vm.startPrank(multisig);
        token.mint(1337);

        token.approve(address(0xABCD), 1337);
        token.approve(address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0xBABE));
    }

    function testApproveBurn() public {
        vm.startPrank(multisig);
        token.mint(1337);

        token.approve(address(0xBABE), 1337);

        token.burn(1337);

        assertEq(token.balanceOf(multisig), 0);

        vm.expectRevert("ERC721: invalid token ID");

        token.getApproved(1337);
    }

    function testApproveAll() public {
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(multisig, address(0xBABE), true);

        vm.prank(multisig);
        token.setApprovalForAll(address(0xBABE), true);

        assertTrue(token.isApprovedForAll(multisig, address(0xBABE)));
    }

    function testApproveUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        token.approve(address(0xBABE), 1337);
    }

    function testApproveUnauthorizedShouldFail() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.expectRevert("ERC721: approve caller is not token owner or approved for all");

        token.approve(address(0xBABE), 1337);
    }

    ////////////////////////////////////////////////
    ////////////////    Balance Of    //////////////
    ////////////////////////////////////////////////

    function testBalanceOf() public {
        vm.prank(multisig);
        token.mint(1337);

        assertEq(token.balanceOf(multisig), 1);
    }

    function testBalanceOfWithTwoMints() public {
        vm.startPrank(multisig);
        token.mint(1);
        token.mint(1337);

        assertEq(token.balanceOf(multisig), 2);
    }

    function testBalanceOfWhenOwningNone() public {
        assertEq(token.balanceOf(multisig), 0);
    }

    function testBalanceOfAfterBurn() public {
        vm.startPrank(multisig);
        token.mint(1);
        token.mint(1337);

        token.burn(1);

        assertEq(token.balanceOf(multisig), 1);
    }

    function testBalanceOfAfterTransferring() public {
        vm.startPrank(multisig);
        token.mint(1);
        token.mint(1337);

        token.transferFrom(multisig, address(this), 1);

        assertEq(token.balanceOf(multisig), 1);
    }

    function testBalanceOfAfterReceivingTransfer() public {
        vm.startPrank(multisig);
        token.mint(1337);

        token.transferFrom(multisig, address(0xBABE), 1337);

        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(multisig), 0);
    }

    function testBalanceOfZeroAddressShouldFail() public {
        vm.expectRevert("ERC721: address zero is not a valid owner");

        token.balanceOf(address(0));
    }

    ////////////////////////////////////////////////
    ////////////////    Owner Of    ////////////////
    ////////////////////////////////////////////////

    function testOwnerOf() public {
        vm.prank(multisig);
        token.mint(1337);

        assertEq(token.ownerOf(1337), multisig);
    }

    function testOwnerOfUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        token.ownerOf(1337);
    }

    function testOwnerOfAfterTransfer() public {
        vm.startPrank(multisig);
        token.mint(1337);

        assertEq(token.ownerOf(1337), multisig);

        token.transferFrom(multisig, address(0xBABE), 1337);

        assertEq(token.ownerOf(1337), address(0xBABE));
    }

    ////////////////////////////////////////////////
    ////////////////    Transfer    ////////////////
    ////////////////////////////////////////////////

    function testTransferFrom() public {
        vm.startPrank(multisig);
        token.mint(1337);

        token.approve(address(this), 1337);

        vm.expectEmit(true, true, true, true);
        emit Transfer(multisig, address(0xBABE), 1337);

        token.transferFrom(multisig, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(multisig), 0);
    }

    function testTransferFromSelf() public {
        vm.startPrank(multisig);
        token.mint(1337);

        token.transferFrom(multisig, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testTransferFromApproveAll() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.prank(multisig);
        token.setApprovalForAll(address(this), true);

        token.transferFrom(multisig, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(multisig), 0);
    }

    function testTransferFromUnownedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        token.transferFrom(address(0xABCD), address(0xBABE), 1337);
    }

    function testTransferFromWithWrongFromShouldFail() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        token.transferFrom(address(0xBABE), address(0xABCD), 1337);
    }

    function testTransferFromToZeroAddressShouldFail() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        token.transferFrom(multisig, address(0), 1337);
    }

    function testTransferFromWithNotOwnerOrUnapprovedSpenderShouldFail() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        token.transferFrom(multisig, address(0xABCD), 1337);
    }

    ////////////////////////////////////////////////
    ////////////////    Safe Transfer    ///////////
    ////////////////////////////////////////////////

    function testSafeTransferFromToEOA() public {
        vm.prank(multisig);
        token.mint(1337);

        vm.prank(multisig);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(multisig, address(0xBABE), 1337);

        token.safeTransferFrom(multisig, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(multisig), 0);
    }

    function testSafeTransferFromToERC721Recipient() public {
        ERC721Recipient recipient = new ERC721Recipient();

        vm.prank(multisig);
        token.mint(1337);

        vm.prank(multisig);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(multisig, address(recipient), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(multisig), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), multisig);
        assertEq(recipient.id(), 1337);
        assertEq(recipient.data(), "");
    }

    function testSafeTransferFromToERC721RecipientWithData() public {
        ERC721Recipient recipient = new ERC721Recipient();

        vm.prank(multisig);
        token.mint(1337);

        vm.prank(multisig);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(multisig, address(recipient), 1337, "testing 456");

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(multisig), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), multisig);
        assertEq(recipient.id(), 1337);
        assertEq(recipient.data(), "testing 456");
    }

    function testSafeTransferFromToNonERC721RecipientShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);
        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        token.safeTransferFrom(multisig, to, 1337);
    }

    function testSafeTransferFromToNonERC721RecipientWithDataShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);

        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        token.safeTransferFrom(multisig, to, 1337, "testing 456");
    }

    function testSafeTransferFromToRevertingERC721RecipientShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);

        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        token.safeTransferFrom(multisig, to, 1337);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        token.safeTransferFrom(multisig, to, 1337);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataWithDataShouldFail() public {
        vm.startPrank(multisig);
        token.mint(1337);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        token.safeTransferFrom(multisig, to, 1337, "testing 456");
    }

    ////////////////////////////////////////////////
    ////////////////    Metadata    ////////////////
    ////////////////////////////////////////////////

    // TODO add ERC721Metadata tests
}

contract ERC721Recipient is IERC721Receiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        operator = _operator;
        from = _from;
        id = _id;
        data = _data;

        return IERC721Receiver.onERC721Received.selector;
    }
}

contract NonERC721Recipient {}

contract RevertingERC721Recipient is IERC721Receiver {
    event log(string info);

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(IERC721Receiver.onERC721Received.selector)));
    }
}

contract WrongReturnDataERC721Recipient is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        return 0xDEADCAFE;
    }
}
