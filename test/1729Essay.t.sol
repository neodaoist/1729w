// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Fleece} from "../src/Fleece.sol";

import "../src/1729Essay.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract OneSevenTwoNineEssayTest is Test {
    //
    OneSevenTwoNineEssay essay;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    function setUp() public {
        essay = new OneSevenTwoNineEssay();
    }

    function testInvariantMetadata() public {
        assertEq(essay.name(), "1729 Essay");
        assertEq(essay.symbol(), "1729ESSAY");
    }

    function testReadJsonMetadata() public {
        string memory json = essay.tokenURI(1);
        Essay memory winningEssay = Fleece.parseJson(json);

        assertEq(winningEssay.cohort, 2);
        assertEq(winningEssay.week, 3);
        assertEq(winningEssay.voteCount, 1337);
        assertEq(winningEssay.name, "Save the World");
        assertEq(winningEssay.image, "XYZ");
        assertEq(winningEssay.description, "ABC");
        assertEq(winningEssay.contentHash, "DEF");
        assertEq(winningEssay.writerName, "Susmitha87539319");
        assertEq(winningEssay.writerAddress, "0xCAFE");
        assertEq(
            winningEssay.publicationURL,
            "https://testpublish.com/savetheworld"
        );
        assertEq(winningEssay.archivalURL, "ipfs://xyzxyzxyz");
    }

    function testWriteJsonMetadata() public {
        Essay memory winningEssay = Essay(
            2,
            3,
            1337,
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
        assertEq(winningEssay.voteCount, parsedEssay.voteCount);
        assertEq(winningEssay.name, parsedEssay.name);
        assertEq(winningEssay.image, parsedEssay.image);
        assertEq(winningEssay.description, parsedEssay.description);
        assertEq(winningEssay.contentHash, parsedEssay.contentHash);
        assertEq(winningEssay.writerName, parsedEssay.writerName);
        assertEq(winningEssay.writerAddress, parsedEssay.writerAddress);

        // TODO address JSON character escaping issue for 2 URL members
        // e.g.,
        // ├─ emit log_named_string(key: "  Expected", val: "https:\\/\\/testpublish.com\\/savetheworld")
        // ├─ emit log_named_string(key: "    Actual", val: "https://testpublish.com/savetheworld")

        // assertEq(winningEssay.publicationURL, parsedEssay.publicationURL);
        // assertEq(winningEssay.archivalURL, parsedEssay.archivalURL);
    }

    function testImplementsInterface() public {
        assertTrue(essay.supportsInterface(_INTERFACE_ID_ERC2981));
        assertTrue(essay.supportsInterface(0x80ac58cd));  // ERC721
        assertTrue(essay.supportsInterface(0x5b5e139f)); // IERC721Metadata
        //assertTrue(essay.supportsInterface(0x780e9d63)); // IERC721Enumerable -- FIXME: do we need this?
        assertFalse(essay.supportsInterface(0x00));
    }

    function testRoyalty() public {
        address author = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
        essay.mint(7,author,100,"https://testpublish.com/savetheworld");
        (address recipient, uint256 amount) = essay.royaltyInfo(7, 100000);
        assertEq(author, recipient);
        assertEq(amount, 10000); // 10%
    }
}
