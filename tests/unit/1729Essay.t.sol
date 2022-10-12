// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SevenTeenTwentyNineEssay} from "../../src/1729Essay.sol";

import "forge-std/Test.sol";
import "./Fixtures.sol";

import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

contract SevenTeenTwentyNineEssayTest is Test {
    //
    SevenTeenTwentyNineEssay essay;

    TestAddresses addresses;

    bytes32 CONTENT_HASH = bytes32(hex"e59d00777b571c5477974b56b9fa6671fd4118fa532ce3ac72ea32fd8b1152b6");
    string METADATA_URI =
        "https://nftstorage.link/ipfs/bafybeiblfxmzzzhllcappbk5t2ujmmton5wfkmaujueqrvluh237bpzale";

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event RoyaltyPercentageUpdated(uint96 newPercentageInBips);

    /*//////////////////////////////////////////////////////////////
                        Set Up
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        addresses = getAddresses();
        essay = new SevenTeenTwentyNineEssay(addresses.multisig);
    }

    function testInvariantMetadata() public {
        assertEq(essay.name(), "1729 Writers Essay NFT");
        assertEq(essay.symbol(), "1729ESSAY");
    }

    function testImplementsInterface() public {
        assertTrue(essay.supportsInterface(0x80ac58cd)); // ERC721
        assertTrue(essay.supportsInterface(0x5b5e139f)); // ERC721Metadata
        assertTrue(essay.supportsInterface(0x2a55205a)); // ERC2981
        assertFalse(essay.supportsInterface(0x00));
    }

    // Contract should NOT support receiving funds directly
    function testReceiveFundsDisabled() public {
        vm.prank(addresses.multisig);
        vm.expectRevert("Contract should not accept payment directly");
        (bool result,) = address(essay).call{value: 1000000000}("");

        assertFalse(result, "Contract should not accept payment");
    }

    /*//////////////////////////////////////////////////////////////
                        Content and Metadata
    //////////////////////////////////////////////////////////////*/

    function testContentAndMetadata() public {
        bytes32 contentHash2 = bytes32(hex"9acb1e45282680109ef0b077c7f60a9258df99b487c25824785b0c07e5bc93a2");
        bytes32 contentHash3 = bytes32(hex"0f65a8d6db15251151a63f77afc28a210e1758133e103994f5e81177a81a5dc3");
        bytes32 contentHash4 = bytes32(hex"74c62dfd1c2b54afe234a03dd6637df58fbfd7a2abff32c08db0260c183d4ce6");
        string memory metadataUri2 = string(abi.encodePacked(METADATA_URI, "abc"));
        string memory metadataUri3 = string(abi.encodePacked(METADATA_URI, "def"));
        string memory metadataUri4 = string(abi.encodePacked(METADATA_URI, "ghi"));

        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
        essay.mint(addresses.writer1, contentHash2, metadataUri2);
        essay.mint(addresses.writer1, contentHash3, metadataUri3);
        essay.mint(addresses.writer1, contentHash4, metadataUri4);

        assertEq(essay.contentHash(1), CONTENT_HASH);
        assertEq(essay.contentHash(2), contentHash2);
        assertEq(essay.contentHash(3), contentHash3);
        assertEq(essay.contentHash(4), contentHash4);

        assertEq(essay.tokenURI(1), METADATA_URI);
        assertEq(essay.tokenURI(2), metadataUri2);
        assertEq(essay.tokenURI(3), metadataUri3);
        assertEq(essay.tokenURI(4), metadataUri4);
    }

    /*//////////////////////////////////////////////////////////////
                        Minting
    //////////////////////////////////////////////////////////////*/

    function testMint() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        assertEq(essay.balanceOf(addresses.multisig), 1);
        assertEq(essay.ownerOf(1), addresses.multisig);
    }

    function testMintWhenNotOwnerShouldFail() public {
        vm.expectRevert("Ownable: caller is not the owner");

        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
    }

    /*//////////////////////////////////////////////////////////////
                        Burning
    //////////////////////////////////////////////////////////////*/

    function testBurn() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
        vm.prank(addresses.multisig);
        essay.burn(1);

        assertEq(essay.balanceOf(addresses.multisig), 0);

        vm.expectRevert("ERC721: invalid token ID");
        essay.ownerOf(1);
    }

    function testBurnUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        vm.prank(addresses.multisig);
        essay.burn(1337);
    }

    function testDoubleBurnShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.burn(1);

        vm.expectRevert("ERC721: invalid token ID");

        essay.burn(1);
    }

    function testBurnWhenNotOwnerShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.expectRevert("Ownable: caller is not the owner");

        essay.burn(1);
    }

    /*//////////////////////////////////////////////////////////////
                        Token ID Incrementing
    //////////////////////////////////////////////////////////////*/

    function testFirstMintIsOne() public {
        vm.startPrank(addresses.multisig);
        uint256 newId = essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
        assertEq(newId, 1);
    }

    function testTotalSupply() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI); // 1
        uint256 two = essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI); // 2
        assertEq(two, 2);
        assertEq(essay.totalSupply(), 2);
        uint256 three = essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI); // 3
        assertEq(three, 3);
        assertEq(essay.totalSupply(), 3);
        essay.burn(2); // burning does not reduce total supply
        assertEq(essay.totalSupply(), 3);
        uint256 four = essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI); // 3
        assertEq(four, 4);
        assertEq(essay.totalSupply(), 4);
    }

    /*//////////////////////////////////////////////////////////////
                        Royalty
    //////////////////////////////////////////////////////////////*/

    function testRoyalty() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, "https://testpublish.com/savetheworld");
        essay.mint(addresses.writer2, CONTENT_HASH, "https://testpublish2.com/abc");
        essay.mint(addresses.writer3, CONTENT_HASH, "https://testpublish3.com/xyz");

        (address recipient, uint256 amount) = essay.royaltyInfo(1, 100_000);
        assertEq(addresses.writer1, recipient);
        assertEq(amount, 10_000); // 10%

        (recipient, amount) = essay.royaltyInfo(2, 7_777);
        assertEq(addresses.writer2, recipient);
        assertEq(amount, 777); // 10%

        (recipient, amount) = essay.royaltyInfo(3, 1_337_001);
        assertEq(addresses.writer3, recipient);
        assertEq(amount, 133_700); // 10%
    }

    /*//////////////////////////////////////////////////////////////
                        ERC 721 Spec Tests
    //////////////////////////////////////////////////////////////*/

    ////////////////////////////////////////////////
    ////////////////    Approve    /////////////////
    ////////////////////////////////////////////////

    function testApprove() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.expectEmit(true, true, true, true);
        emit Approval(addresses.multisig, address(0xBABE), 1);

        vm.prank(addresses.multisig);
        essay.approve(address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0xBABE));
    }

    function testMultipleApprove() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.approve(address(0xABCD), 1);
        essay.approve(address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0xBABE));
    }

    function testApproveBurn() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.approve(address(0xBABE), 1);

        essay.burn(1);

        assertEq(essay.balanceOf(addresses.multisig), 0);

        vm.expectRevert("ERC721: invalid token ID");

        essay.getApproved(1);
    }

    function testApproveAll() public {
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(addresses.multisig, address(0xBABE), true);

        vm.prank(addresses.multisig);
        essay.setApprovalForAll(address(0xBABE), true);

        assertTrue(essay.isApprovedForAll(addresses.multisig, address(0xBABE)));
    }

    function testApproveUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        essay.approve(address(0xBABE), 1337);
    }

    function testApproveUnauthorizedShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.expectRevert("ERC721: approve caller is not token owner or approved for all");

        essay.approve(address(0xBABE), 1);
    }

    ////////////////////////////////////////////////
    ////////////////    Balance Of    //////////////
    ////////////////////////////////////////////////

    function testBalanceOf() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }

    function testBalanceOfWithTwoMints() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI); // 1
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI); // 2

        assertEq(essay.balanceOf(addresses.multisig), 2);
    }

    function testBalanceOfWhenOwningNone() public {
        assertEq(essay.balanceOf(addresses.multisig), 0);
    }

    function testBalanceOfAfterBurn() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.burn(1);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }

    function testBalanceOfAfterTransferring() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.transferFrom(addresses.multisig, address(this), 1);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }

    function testBalanceOfAfterReceivingTransfer() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.balanceOf(address(0xBABE)), 1);
        assertEq(essay.balanceOf(addresses.multisig), 0);
    }

    function testBalanceOfZeroAddressShouldFail() public {
        vm.expectRevert("ERC721: address zero is not a valid owner");

        essay.balanceOf(address(0));
    }

    ////////////////////////////////////////////////
    ////////////////    Owner Of    ////////////////
    ////////////////////////////////////////////////

    function testOwnerOf() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        assertEq(essay.ownerOf(1), addresses.multisig);
    }

    function testOwnerOfUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        essay.ownerOf(1337);
    }

    function testOwnerOfAfterTransfer() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        assertEq(essay.ownerOf(1), addresses.multisig);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.ownerOf(1), address(0xBABE));
    }

    ////////////////////////////////////////////////
    ////////////////    Transfer    ////////////////
    ////////////////////////////////////////////////

    function testTransferFrom() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.approve(address(this), 1);

        vm.expectEmit(true, true, true, true);
        emit Transfer(addresses.multisig, address(0xBABE), 1);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(0xBABE));
        assertEq(essay.balanceOf(address(0xBABE)), 1);
        assertEq(essay.balanceOf(addresses.multisig), 0);
    }

    function testTransferFromSelf() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(0xBABE));
        assertEq(essay.balanceOf(address(0xBABE)), 1);
        assertEq(essay.balanceOf(address(this)), 0);
    }

    function testTransferFromApproveAll() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.prank(addresses.multisig);
        essay.setApprovalForAll(address(this), true);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(0xBABE));
        assertEq(essay.balanceOf(address(0xBABE)), 1);
        assertEq(essay.balanceOf(addresses.multisig), 0);
    }

    function testTransferFromUnownedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        essay.transferFrom(address(0xABCD), address(0xBABE), 1337);
    }

    function testTransferFromWithWrongFromShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        essay.transferFrom(address(0xBABE), address(0xABCD), 1);
    }

    function testTransferFromToZeroAddressShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        essay.transferFrom(addresses.multisig, address(0), 1);
    }

    function testTransferFromWithNotOwnerOrUnapprovedSpenderShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        essay.transferFrom(addresses.multisig, address(0xABCD), 1);
    }

    ////////////////////////////////////////////////
    ////////////////    Safe Transfer    ///////////
    ////////////////////////////////////////////////

    function testSafeTransferFromToEOA() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.prank(addresses.multisig);
        essay.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true);
        emit Transfer(addresses.multisig, address(0xBABE), 1);

        essay.safeTransferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(0xBABE));
        assertEq(essay.balanceOf(address(0xBABE)), 1);
        assertEq(essay.balanceOf(addresses.multisig), 0);
    }

    function testSafeTransferFromToERC721Recipient() public {
        ERC721Recipient recipient = new ERC721Recipient();

        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.prank(addresses.multisig);
        essay.setApprovalForAll(address(this), true);

        essay.safeTransferFrom(addresses.multisig, address(recipient), 1);

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(recipient));
        assertEq(essay.balanceOf(address(recipient)), 1);
        assertEq(essay.balanceOf(addresses.multisig), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), addresses.multisig);
        assertEq(recipient.id(), 1);
        assertEq(recipient.data(), "");
    }

    function testSafeTransferFromToERC721RecipientWithData() public {
        ERC721Recipient recipient = new ERC721Recipient();

        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        vm.prank(addresses.multisig);
        essay.setApprovalForAll(address(this), true);

        essay.safeTransferFrom(addresses.multisig, address(recipient), 1, "testing 456");

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(recipient));
        assertEq(essay.balanceOf(address(recipient)), 1);
        assertEq(essay.balanceOf(addresses.multisig), 0);

        assertEq(recipient.operator(), address(this));
        assertEq(recipient.from(), addresses.multisig);
        assertEq(recipient.id(), 1);
        assertEq(recipient.data(), "testing 456");
    }

    function testSafeTransferFromToNonERC721RecipientShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);
        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1);
    }

    function testSafeTransferFromToNonERC721RecipientWithDataShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1, "testing 456");
    }

    function testSafeTransferFromToRevertingERC721RecipientShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataWithDataShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, CONTENT_HASH, METADATA_URI);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1, "testing 456");
    }
}

contract ERC721Recipient is IERC721Receiver {
    address public operator;
    address public from;
    uint256 public id;
    bytes public data;

    function onERC721Received(address _operator, address _from, uint256 _id, bytes calldata _data)
        public
        virtual
        override
        returns (bytes4)
    {
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

    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        revert(string(abi.encodePacked(IERC721Receiver.onERC721Received.selector)));
    }
}

contract WrongReturnDataERC721Recipient is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) public virtual override returns (bytes4) {
        return 0xDEADCAFE;
    }
}
