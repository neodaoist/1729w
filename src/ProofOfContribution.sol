// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IProofOfContribution.sol";

import {ERC1155} from "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-contracts/utils/Counters.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";

/// @dev See {IProofOfContribution}
abstract contract ProofOfContribution is IProofOfContribution, ERC1155, Ownable {
    //
    using Counters for Counters.Counter;

    /// @dev Check that a contribution exists
    /// @param _tokenId The token ID to check
    modifier contributionExists(uint256 _tokenId) {
        require(bytes(contributions[_tokenId].name).length > 0, "ProofOfContribution: no matching contribution found");
        _;
    }

    /// @dev Revert overridden ERC1155 functions related to post-mint transfers. Function body
    /// @dev is placed before revert statement here (even though all 4 function bodies are 
    /// @dev empty and logically revert statement should come first), in order to avoid a
    /// @dev compiler warning related to unreachable code in functions with this modifier applied.
    modifier nontransferable() {
        _;
        revert("ProofOfContribution: soulbound tokens are nontransferable");
    }

    /// @dev A representation of a specific type of contribution, for which SBTs can then be issued to contributors
    /// @param name The name of the contribution
    /// @param uri The fully qualified URI of the contribution JSON metadata
    /// @param created Flag to check if a given ContributionItem exists in the `contributions` mapping
    struct ContributionItem {
        string name;
        string uri;
    }

    mapping(uint256 => ContributionItem) public contributions;

    Counters.Counter internal nextTokenId;

    /*//////////////////////////////////////////////////////////////
                        Constructor
    //////////////////////////////////////////////////////////////*/

    constructor() ERC1155("") {
        nextTokenId.increment(); // start tokenId counter at 1
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

    /// @inheritdoc	IProofOfContribution
    function hasToken(address _owner, uint256 _tokenId) external view returns (bool) {
        return _hasToken(_owner, _tokenId);
    }

    /// @inheritdoc	IProofOfContribution
    function hasTokenBatch(address[] calldata _owners, uint256 _tokenId) external view returns (bool[] memory) {
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
    /// @dev The nontransferable modifier is applied to revert this function in all cases.
    /// @dev In order to avoid a compiler warning related to unused parameters while
    /// @dev overriding these ERC1155 transfer functions, parameter names are commented out.
    /// @dev In addition, function mutability is set to pure to achieve slight gas savings.
    function safeTransferFrom(
        address, /*from*/
        address, /*to*/
        uint256, /*id*/
        uint256, /*amount*/
        bytes memory /*data*/
    ) public pure override nontransferable {}

    /// @notice Soulbound tokens are nontransferable
    /// @dev See safeTransferFrom() documentation for additional info
    function safeBatchTransferFrom(
        address, /*from*/
        address, /*to*/
        uint256[] memory, /*ids*/
        uint256[] memory, /*amounts*/
        bytes memory /*data*/
    ) public pure override nontransferable {}

    /// @notice Soulbound tokens are nontransferable
    /// @dev See safeTransferFrom() documentation for additional info
    function setApprovalForAll(address, /*operator*/ bool /*approved*/ ) public pure override nontransferable {}

    /// @notice Soulbound tokens are nontransferable
    /// @dev See safeTransferFrom() documentation for additional info
    function isApprovedForAll(address, /*account*/ address /*operator*/ )
        public
        pure
        override
        nontransferable
        returns (bool)
    {}

    /*//////////////////////////////////////////////////////////////
                        Transactions – Creating
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	IProofOfContribution
    /// @dev _contributionName cannot be empty, in order to more efficiently check if a contribution exists
    /// @dev in the contributionExists modifier
    function createContribution(string calldata _contributionName, string calldata _contributionUri)
        external
        onlyOwner
        returns (uint256)
    {
        require(bytes(_contributionName).length > 0, "ProofOfContribution: contribution name cannot be empty");

        uint256 tokenId = nextTokenId.current();
        nextTokenId.increment();

        contributions[tokenId] = ContributionItem(_contributionName, _contributionUri);

        emit NewContribution(tokenId, _contributionName, _contributionUri);

        return tokenId;
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Issuing
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	IProofOfContribution
    function issue(address payable _recipient, uint256 _tokenId) external payable onlyOwner {
        _issue(_recipient, _tokenId);

        if (msg.value > 0) {
            // forward any ether to recipient
            Address.sendValue(_recipient, msg.value);
        }
    }

    /// @inheritdoc	IProofOfContribution
    function issueBatch(address payable[] calldata _recipients, uint256 _tokenId) external payable onlyOwner {
        require(_recipients.length <= 100, "ProofOfContribution: can not issue more than 100 SBTs in a single transaction");

        if (msg.value > 0) {
            uint256 valueToSend = msg.value / _recipients.length;

            // issue SBTs and forward any ether to recipients, divided equally
            for (uint256 i = 0; i < _recipients.length; i++) {
                _issue(_recipients[i], _tokenId);
                Address.sendValue(_recipients[i], valueToSend);
            }

            // cleanup any dust leftover
            uint256 balance = address(this).balance;
            if (balance > 0) {
                Address.sendValue(payable(msg.sender), balance);
            }
        } else {
            // no ether included, so just do basic issuing SBTs loop
            for (uint256 i = 0; i < _recipients.length; i++) {
                _issue(_recipients[i], _tokenId);
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Revoking
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	IProofOfContribution
    function revoke(address _owner, uint256 _tokenId, string calldata _reason) external onlyOwner {
        _revoke(_owner, _tokenId, _reason);
    }

    /// @inheritdoc	IProofOfContribution
    function revokeBatch(address[] calldata _owners, uint256 _tokenId, string calldata _reason) external onlyOwner {
        for (uint256 i = 0; i < _owners.length; i++) {
            _revoke(_owners[i], _tokenId, _reason);
        }
    }

    /*//////////////////////////////////////////////////////////////
                        Transactions – Rejecting
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc	IProofOfContribution
    function reject(uint256 _tokenId) external contributionExists(_tokenId) {
        require(_hasToken(msg.sender, _tokenId), "ProofOfContribution: no matching soulbound token found");

        _burn(msg.sender, _tokenId, 1);

        emit Reject(msg.sender, _tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                        Internal Functions – Views
    //////////////////////////////////////////////////////////////*/

    /// @dev Internal function to determine if an EOA holds a given SBT, used by hasToken() and hasTokenBatch()
    function _hasToken(address _owner, uint256 _tokenId) internal view contributionExists(_tokenId) returns (bool) {
        return balanceOf(_owner, _tokenId) >= 1;
    }

    /*//////////////////////////////////////////////////////////////
                        Internal Functions – Transactions
    //////////////////////////////////////////////////////////////*/

    /// @dev Internal function for Issue business logic, used by issue() and issueBatch()
    function _issue(address _recipient, uint256 _tokenId) internal contributionExists(_tokenId) {
        require(
            !_hasToken(_recipient, _tokenId),
            "ProofOfContribution: a person can only receive one soulbound token per contribution"
        );

        _mint(_recipient, _tokenId, 1, "");

        emit Issue(address(this), _recipient, _tokenId);
    }

    /// @dev Internal function for Revoke business logic, used by revoke() and revokeBatch()
    function _revoke(address _owner, uint256 _tokenId, string calldata _reason) internal contributionExists(_tokenId) {
        _burn(_owner, _tokenId, 1);

        emit Revoke(address(this), _owner, _tokenId, _reason);
    }
}
