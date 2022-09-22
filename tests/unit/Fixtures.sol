// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// participating members
// total writers (not an explicit level of contribution)
// fully participating writers
// partially participating writers
// readers/voters
// auction bidders
// winning writers

struct TestAddresses {
    address multisig;
    address writer1;
    address writer2;
    address writer3;
    address writer4;
    address writer5;
    address random;
}

/// @dev Get a list of addresses
function getAddresses() pure returns (TestAddresses memory) {
    TestAddresses memory addresses = TestAddresses({
        multisig: address(0x1729),
        writer1: address(0x1),
        writer2: address(0x2),
        writer3: address(0x3),
        writer4: address(0x4),
        writer5: address(0x5),
        random: address(0xABCD)
    });

    return addresses;
}
