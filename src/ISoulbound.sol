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

    /// @notice Emitted when a new Contribution is created
    /// @param tokenId The token ID of the newly created contribution
    /// @param contributionName The name of the contribution
    /// @param contributionUri The fully qualified URI of the contribution JSON metadata
    event NewContribution(uint256 indexed tokenId, string contributionName, string contributionUri);

    /// @notice Emitted when an SBT is issued to an address
    /// @param issuer The issuing body (the concrete implementation of the SBT contract)
    /// @param issuee The address receiving the SBT
    /// @param tokenId The token ID of the SBT being issued
    event Issue(address indexed issuer, address indexed issuee, uint256 indexed tokenId);

    /// @notice Emitted when an SBT is revoked from an address by the issuing body
    /// @param revoker The issuing body (the concrete implementation of the SBT contract)
    /// @param revokee The address that previously held, but no longer holds, the SBT
    /// @param tokenId The token ID of the SBT being revoked
    /// @param reason A brief message describing the reason for revoking the SBT
    event Revoke(address indexed revoker, address indexed revokee, uint256 indexed tokenId, string reason);

    /// @notice Emitted when an SBT is rejected by the owner of that token
    /// @param rejecter The address that previously held, but no longer holds, the SBT
    /// @param tokenId The token ID of the SBT being rejected
    event Reject(address indexed rejecter, uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    /// @notice Check if an address holds the given SBT
    /// @param _owner The address to check
    /// @param _tokenId The token ID of the SBT to check
    /// @return A boolean value expressing if this address holds this SBT
    function hasToken(address _owner, uint256 _tokenId) external view returns (bool);

    /// @notice Check if multiple addresses hold the given SBT
    /// @param _owners The addresses to check
    /// @param _tokenId The token ID of the SBT to check
    /// @return An array of boolean values expressing if these addresses hold this SBT,
    /// with the same number of elements, in the same order, as the _owners parameter
    function hasTokenBatch(address[] calldata _owners, uint256 _tokenId) external view returns (bool[] memory);

    /*//////////////////////////////////////////////////////////////
                        Transactions – Creating
    //////////////////////////////////////////////////////////////*/

    /// @notice Create a contribution so that SBTs can be issued for it
    /// @param _contributionName The name of the contribution
    /// @param _contributionUri The fully qualified URI of the contribution JSON metadata
    /// @return The token ID of the newly created contribution
    function createContribution(string calldata _contributionName, string calldata _contributionUri)
        external
        returns (uint256);

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    /// @notice Issue an SBT to a single address
    /// @param _recipient The address to receive the SBT
    /// @param _tokenId The token ID of the SBT
    function issue(address _recipient, uint256 _tokenId) external;

    /// @notice Issue an SBT to multiple addresses
    /// @param _recipients The addresses to receive the SBT
    /// @param _tokenId The token ID of the SBT
    function issueBatch(address[] calldata _recipients, uint256 _tokenId) external;

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    /// @notice Revoke an SBT from a single address
    /// @param _owner The address that currently holds, but will no longer hold, the SBT
    /// @param _tokenId The token ID of the SBT
    function revoke(address _owner, uint256 _tokenId, string calldata _reason) external;

    /// @notice Revoke an SBT from multiple addresses
    /// @param _owners The addresses that currently hold, but will no longer hold, the SBT
    /// @param _tokenId The token ID of the SBT
    function revokeBatch(address[] calldata _owners, uint256 _tokenId, string calldata _reason) external;

    /*//////////////////////////////////////////////////////////////
                        Transactions – Rejecting
    //////////////////////////////////////////////////////////////*/

    /// @notice Reject an SBT as the owner of the token
    /// @param _tokenId The token ID of the SBT
    function reject(uint256 _tokenId) external;
}
