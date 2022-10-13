// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ProofOfContribution} from "./ProofOfContribution.sol";

////////////////////////////////////////////////////////////////////////////
//                                                                        //
//         _ _____ ____   ___    __    __      _ _                        //
//        / |___  |___ \ / _ \  / / /\ \ \_ __(_) |_ ___ _ __ ___         //
//        | |  / /  __) | (_) | \ \/  \/ / '__| | __/ _ \ '__/ __|        //
//        | | / /  / __/ \__, |  \  /\  /| |  | | ||  __/ |  \__ \        //
//        |_|/_/  |_____|  /_/    \/  \/ |_|  |_|\__\___|_|  |___/        //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

/// @title 1729 Writers Proof of Contribution SBT
/// @author neodaoist
/// @author plaird
/// @notice The 1729 Writers community issues proof of contribution "soulbound tokens" (SBTs) with this contract
contract SevenTeenTwentyNineProofOfContribution is ProofOfContribution {
    //
    constructor(address _owner) {
        transferOwnership(_owner);
    }
}
