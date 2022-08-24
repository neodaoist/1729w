// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// participating members
// total writers (not an explicit level of contribution)
// fully participating writers
// partially participating writers
// participating readers/voters
// participating bidders
// winning writers

struct TestAddresses {
    address userAddress;
    address secondUserAddress;
    address thirdUserAddress;
}

/// @dev Get a list of addresses
function getAddresses() pure returns (TestAddresses memory) {
    TestAddresses memory addresses = TestAddresses({
        userAddress: address(0x1),
        secondUserAddress: address(0x2),
        thirdUserAddress: address(0x3)
    });

    return addresses;
}
