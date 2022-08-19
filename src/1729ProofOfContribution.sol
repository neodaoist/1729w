// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC1155} from "solmate/tokens/ERC1155.sol";

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//         _ _____ ____   ___    __    __      _ _                        //
//        / |___  |___ \ / _ \  / / /\ \ \_ __(_) |_ ___ _ __ ___         //
//        | |  / /  __) | (_) | \ \/  \/ / '__| | __/ _ \ '__/ __|        //
//        | | / /  / __/ \__, |  \  /\  /| |  | | ||  __/ |  \__ \        //
//        |_|/_/  |_____|  /_/    \/  \/ |_|  |_|\__\___|_|  |___/        //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

/// @title A proof of contribution by members of the 1729 writers union
/// @author neodaoist, plaird
/// @notice A 1729w admin can issue proof of contribution tokens on this contract
/// @dev XYZ
contract OneSevenTwoNineProofOfContribution is ERC1155 {
    constructor() {}

    /// @notice Get the Proof of Contribution token metadata URI
    /// @dev XYZ
    /// @param id The Token ID for a specific Proof of Contribution token
    /// @return Fully-qualified URI of a Proof of Contribution token, e.g., XYZ
    function uri(uint256 id) public view override returns (string memory) {
        return "";
    }
}
