// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @title An idea for an 1155-flavored SBT / cryptocredential standard
/// @author neodaoist
/// @notice Just exploring for now, Keeping it simple and clear
/// @dev Further ideas — 3rd-Party Attestations, Hubs and Authorities, Reveal/Conceal Pattern
interface SBT {
    //

    /*//////////////////////////////////////////////////////////////
                        Events
    //////////////////////////////////////////////////////////////*/

    event IssueSingle(address indexed _issuer, address indexed _issuee, uint256 _tokenID, uint256 _value);

    event IssueBatch(address indexed _issuer, address indexed _issuee, uint256[] _tokenIDs, uint256[] _values);

    event RevokeSingle(address indexed _revoker, address indexed _revokee, uint256 _tokenID, uint256 _value);

    event RevokeBatch(address indexed _revoker, address indexed _revokee, uint256[] _tokenIDs, uint256[] _values);

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function hasToken(address _owner, uint256 _tokenID) external view returns (bool);

    function hasTokenBatch(address[] calldata _owners, uint256[] calldata _tokenIDs)
        external
        view
        returns (bool[] memory);

    function allOwnersOf(uint256 _tokenID) external view returns (address[] memory);

    function allTokensOf(address _owner) external view returns (uint256[] memory);

    /*//////////////////////////////////////////////////////////////
                        Issuing
    //////////////////////////////////////////////////////////////*/

    function issue(address _recipient, uint256 _tokenID) external;

    function issueBatch(address[] calldata _recipients, uint256[] calldata _tokenIDs) external;

    /*//////////////////////////////////////////////////////////////
                        Revoking
    //////////////////////////////////////////////////////////////*/

    function revoke(address _recipient, uint256 _tokenID) external;

    function revokeBatch(address[] calldata _recipients, uint256[] calldata _tokenIDs) external;
}
