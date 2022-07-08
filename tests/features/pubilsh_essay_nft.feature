Feature: Publish Essay NFT for the weekly winning essay
    As the 1729 writers guild admin
    So that I can reward the winning writer and create a lasting on-chain body of work for 1729
    I want to mint, list, bid on, and distribute funds for an NFT of the winning essay for the week

    Scenario: Publish winning Essay NFT
        Given The Essay NFT contract is deployed
        And there are no NFTs minted on the contract
        And the Cohort is 1
        And the Week is 1
        And "Save the World" is the winning essay
        And the essay content is "XYZ"
        And the writer's name is Susmitha and address is 0xCAFE
        And the publication URL is "https://testpublish.com/savetheworld"
        And it received 1337 Community-Sourced Attestations
        When I mint, list, and bid on the Essay NFT
        Then There should be an Essay NFT minted with the following properties:
            | property name                       | property value                       |
            | Token ID                            | 1                                    |
            | Cohort                              | 1                                    |
            | Week                                | 1                                    |
            | Name                                | Save the World                       |
            | Image                               | XYZ                                  |
            | Description                         | XYZ                                  |
            | Content Hash                        | XYZ                                  |
            | Writer Name                         | Susmitha                             |
            | Writer Address                      | 0xCAFE                               |
            | Publication URL                     | https://testpublish.com/savetheworld |
            | Archival URL                        | ipfs://[^\s]*                        |
            | Community-Sourced Attestation Count | 1337                                 |
        And there should be an auction listing on Zora with a minimum bid amount of 0.1 ETH
        And there should be a bid placed for 0.1 ETH by the 1729w multisig account

    Scenario: Finalize auction as winner
    # TODO include Funds are distributed as a Then in both finalize scenarios

    Scenario: Finalize auction as loser
