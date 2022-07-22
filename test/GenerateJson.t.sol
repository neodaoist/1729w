// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "solidity-json-writer/JsonWriter.sol";
import "jsmnSol/JsmnSolLib.sol";

contract GenerateJsonTest is Test {
    //
    using JsonWriter for JsonWriter.Json;

    uint constant RETURN_SUCCESS = 0;
    uint constant RETURN_ERROR_INVALID_JSON = 1;
    uint constant RETURN_ERROR_PART = 2;
    uint constant RETURN_ERROR_NO_MEM = 3;

    function testGenerateJson() public {
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

    function testParseJson() public {
        string memory json = '{"key": "value", "key2": "value2"}';

        uint returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint actualNum;

        (returnValue, tokens, actualNum) = JsmnSolLib.parse(json, 5);

        assertEq(returnValue, RETURN_SUCCESS);
        assertEq(JsmnSolLib.getBytes(json, tokens[1].start, tokens[1].end), 'key');
        assertEq(JsmnSolLib.getBytes(json, tokens[2].start, tokens[2].end), 'value');
        assertEq(JsmnSolLib.getBytes(json, tokens[3].start, tokens[3].end), 'key2');
        assertEq(JsmnSolLib.getBytes(json, tokens[4].start, tokens[4].end), 'value2');
    }
}
