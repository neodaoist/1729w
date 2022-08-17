// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ISoulbound.sol";
import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";

/// @dev See {ISBT}.
abstract contract SBT is ISoulbound, ERC1155 {
    //
    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function hasToken(address _owner, uint256 _tokenID)
        external
        view
        returns (bool) {}

    function hasTokenBatch(
        address[] calldata _owners,
        uint256[] calldata _tokenIDs
    ) external view returns (bool[] memory) {}

    function allOwnersOf(uint256 _tokenID)
        external
        view
        returns (address[] memory) {}

    function allTokensOf(address _owner)
        external
        view
        returns (uint256[] memory) {}

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    function issue(address _recipient, uint256 _tokenID) external {
        emit IssueSingle(address(this), _recipient, _tokenID, 1);
        _mint(_recipient, _tokenID, 1, "");
    }

    function issueBatch(
        address[] calldata _recipients,
        uint256 _tokenID
    ) external {
        for (uint256 i = 0; i < _recipients.length; i++) {
            _mint(_recipients[i], _tokenID, 1, "");
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    function revoke(address _recipient, uint256 _tokenID) external {}

    function revokeBatch(
        address[] calldata _recipients,
        uint256 _tokenID
    ) external {}
}
