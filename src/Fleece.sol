// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "jsmnSol/JsmnSolLib.sol";
import "solidity-json-writer/JsonWriter.sol";

import {Essay} from "./1729Essay.sol";

/// @title Fleece
/// @author neodaoist
/// @dev A lightweight JSON parsing/reading/writing utility (very 1729-specific rn)
library Fleece {
    //
    using JsonWriter for JsonWriter.Json;

    uint8 internal constant MAX_NUMBER_OF_ESSAY_ELEMENTS = 23;
    
    uint8 internal constant RETURN_SUCCESS = 0;
    // uint8 internal constant RETURN_ERROR_INVALID_JSON = 1;
    // uint8 internal constant RETURN_ERROR_PART = 2;
    // uint8 internal constant RETURN_ERROR_NO_MEM = 3;

    function parseJson(string memory _json) internal pure returns (Essay memory) {
        uint256 returnValue;
        JsmnSolLib.Token[] memory tokens;
        uint256 actualNumberOfTokens;

        (returnValue, tokens, actualNumberOfTokens) = JsmnSolLib.parse(_json, MAX_NUMBER_OF_ESSAY_ELEMENTS);

        require(returnValue == RETURN_SUCCESS, "JSON parsing error, you have been slayed by the hydra");

        // TODO investigate type casting messiness here
        return Essay(
            uint8(uint(JsmnSolLib.parseInt(readJsonElement(_json, tokens, 2)))),
            uint8(uint(JsmnSolLib.parseInt(readJsonElement(_json, tokens, 4)))),
            uint16(uint(JsmnSolLib.parseInt(readJsonElement(_json, tokens, 6)))),
            readJsonElement(_json, tokens, 8),
            readJsonElement(_json, tokens, 10),
            readJsonElement(_json, tokens, 12),
            readJsonElement(_json, tokens, 14),
            readJsonElement(_json, tokens, 16),
            readJsonElement(_json, tokens, 18),
            readJsonElement(_json, tokens, 20),
            readJsonElement(_json, tokens, 22)
        );
    }

    function readJsonElement(string memory _json, JsmnSolLib.Token[] memory _elements, uint256 _index) private pure returns (string memory) {
        return JsmnSolLib.getBytes(_json, _elements[_index].start, _elements[_index].end);
    }

    function writeJson(Essay memory _essay) internal pure returns (string memory) {
        JsonWriter.Json memory writer;

        writer = writer.writeStartObject();
        writer = writer.writeUintProperty("Cohort", _essay.cohort);
        writer = writer.writeUintProperty("Week", _essay.week);
        writer = writer.writeUintProperty("Vote Count", _essay.voteCount);
        writer = writer.writeStringProperty("Name", _essay.name);
        writer = writer.writeStringProperty("Image", _essay.image);
        writer = writer.writeStringProperty("Description", _essay.description);
        writer = writer.writeStringProperty("Content Hash", _essay.contentHash);
        writer = writer.writeStringProperty("Writer Name", _essay.writerName);
        writer = writer.writeStringProperty("Writer Address", _essay.writerAddress);
        writer = writer.writeStringProperty("Publication URL", _essay.publicationURL);
        writer = writer.writeStringProperty("Archival URL", _essay.archivalURL);
        writer = writer.writeEndObject();
        
        return writer.value;
    }    
}
