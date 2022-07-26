// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import "forge-std/Test.sol";
import "solmate/tokens/ERC721.sol";

import {SevenTeenTwentyNineEssay} from "../src/1729Essay.sol";

contract ERC721SpecTest is Test {
    //
    using stdStorage for StdStorage;

    SevenTeenTwentyNineEssay token;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setUp() public {
        token = new SevenTeenTwentyNineEssay();
    }

    function testInvariantMetadata() public {
        assertEq(token.name(), "1729 Essay");
        assertEq(token.symbol(), "1729ESSAY");
    }

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function testMint() public {
        token.mint(address(0xBABE), 1337);

        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.ownerOf(1337), address(0xBABE));
    }

    function testMintToZeroAddressShouldFail() public {
        vm.expectRevert("INVALID_RECIPIENT");

        token.mint(address(0), 1337);
    }

    function testDoubleMintShouldFail() public {
        token.mint(address(0xBABE), 1337);

        vm.expectRevert("ALREADY_MINTED");

        token.mint(address(0xBABE), 1337);
    }

    function testMintFuzzy(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBABE);

        token.mint(to, id);

        assertEq(token.balanceOf(to), 1);
        assertEq(token.ownerOf(id), to);
    }

    ////////////////////////////////////////////////
    ////////////////    Burn    ////////////////////
    ////////////////////////////////////////////////

    function testBurn() public {
        token.mint(address(0xBABE), 1337);
        token.burn(1337);

        assertEq(token.balanceOf(address(0xBABE)), 0);

        vm.expectRevert("NOT_MINTED");
        token.ownerOf(1337);
    }

    function testBurnUnmintedShouldFail() public {
        vm.expectRevert("NOT_MINTED");

        token.burn(1337);
    }

    function testDoubleBurnShouldFail() public {
        token.mint(address(0xBABE), 1337);

        token.burn(1337);

        vm.expectRevert("NOT_MINTED");

        token.burn(1337);
    }

    function testBurnFuzzy(address to, uint256 id) public {
        if (to == address(0)) to = address(0xBABE);

        token.mint(to, id);
        token.burn(id);

        assertEq(token.balanceOf(to), 0);

        vm.expectRevert("NOT_MINTED");
        token.ownerOf(id);
    }

    ////////////////////////////////////////////////
    ////////////////    Approve    /////////////////
    ////////////////////////////////////////////////

    function testApprove() public {
        token.mint(address(this), 1337);

        vm.expectEmit(true, true, true, true);
        emit Approval(address(this), address(0xBABE), 1337);

        token.approve(address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0xBABE));
    }

    function testMultipleApprove() public {
        token.mint(address(this), 1337);

        token.approve(address(0xABCD), 1337);
        token.approve(address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0xBABE));
    }

    function testApproveBurn() public {
        token.mint(address(this), 1337);

        token.approve(address(0xBABE), 1337);

        token.burn(1337);

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.getApproved(1337), address(0));

        vm.expectRevert("NOT_MINTED");
        token.ownerOf(1337);
    }

    function testApproveAll() public {
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(address(this), address(0xBABE), true);

        token.setApprovalForAll(address(0xBABE), true);

        assertTrue(token.isApprovedForAll(address(this), address(0xBABE)));
    }

    function testApproveUnmintedShouldFail() public {
        vm.expectRevert("NOT_AUTHORIZED");

        token.approve(address(0xBABE), 1337);
    }

    function testApproveUnauthorizedShouldFail() public {
        token.mint(address(0xABCD), 1337);

        vm.expectRevert("NOT_AUTHORIZED");

        token.approve(address(0xBABE), 1337);
    }

    // TODO add remaining fuzz tests

    ////////////////////////////////////////////////
    ////////////////    Balance Of    //////////////
    ////////////////////////////////////////////////

    function testBalanceOf() public {
        token.mint(address(0xBABE), 1337);

        assertEq(token.balanceOf(address(0xBABE)), 1);
    }

    function testBalanceOfWithTwoMints() public {
        token.mint(address(0xBABE), 1);
        token.mint(address(0xBABE), 1337);

        assertEq(token.balanceOf(address(0xBABE)), 2);
    }

    function testBalanceOfWhenOwningNone() public {
        assertEq(token.balanceOf(address(0xBABE)), 0);
    }

    function testBalanceOfAfterBurn() public {
        token.mint(address(0xBABE), 1);
        token.mint(address(0xBABE), 1337);

        vm.prank(address(0xBABE));
        token.burn(1);

        assertEq(token.balanceOf(address(0xBABE)), 1);
    }

    function testBalanceOfAfterTransferring() public {
        token.mint(address(0xBABE), 1);
        token.mint(address(0xBABE), 1337);

        vm.prank(address(0xBABE));
        token.transferFrom(address(0xBABE), address(this), 1);

        assertEq(token.balanceOf(address(0xBABE)), 1);
    }

    function testBalanceOfAfterReceivingTransfer() public {
        token.mint(address(this), 1337);

        token.transferFrom(address(this), address(0xBABE), 1337);

        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testBalanceOfZeroAddressShouldFail() public {
        vm.expectRevert("ZERO_ADDRESS");

        token.balanceOf(address(0));
    }

    // TODO add remaining fuzz tests

    ////////////////////////////////////////////////
    ////////////////    Owner Of    ////////////////
    ////////////////////////////////////////////////

    function testOwnerOf() public {
        token.mint(address(0xBABE), 1337);

        assertEq(token.ownerOf(1337), address(0xBABE));
    }

    function testOwnerOfUnmintedShouldFail() public {
        vm.expectRevert("NOT_MINTED");

        token.ownerOf(1337);
    }

    function testOwnerOfAfterTransfer() public {
        token.mint(address(this), 1337);

        assertEq(token.ownerOf(1337), address(this));

        token.transferFrom(address(this), address(0xBABE), 1337);

        assertEq(token.ownerOf(1337), address(0xBABE));
    }

    // TODO add remaining fuzz tests

    ////////////////////////////////////////////////
    ////////////////    Transfer    ////////////////
    ////////////////////////////////////////////////

    function testTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1337);

        vm.prank(from);
        token.approve(address(this), 1337);

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, address(0xBABE), 1337);

        token.transferFrom(from, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(from), 0);
    }

    function testTransferFromSelf() public {
        token.mint(address(this), 1337);

        token.transferFrom(address(this), address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testTransferFromApproveAll() public {
        address from = address(0xABCD);

        token.mint(from, 1337);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.transferFrom(from, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(from), 0);
    }

    function testTransferFromUnownedShouldFail() public {
        vm.expectRevert("WRONG_FROM");

        token.transferFrom(address(0xABCD), address(0xBABE), 1337);
    }

    function testTransferFromWithWrongFromShouldFail() public {
        token.mint(address(this), 1337);

        vm.expectRevert("WRONG_FROM");

        token.transferFrom(address(0xBABE), address(0xABCD), 1337);
    }

    function testTransferFromToZeroAddressShouldFail() public {
        token.mint(address(this), 1337);

        vm.expectRevert("INVALID_RECIPIENT");

        token.transferFrom(address(this), address(0), 1337);
    }

    function testTransferFromWithNotOwnerOrUnapprovedSpenderShouldFail() public {
        token.mint(address(0xBABE), 1337);

        vm.expectRevert("NOT_AUTHORIZED");

        token.transferFrom(address(0xBABE), address(0xABCD), 1337);
    }

    // TODO add remaining fuzz tests

    ////////////////////////////////////////////////
    ////////////////    Safe Transfer    ///////////
    ////////////////////////////////////////////////

    function testSafeTransferFromToEOA() public {
        address from = address(0xABCD);

        token.mint(from, 1337);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(from, address(0xBABE), 1337);

        token.safeTransferFrom(from, address(0xBABE), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(0xBABE));
        assertEq(token.balanceOf(address(0xBABE)), 1);
        assertEq(token.balanceOf(from), 0);
    }

    function testSafeTransferFromToERC721Recipient() public {
        address from = address(0xABCD);
        ERC721Recipient recipient = new ERC721Recipient();

        token.mint(from, 1337);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(from, address(recipient), 1337);

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(from), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), from);
        assertEq(recipient.id(), 1337);
        assertEq(recipient.data(), "");
    }

    function testSafeTransferFromToERC721RecipientWithData() public {
        address from = address(0xABCD);
        ERC721Recipient recipient = new ERC721Recipient();

        token.mint(from, 1337);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(from, address(recipient), 1337, "testing 456");

        assertEq(token.getApproved(1337), address(0));
        assertEq(token.ownerOf(1337), address(recipient));
        assertEq(token.balanceOf(address(recipient)), 1);
        assertEq(token.balanceOf(from), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), from);
        assertEq(recipient.id(), 1337);
        assertEq(recipient.data(), "testing 456");
    }

    function testSafeTransferFromToNonERC721RecipientShouldFail() public {
        token.mint(address(this), 1337);
        address to = address(new NonERC721Recipient());

        vm.expectRevert();

        token.safeTransferFrom(address(this), to, 1337);
    }

    function testSafeTransferFromToNonERC721RecipientWithDataShouldFail() public {
        token.mint(address(this), 1337);

        address to = address(new NonERC721Recipient());

        vm.expectRevert();

        token.safeTransferFrom(address(this), to, 1337, "testing 456");
    }

    function testSafeTransferFromToRevertingERC721RecipientShouldFail() public {
        token.mint(address(this), 1337);

        address to = address(new NonERC721Recipient());

        vm.expectRevert();

        token.safeTransferFrom(address(this), to, 1337);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataShouldFail() public {
        token.mint(address(this), 1337);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("UNSAFE_RECIPIENT");

        token.safeTransferFrom(address(this), to, 1337);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataWithDataShouldFail() public {
        token.mint(address(this), 1337);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("UNSAFE_RECIPIENT");

        token.safeTransferFrom(address(this), to, 1337, "testing 456");
    }

    // TODO add remaining fuzz tests

    ////////////////////////////////////////////////
    ////////////////    Safe Mint    ///////////////
    ////////////////////////////////////////////////

    // function testSafeMintToEOA() public {
    //     token.safeMint(address(0xBABE), 1337);

    //     assertEq(token.ownerOf(1337), address(address(0xBABE)));
    //     assertEq(token.balanceOf(address(address(0xBABE))), 1);
    // }

    // function testSafeMintToERC721Recipient() public {
    //     ERC721Recipient recipient = new ERC721Recipient();

    //     token.safeMint(address(recipient), 1337);

    //     assertEq(token.ownerOf(1337), address(recipient));
    //     assertEq(token.balanceOf(address(recipient)), 1);

    //     assertEq(recipient.operator(), address(this));
    //     assertEq(recipient.from(), (address(0)));
    //     assertEq(recipient.id(), 1337);
    //     assertEq(recipient.data(), "");
    // }

    // function testSafeMintToERC721RecipientWithData() public {
    //     ERC721Recipient recipient = new ERC721Recipient();

    //     token.safeMint(address(recipient), 1337, "testing 456");

    //     assertEq(token.ownerOf(1337), address(recipient));
    //     assertEq(token.balanceOf(address(recipient)), 1);

    //     assertEq(recipient.operator(), address(this));
    //     assertEq(recipient.from(), address(0));
    //     assertEq(recipient.id(), 1337);
    //     assertEq(recipient.data(), "testing 456");
    // }

    // function testSafeMintToNonERC721RecipientShouldFail() public {
    //     address to = address(new NonERC721Recipient());

    //     vm.expectRevert();

    //     token.safeMint(to, 1337);
    // }

    // function testSafeMintToNonERC721RecipientWithDataShouldFail() public {
    //     address to = address(new NonERC721Recipient());

    //     vm.expectRevert();

    //     token.safeMint(to, 1337, "testing 456");
    // }

    // function testSafeMintToRevertingERC721RecipientShouldFail() public {
    //     address to = address(new RevertingERC721Recipient());

    //     vm.expectRevert(ERC721TokenReceiver.onERC721Received.selector);

    //     token.safeMint(to, 1337);
    // }

    // function testSafeMintToRevertingERC721RecipientWithDataShouldFail() public {
    //     address to = address(new RevertingERC721Recipient());

    //     vm.expectRevert(bytes(string(abi.encodePacked(ERC721TokenReceiver.onERC721Received.selector))));

    //     token.safeMint(to, 1337, "testing 456");
    // }

    // function testSafeMintToERC721RecipientWithWrongReturnDataShouldFail() public {
    //     address to = address(new WrongReturnDataERC721Recipient());

    //     vm.expectRevert("UNSAFE_RECIPIENT");

    //     token.safeMint(to, 1337);
    // }

    // function testSafeMintToERC721RecipientWithWrongReturnDataWithDataShouldFail() public {
    //     address to = address(new WrongReturnDataERC721Recipient());

    //     vm.expectRevert("UNSAFE_RECIPIENT");

    //     token.safeMint(to, 1337, "testing 456");
    // }

    // TODO add remaining fuzz tests

    ////////////////////////////////////////////////
    ////////////////    Metadata    ////////////////
    ////////////////////////////////////////////////

    // TODO add ERC721Metadata tests

    ////////////////////////////////////////////////
    ////////////////    Enumerable    //////////////
    ////////////////////////////////////////////////

    // TODO add ERC721Enumerable
}

contract ERC721Recipient is ERC721TokenReceiver {
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

        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

contract NonERC721Recipient {}

contract RevertingERC721Recipient is ERC721TokenReceiver {
    event log(string info);

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(ERC721TokenReceiver.onERC721Received.selector)));
    }
}

contract WrongReturnDataERC721Recipient is ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) public virtual override returns (bytes4) {
        return 0xDEADCAFE;
    }
}
