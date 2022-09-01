// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title An ERC1155-flavored SBT / cryptocredential standard
/// @author neodaoist
/// @dev Just exploring for now, keeping the interface simple and clear
interface ISoulbound {
    //

    /*//////////////////////////////////////////////////////////////
                        Events
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an SBT is issued to an address
    /// @param _issuer The issuing body (the concrete implementation of the SBT contract)
    /// @param _issuee The address receiving the SBT
    /// @param _tokenId The token ID of the SBT being issued
    event Issue(
        address indexed _issuer,
        address indexed _issuee,
        uint256 _tokenId
    );

    /// @notice Emitted when an SBT is revoked from an address
    /// @param _revoker The issuing body (the concrete implementation of the SBT contract)
    /// @param _revokee The address that previously held, but no longer holds, the SBT
    /// @param _tokenId The token ID of the SBT being revoked
    /// @param _reason A brief message describing the reason for revoking the SBT
    event Revoke(
        address indexed _revoker,
        address indexed _revokee,
        uint256 _tokenId,
        string _reason
    );

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    /// @notice Check if an address holds the given SBT
    /// @param _owner The address to check
    /// @param _tokenId The token ID of the SBT to check
    /// @return A boolean value expressing if this address holds this SBT
    function hasToken(address _owner, uint256 _tokenId)
        external
        view
        returns (bool);

    /// @notice Check if multiple addresses hold the given SBT
    /// @param _owners The addresses to check
    /// @param _tokenId The token ID of the SBT to check
    /// @return An array of boolean values expressing if these addresses hold this SBT,
    /// with the same number of elements, in the same order, as the _owners parameter
    function hasTokenBatch(
        address[] calldata _owners,
        uint256 _tokenId
    ) external view returns (bool[] memory);

    /*//////////////////////////////////////////////////////////////
                        Transactions – Creating
    //////////////////////////////////////////////////////////////*/

    // TODO add doc
    function createContribution(
        uint256 _tokenId,
        string calldata _contributionName,
        string calldata _contributionUri
    ) external;

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    /// @notice Issue an SBT to a single address
    /// @dev Currently token ID management is left to the end user
    /// @param _issuee The address to receive the SBT
    /// @param _tokenId The token ID of the SBT
    function issue(address _issuee, uint256 _tokenId) external;

    /// @notice Issue an SBT to multiple addresses
    /// @dev Currently token ID management is left to the end user
    /// @param _issuees The addresses to receive the SBT
    /// @param _tokenId The token ID of the SBT
    function issueBatch(
        address[] calldata _issuees,
        uint256 _tokenId
    ) external;

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    /// @notice Revoke an SBT from a single address
    /// @param _revokee The address that currently holds, but will no longer hold, the SBT
    /// @param _tokenId The token ID of the SBT
    function revoke(address _revokee, uint256 _tokenId, string calldata _reason) external;

    /// @notice Revoke an SBT from multiple addresses
    /// @param _revokees The addresses that currently hold, but will no longer hold, the SBT
    /// @param _tokenId The token ID of the SBT
    function revokeBatch(
        address[] calldata _revokees,
        uint256 _tokenId,
        string calldata _reason
    ) external;
}
