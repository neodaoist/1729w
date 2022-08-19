// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title An idea for an 1155-flavored SBT / cryptocredential standard
/// @author neodaoist
/// @notice Just exploring for now, Keeping it simple and clear
/// @dev Further ideas — 3rd-Party Attestations, Hubs and Authorities, Reveal/Conceal Pattern
interface ISoulbound {
    //

    /*//////////////////////////////////////////////////////////////
                        Events
    //////////////////////////////////////////////////////////////*/

    event Issue(
        address indexed _issuer,
        address indexed _issuee,
        uint256 _tokenId
    );

    // event Revoke(
    //     address indexed _revoker,
    //     address indexed _revokee,
    //     uint256 _tokenId,
    //     uint256 _value
    // );

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    function hasToken(address _owner, uint256 _tokenId)
        external
        view
        returns (bool);

    function hasTokenBatch(
        address[] calldata _owners,
        uint256 _tokenId
    ) external view returns (bool[] memory);

    function allOwnersOf(uint256 _tokenId)
        external
        view
        returns (address[] memory);

    function allTokensOf(address _owner)
        external
        view
        returns (uint256[] memory);

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    function issue(address _recipient, uint256 _tokenId) external;

    function issueBatch(
        address[] calldata _recipients,
        uint256 _tokenId
    ) external;

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    function revoke(address _recipient, uint256 _tokenId) external;

    function revokeBatch(
        address[] calldata _recipients,
        uint256 _tokenId
    ) external;
}
