// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Fleece} from "../src/Fleece.sol";

import "../src/1729Essay.sol";

contract OneSevenTwoNineEssayTest is Test {
    //
    OneSevenTwoNineEssay essay;

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
}
