Feature: Deploy smart contracts
    As a 1729 developer
    So that the 1729 writers guild contracts are secure
    I want to deploy the smart contracts with proper access and upgradability patterns

    Scenario: Deploy Proof of Contribution SBT contract
    # Then should have vanity address starting with '0x172w[0-9]'
    # TODO ERC1155 ?

    Scenario: Deploy Essay NFT contract
    # Then should have vanity address starting with '0x172w[0-9]'
    # TODO ERC721 ?

    Scenario: Verify contracts on Etherscan

# TODO should we support upgradeability?
# TODO what functions should be protected by onlyOwner modifier?
# TODO do we need more roles other than owner?
