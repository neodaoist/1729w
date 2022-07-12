// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {OneSevenTwoNineEssay} from "../src/1729Essay.sol";

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
}
