// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {SBT} from "./SBT.sol";
import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";

/// @title A proof of contribution by members of the 1729 writers union
/// @author neodaoist, plaird
/// @notice A 1729w admin can issue proof of contribution tokens on this contract
/// @dev XYZ
contract SevenTeenTwentyNineProofOfContribution is SBT {
    //
    
    constructor(address _owner) ERC1155("") {
        transferOwnership(_owner);
    }

    /// @notice Get the Proof of Contribution token metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Proof of Contribution token
    /// @return Fully-qualified URI of a Proof of Contribution token, e.g., XYZ
    function uri(uint256 id) public view override returns (string memory) {
        return "";
    }
}
