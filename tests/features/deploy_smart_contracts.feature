Feature: Deploy smart contracts
    As a 1729 developer
    So that the 1729 writers guild contracts are available and secure
    I want to deploy the smart contracts with proper access and upgradability patterns

    Scenario: Deploy Gnosis multisig

    Scenario: Setup ENS name

    Scenario: Deploy Juicebox treasury

    Scenario: Deploy Proof of Contribution SBT contract
        #
        Then should have vanity address starting with '0x172w[0-9]'
        And the contract should be verified on Etherscan
    # TODO ERC1155 ?
    # TODO should we support upgradeability?
    # TODO what functions should be protected by onlyOwner modifier?
    # TODO do we need more roles other than owner?

    Scenario: Deploy Essay NFT contract
        #
        Then should have vanity address starting with '0x172w[0-9]'
        And the contract should be verified on Etherscan
# TODO ERC721 ?
