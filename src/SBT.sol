// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @title An idea for an 1155-flavored SBT / cryptocredential standard
/// @author neodaoist
/// @notice xyz
/// @dev Just exploring now, Keeping it simple and clear
abstract contract SBT {
    //

    /*//////////////////////////////////////////////////////////////
                        Events
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _tokenID, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _tokenIDs, uint256[] _values);

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function balanceOf(address _owner, uint256 _tokenID) external virtual view returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _tokenIDs) external virtual view returns (uint256[] memory);

    function allOwnersOf(uint256 _tokenID) external virtual view returns (address[] memory);

    function allTokensOf(address _owner) external virtual view returns (uint256[] memory);

    /*//////////////////////////////////////////////////////////////
                        Issuing
    //////////////////////////////////////////////////////////////*/

    function issue(address _recipient, uint256 _tokenID) external virtual;

    function issueBatch(address[] calldata _recipients, uint256[] calldata _tokenIDs) external virtual;

    /*//////////////////////////////////////////////////////////////
                        Revoking
    //////////////////////////////////////////////////////////////*/

    function revoke(address _recipient, uint256 _tokenID) external virtual;

    function revokeBatch(address[] calldata _recipients, uint256[] calldata _tokenIDs) external virtual;
}
