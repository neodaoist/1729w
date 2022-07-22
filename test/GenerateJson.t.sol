// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "solidity-json-writer/JsonWriter.sol";

contract GenerateJsonTest is Test {
    //
    using JsonWriter for JsonWriter.Json;

    function testGenerateJSON() public {
        JsonWriter.Json memory writer;

        // Token ID, on-chain
        writer = writer.writeStartObject();
        writer = writer.writeUintProperty("Cohort", 2);
        writer = writer.writeUintProperty("Week", 1);
        writer = writer.writeStringProperty("Name", "Save the World");
        writer = writer.writeStringProperty("Image", "XYZ");
        writer = writer.writeStringProperty("Description", "ABC");
        writer = writer.writeStringProperty("Content Hash", "DEF");
        writer = writer.writeStringProperty("Writer Name", "Susmitha87539319");
        writer = writer.writeStringProperty("Writer Address", "0xCAFE");
        writer = writer.writeStringProperty("Publication URL", "https://testpublish.com/savetheworld");
        writer = writer.writeStringProperty("Archival URL", "pfs://xyzxyzxyz");
        writer = writer.writeUintProperty("Peer Attestation Count", 1337);
        writer = writer.writeEndObject();

        emit log (writer.value);
    }
}
