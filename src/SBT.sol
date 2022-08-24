// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ISoulbound.sol";

import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/// @dev See {ISoulbound}.
abstract contract SBT is ISoulbound, ERC1155, Ownable {
    //

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	ISoulbound
    function hasToken(address _owner, uint256 _tokenId)
        external
        view
        returns (bool)
    {
        return _hasToken(_owner, _tokenId);
    }

    function _hasToken(address _owner, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return balanceOf(_owner, _tokenId) >= 1;
    }

    /// @inheritdoc	ISoulbound
    function hasTokenBatch(address[] calldata _owners, uint256 _tokenId)
        external
        view
        returns (bool[] memory)
    {
        bool[] memory hasTokens = new bool[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            hasTokens[i] = _hasToken(_owners[i], _tokenId);
        }

        return hasTokens;
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	ISoulbound
    function issue(address _recipient, uint256 _tokenId) external onlyOwner {
        _issue(_recipient, _tokenId);
    }

    function _issue(address _recipient, uint256 _tokenId) internal {
        emit Issue(address(this), _recipient, _tokenId);
        _mint(_recipient, _tokenId, 1, "");
    }

    /// @inheritdoc	ISoulbound
    function issueBatch(address[] calldata _recipients, uint256 _tokenId) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            _issue(_recipients[i], _tokenId);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	ISoulbound
    function revoke(address _owner, uint256 _tokenId, string calldata _reason) external onlyOwner {
        _revoke(_owner, _tokenId, _reason);
    }

    function _revoke(address _owner, uint256 _tokenId, string calldata _reason) internal {
        emit Revoke(address(this), _owner, _tokenId, _reason);
        _burn(_owner, _tokenId, 1);
    }

    /// @inheritdoc	ISoulbound
    function revokeBatch(address[] calldata _owners, uint256 _tokenId, string calldata _reason) external onlyOwner {
        for (uint256 i = 0; i < _owners.length; i++) {
            _revoke(_owners[i], _tokenId, _reason);
        }
    }
}
