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

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _issuer Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _issuee Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    event Issue(
        address indexed _issuer,
        address indexed _issuee,
        uint256 _tokenId
    );

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _revoker Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _revokee Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _reason Documents a parameter just like in doxygen (must be followed by parameter name)
    event Revoke(
        address indexed _revoker,
        address indexed _revokee,
        uint256 _tokenId,
        string _reason
    );

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _owner Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    function hasToken(address _owner, uint256 _tokenId)
        external
        view
        returns (bool);

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _owners Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    function hasTokenBatch(
        address[] calldata _owners,
        uint256 _tokenId
    ) external view returns (bool[] memory);

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _recipient Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    function issue(address _recipient, uint256 _tokenId) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _recipients Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    function issueBatch(
        address[] calldata _recipients,
        uint256 _tokenId
    ) external;

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _owner Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _reason Documents a parameter just like in doxygen (must be followed by parameter name)
    function revoke(address _owner, uint256 _tokenId, string calldata _reason) external;

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _owners Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenId Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @param _reason Documents a parameter just like in doxygen (must be followed by parameter name)
    function revokeBatch(
        address[] calldata _owners,
        uint256 _tokenId,
        string calldata _reason
    ) external;
}
