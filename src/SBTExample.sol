// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SBT} from "./SBT.sol";
import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";

contract SBTExample is SBT {
    //
    constructor() ERC1155("") {}
}
