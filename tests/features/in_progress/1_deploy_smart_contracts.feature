Feature: Deploy smart contracts and setup web3 components
    As a 1729 developer
    So that the 1729 Writers contracts and web3 components are available and secure
    I want to deploy the smart contracts and setup the web3 components using good security practices

    Scenario: Deploy Gnosis multisig

    Scenario: Setup ENS name

    Scenario: Deploy Juicebox treasury

    Scenario: Setup Snapshot project

    Scenario: Deploy Proof of Contribution SBT contract
        # TODO
        Then It should have vanity address starting with '0x1729[A-Fa-f][0-9A-Fa-f]{15}'
        And the contract should be verified on Etherscan

    Scenario: Deploy Essay NFT contract
        # TODO
        Then should have vanity address starting with '0x1729[A-Fa-f][0-9A-Fa-f]{15}'
        And the contract should be verified on Etherscan
