// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ISoulbound.sol";

import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-contracts/utils/Counters.sol";

/// @dev See {ISoulbound}.
abstract contract SBT is ISoulbound, ERC1155, Ownable {
    //

    using Counters for Counters.Counter;

    /// @dev Check that a contribution exists
    /// @param _tokenId The token ID to check
    modifier contributionExists(uint256 _tokenId) {
        require(contributions[_tokenId].created, "SBT: no matching contribution found");        
        _;
    }

    /// @dev A representation of a specific type of contribution, for which SBTs can then be issued to contributors
    /// @param name The name of the contribution
    /// @param uri The fully qualified URI of the contribution JSON metadata
    /// @param created Flag to check if a given ContributionItem exists in the `contributions` mapping
    struct ContributionItem {
        string name;
        string uri;
        bool created;
    }

    mapping(uint256 => ContributionItem) public contributions;

    Counters.Counter internal nextTokenId;

    /*//////////////////////////////////////////////////////////////
                        Constructor
    //////////////////////////////////////////////////////////////*/

    constructor() ERC1155("") {
        nextTokenId.increment();  // start tokenId counter at 1
    }

    /*//////////////////////////////////////////////////////////////
                        Views
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the Proof of Contribution token metadata URI
    /// @param _tokenId The Token ID for a specific Proof of Contribution token
    /// @return Fully-qualified URI of a Proof of Contribution token
    function uri(uint256 _tokenId) public view override returns (string memory) {
        return contributions[_tokenId].uri;
    }

    /// @inheritdoc	ISoulbound
    function hasToken(address _owner, uint256 _tokenId)
        external
        view
        returns (bool)
    {
        return _hasToken(_owner, _tokenId);
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
                        Nontransferability
    //////////////////////////////////////////////////////////////*/

    /// @notice Soulbound tokens are nontransferable
    /// @dev In order to suppress compiler warnings (unused parameters and function mutability)
    /// @dev while overriding ERC1155 transfer functions, parameter names are commented out and 
    /// @dev function mutability is set to pure.
    function safeTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256 /*id*/,
        uint256 /*amount*/,
        bytes memory /*data*/
    ) public pure override {
        revert("SBT: soulbound tokens are nontransferable");
    }

    /// @notice Soulbound tokens are nontransferable
    /// @dev In order to suppress compiler warnings (unused parameters and function mutability)
    /// @dev while overriding ERC1155 transfer functions, parameter names are commented out and 
    /// @dev function mutability is set to pure.
    function safeBatchTransferFrom(
        address /*from*/,
        address /*to*/,
        uint256[] memory /*ids*/,
        uint256[] memory /*amounts*/,
        bytes memory /*data*/
    ) public pure override {
        revert("SBT: soulbound tokens are nontransferable");
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Creating
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	ISoulbound
    function createContribution(
        string calldata _contributionName,
        string calldata _contributionUri
    ) external onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId.current();
        nextTokenId.increment();

        contributions[tokenId] = ContributionItem(_contributionName, _contributionUri, true);

        return tokenId;
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	ISoulbound
    function issue(address _recipient, uint256 _tokenId) external onlyOwner {
        _issue(_recipient, _tokenId);
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

    /// @inheritdoc	ISoulbound
    function revokeBatch(address[] calldata _owners, uint256 _tokenId, string calldata _reason) external onlyOwner {
        for (uint256 i = 0; i < _owners.length; i++) {
            _revoke(_owners[i], _tokenId, _reason);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Rejecting
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	ISoulbound
    function reject(uint256 _tokenId) external contributionExists(_tokenId) {
        require(_hasToken(msg.sender, _tokenId), "SBT: no matching soulbound token found");
        
        emit Reject(msg.sender, _tokenId);
        _burn(msg.sender, _tokenId, 1);
    }

    /*//////////////////////////////////////////////////////////////
                        Internal Functions – Views
    //////////////////////////////////////////////////////////////*/

    /// @dev Internal function to determine if an EOA holds a given SBT, used by hasToken() and hasTokenBatch()
    function _hasToken(address _owner, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return balanceOf(_owner, _tokenId) >= 1;
    }

    /*//////////////////////////////////////////////////////////////
                        Internal Functions – Transactions
    //////////////////////////////////////////////////////////////*/

    /// @dev Internal function for Issue business logic, used by issue() and issueBatch()
    function _issue(address _recipient, uint256 _tokenId) internal contributionExists(_tokenId) {
        require(!_hasToken(_recipient, _tokenId), "SBT: a person can only receive one SBT per contribution");

        emit Issue(address(this), _recipient, _tokenId);
        _mint(_recipient, _tokenId, 1, "");
    }

    /// @dev Internal function for Revoke business logic, used by revoke() and revokeBatch()
    function _revoke(address _owner, uint256 _tokenId, string calldata _reason) internal contributionExists(_tokenId) {
        emit Revoke(address(this), _owner, _tokenId, _reason);
        _burn(_owner, _tokenId, 1);
    }
}
