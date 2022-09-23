// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct TestAddresses {
    address payable multisig;
    address payable writer1;
    address payable writer2;
    address payable writer3;
    address payable random;
}

/// @dev Get test addresses
function getAddresses() pure returns (TestAddresses memory) {
    TestAddresses memory addresses = TestAddresses({
        multisig: payable(address(0x1729)),
        writer1: payable(address(0xA1)),
        writer2: payable(address(0xA2)),
        writer3: payable(address(0xA3)),
        random: payable(address(0xABCD))
    });

    return addresses;
}

/// @dev Get an array of test addresses (for use in batch tests)
function getBatchAddresses(uint160 number) pure returns (address[] memory) {
    address[] memory contributors = new address[](number);

    for (uint160 i = 0; i < number; i++) {
        contributors[i] = address(0xABCDEF + i);
    }

    return contributors;
}

/// @dev Get an array of payable test addresses (for use in batch tests)
function getBatchPayableAddresses(uint160 number) pure returns (address payable[] memory) {
    address payable[] memory contributors = new address payable[](number);

    for (uint160 i = 0; i < number; i++) {
        contributors[i] = payable(address(0xABCDEF + i));
    }

    return contributors;
}
