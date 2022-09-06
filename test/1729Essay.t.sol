// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import {OneSevenTwoNineEssay} from "../src/1729Essay.sol";
import {Fleece} from "../src/Fleece.sol";
import {Essay} from "../src/models/Essay.sol";

import "forge-std/Test.sol";
import "./Fixtures.sol";

import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

contract OneSevenTwoNineEssayTest is Test {
    //

    OneSevenTwoNineEssay essay;

    TestAddresses addresses;

    string EXPECTED_BASE_URI = "https://nftstorage.link/ipfs/bafybeiblfxmzzzhllcappbk5t2ujmmton5wfkmaujueqrvluh237bpzale/";

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event RoyaltyPercentageUpdated(uint96 newPercentageInBips);

    /*//////////////////////////////////////////////////////////////
                        Set Up
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        addresses = getAddresses();
        essay= new OneSevenTwoNineEssay(addresses.multisig);
    }

    function testInvariantMetadata() public {
        assertEq(essay.name(), "1729 Writers Essay NFT");
        assertEq(essay.symbol(), "1729ESSAY");
    }

    /*//////////////////////////////////////////////////////////////
                        URI Storage
    //////////////////////////////////////////////////////////////*/

    // TODO think about this test - currently it's misleading as to actual contract behavior
    function testURIStorage() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);  // 1
        essay.mint(addresses.writer1, string(abi.encodePacked(EXPECTED_BASE_URI, "2")));
        essay.mint(addresses.writer1, string(abi.encodePacked(EXPECTED_BASE_URI, "3")));
        essay.mint(addresses.writer1, string(abi.encodePacked(EXPECTED_BASE_URI, "4")));

        assertEq(essay.tokenURI(1), EXPECTED_BASE_URI);
        assertEq(essay.tokenURI(2), string(abi.encodePacked(EXPECTED_BASE_URI, "2")));
        assertEq(essay.tokenURI(3), string(abi.encodePacked(EXPECTED_BASE_URI, "3")));
        assertEq(essay.tokenURI(4), string(abi.encodePacked(EXPECTED_BASE_URI, "4")));
    }

    /*//////////////////////////////////////////////////////////////
                        JSON tests
    //////////////////////////////////////////////////////////////*/

    function testReadJsonMetadata() public {
        // mock 4 tokens for unit testing JSON metadata returned from tokenURI() view
        // TODO load example JSON
        vm.mockCall(
            address(essay),
            abi.encodeWithSelector(OneSevenTwoNineEssay.tokenURI.selector, 1),
            abi.encode("hello world 1")
        );
        vm.mockCall(
            address(essay),
            abi.encodeWithSelector(OneSevenTwoNineEssay.tokenURI.selector, 2),
            abi.encode("hello world 2")
        );
        vm.mockCall(
            address(essay),
            abi.encodeWithSelector(OneSevenTwoNineEssay.tokenURI.selector, 3),
            abi.encode("hello world 3")
        );
        vm.mockCall(
            address(essay),
            abi.encodeWithSelector(OneSevenTwoNineEssay.tokenURI.selector, 4),
            abi.encode("hello world 4")
        );

        assertEq(essay.tokenURI(1), "hello world 1");
        assertEq(essay.tokenURI(2), "hello world 2");
        assertEq(essay.tokenURI(3), "hello world 3");
        assertEq(essay.tokenURI(4), "hello world 4");
    }

    function testParseJsonMetadata() public {
        string memory json = '{"Cohort": 2,"Week": 3,"Status": "Weekly Winner","Name": "Save the World","Image": "XYZ","Description": "ABC","Content Hash": "DEF","Writer Name": "Susmitha87539319","Writer Address": "0xCAFE","Publication URL": "https://testpublish.com/savetheworld","Archival URL": "ipfs://xyzxyzxyz"}';
        Essay memory winningEssay = Fleece.parseJson(json);
        assertEq(winningEssay.cohort, 2);
        assertEq(winningEssay.week, 3);
        assertEq(winningEssay.status, "Weekly Winner");
        assertEq(winningEssay.name, "Save the World");
        assertEq(winningEssay.image, "XYZ");
        assertEq(winningEssay.description, "ABC");
        assertEq(winningEssay.contentHash, "DEF");
        assertEq(winningEssay.writerName, "Susmitha87539319");
        assertEq(winningEssay.writerAddress, "0xCAFE");
        assertEq(winningEssay.publicationURL, "https://testpublish.com/savetheworld");
        assertEq(winningEssay.archivalURL, "ipfs://xyzxyzxyz");
    }

    function testWriteJsonMetadata() public {
        Essay memory winningEssay = Essay(
            2,
            3,
            "Weekly Winner",
            "Save the World",
            "XYZ",
            "ABC",
            "DEF",
            "Susmitha87539319",
            "0xCAFE",
            "https://testpublish.com/savetheworld",
            "ipfs://xyzxyzxyz"
        );

        string memory json = Fleece.writeJson(winningEssay);
        Essay memory parsedEssay = Fleece.parseJson(json);

        assertEq(winningEssay.cohort, parsedEssay.cohort);
        assertEq(winningEssay.week, parsedEssay.week);
        assertEq(winningEssay.status, parsedEssay.status);
        assertEq(winningEssay.name, parsedEssay.name);
        assertEq(winningEssay.image, parsedEssay.image);
        assertEq(winningEssay.description, parsedEssay.description);
        assertEq(winningEssay.contentHash, parsedEssay.contentHash);
        assertEq(winningEssay.writerName, parsedEssay.writerName);
        assertEq(winningEssay.writerAddress, parsedEssay.writerAddress);

        // TODO address JSON character escaping issue for 2 URL members
        // assertEq(winningEssay.publicationURL, parsedEssay.publicationURL);
        // e.g.,
        // ├─ emit log_named_string(key: "  Expected", val: "https:\\/\\/testpublish.com\\/savetheworld")
        // ├─ emit log_named_string(key: "    Actual", val: "https://testpublish.com/savetheworld")
        // assertEq(winningEssay.archivalURL, parsedEssay.archivalURL);
    }

    function testImplementsInterface() public {
        assertTrue(essay.supportsInterface(0x80ac58cd));  // ERC721
        assertTrue(essay.supportsInterface(0x5b5e139f)); // ERC721Metadata
        assertTrue(essay.supportsInterface(0x2a55205a)); // ERC2981
        assertFalse(essay.supportsInterface(0x00));
    }

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function testMint() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        assertEq(essay.balanceOf(addresses.multisig), 1);
        assertEq(essay.ownerOf(1), addresses.multisig);
    }

/* FIXME: Can't test due to private _mint function
    function testDoubleMintShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay._mint(1337, addresses.writer1, EXPECTED_BASE_URI);

        vm.expectRevert("ERC721: essayalready minted");

        essay._mint(1337, addresses.writer1, EXPECTED_BASE_URI);
    }

    function testMintFuzzy(uint256 id) public {
        vm.prank(addresses.multisig);
        essay._mint(id, addresses.writer1, EXPECTED_BASE_URI);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }
    */

    function testMintWhenNotOwnerShouldFail() public {
        vm.expectRevert("Ownable: caller is not the owner");

        essay.mint(addresses.writer1, EXPECTED_BASE_URI);
    }

    ////////////////////////////////////////////////
    ////////////////    Burn    ////////////////////
    ////////////////////////////////////////////////

    function testBurn() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);
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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        essay.burn(1);

        vm.expectRevert("ERC721: invalid token ID");

        essay.burn(1);
    }

    function testBurnWhenNotOwnerShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.expectRevert("Ownable: caller is not the owner");

        essay.burn(1);
    }

/* Disabled due to private _mint function
    function testBurnFuzzy(uint256 id) public {
        vm.prank(addresses.multisig);
        essay._mint(id, addresses.writer1, EXPECTED_BASE_URI);
        vm.prank(addresses.multisig);
        essay.burn(id);

        assertEq(essay.balanceOf(addresses.multisig), 0);

        vm.expectRevert("ERC721: invalid token ID");
        essay.ownerOf(id);
    }
*/

    ////////////////////////////////////////////////
    ////////////////    Approve    /////////////////
    ////////////////////////////////////////////////

    function testApprove() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.expectEmit(true, true, true, true);
        emit Approval(addresses.multisig, address(0xBABE), 1);

        vm.prank(addresses.multisig);
        essay.approve(address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0xBABE));
    }

    function testMultipleApprove() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        essay.approve(address(0xABCD), 1);
        essay.approve(address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0xBABE));
    }

    function testApproveBurn() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.expectRevert(
            "ERC721: approve caller is not token owner or approved for all"
        );

        essay.approve(address(0xBABE), 1);
    }

    ////////////////////////////////////////////////
    ////////////////    Balance Of    //////////////
    ////////////////////////////////////////////////

    function testBalanceOf() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }

    function testBalanceOfWithTwoMints() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);  // 1
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);  // 2

        assertEq(essay.balanceOf(addresses.multisig), 2);
    }

    function testBalanceOfWhenOwningNone() public {
        assertEq(essay.balanceOf(addresses.multisig), 0);
    }

    function testBalanceOfAfterBurn() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        essay.burn(1);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }

    function testBalanceOfAfterTransferring() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        essay.transferFrom(addresses.multisig, address(this), 1);

        assertEq(essay.balanceOf(addresses.multisig), 1);
    }

    function testBalanceOfAfterReceivingTransfer() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        assertEq(essay.ownerOf(1), addresses.multisig);
    }

    function testOwnerOfUnmintedShouldFail() public {
        vm.expectRevert("ERC721: invalid token ID");

        essay.ownerOf(1337);
    }

    function testOwnerOfAfterTransfer() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        assertEq(essay.ownerOf(1), addresses.multisig);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.ownerOf(1), address(0xBABE));
    }

    ////////////////////////////////////////////////
    ////////////////    Transfer    ////////////////
    ////////////////////////////////////////////////

    function testTransferFrom() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        essay.transferFrom(addresses.multisig, address(0xBABE), 1);

        assertEq(essay.getApproved(1), address(0));
        assertEq(essay.ownerOf(1), address(0xBABE));
        assertEq(essay.balanceOf(address(0xBABE)), 1);
        assertEq(essay.balanceOf(address(this)), 0);
    }

    function testTransferFromApproveAll() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        essay.transferFrom(address(0xBABE), address(0xABCD), 1);
    }

    function testTransferFromToZeroAddressShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        essay.transferFrom(addresses.multisig, address(0), 1);
    }

    function testTransferFromWithNotOwnerOrUnapprovedSpenderShouldFail() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.expectRevert("ERC721: caller is not token owner or approved");

        essay.transferFrom(addresses.multisig, address(0xABCD), 1);
    }

    ////////////////////////////////////////////////
    ////////////////    Safe Transfer    ///////////
    ////////////////////////////////////////////////

    function testSafeTransferFromToEOA() public {
        vm.prank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        vm.prank(addresses.multisig);
        essay.setApprovalForAll(address(this), true);

        essay.safeTransferFrom(
            addresses.multisig, address(recipient), 1, "testing 456"
        );

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
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);
        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1);
    }

    function testSafeTransferFromToNonERC721RecipientWithDataShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1, "testing 456");
    }

    function testSafeTransferFromToRevertingERC721RecipientShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        address to = address(new NonERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1);
    }

    function testSafeTransferFromToERC721RecipientWithWrongReturnDataWithDataShouldFail() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI);

        address to = address(new WrongReturnDataERC721Recipient());

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");

        essay.safeTransferFrom(addresses.multisig, to, 1, "testing 456");
    }

    // Contract should NOT support receiving funds directly
    function testReceiveFundsDisabled() public {
        vm.prank(addresses.multisig);
        vm.expectRevert("Contract should not accept payment directly");
        (bool result, ) = address(essay).call{value:1000000000}("");

        assertFalse(result, "Contract should not accept payment");
    }

    ////////////////////////////////////////////////
    ////////////    Token ID Incrementing   ////////
    ////////////////////////////////////////////////

    function testFirstMintIsOne() public {
        vm.startPrank(addresses.multisig);
        uint256 newId = essay.mint(addresses.writer1, EXPECTED_BASE_URI);
        assertEq(newId, 1);
    }

    function testTotalSupply() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1, EXPECTED_BASE_URI); // 1
        uint256 two = essay.mint(addresses.writer1, EXPECTED_BASE_URI); // 2
        assertEq(two, 2);
        assertEq(essay.totalSupply(), 2);
        uint256 three = essay.mint(addresses.writer1, EXPECTED_BASE_URI); // 3
        assertEq(three, 3);
        assertEq(essay.totalSupply(), 3);
        essay.burn(2);  // burning does not reduce total supply
        assertEq(essay.totalSupply(), 3);
        uint256 four = essay.mint(addresses.writer1, EXPECTED_BASE_URI); // 3
        assertEq(four, 4);
        assertEq(essay.totalSupply(), 4);
    }

    /*//////////////////////////////////////////////////////////////
                        Royalty
    //////////////////////////////////////////////////////////////*/

    function testRoyalty() public {
        vm.startPrank(addresses.multisig);
        essay.mint(addresses.writer1,"https://testpublish.com/savetheworld");
        essay.mint(addresses.writer2,"https://testpublish2.com/abc");
        essay.mint(addresses.writer3,"https://testpublish3.com/xyz");

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
    )
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

    function onERC721Received(address, address, uint256, bytes calldata)
        public
        virtual
        override
        returns (bytes4)
    {
        revert(
            string(abi.encodePacked(IERC721Receiver.onERC721Received.selector))
        );
    }
}

contract WrongReturnDataERC721Recipient is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata)
        public
        virtual
        override
        returns (bytes4)
    {
        return 0xDEADCAFE;
    }
}
