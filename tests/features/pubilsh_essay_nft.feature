Feature: Publish Essay NFT for the weekly winning essay
    As the 1729 writers guild admin
    So that I can reward the winning writer and create a lasting on-chain body of work for 1729
    I want to mint, list, bid on, and distribute funds for an NFT of the winning essay for the week

    Background: The winning essay has been determined for the week
        Given The Essay NFT contract is deployed
        And there are no NFTs minted on the contract
        And Cohort is 1
        And it received 1337 Community-Sourced Attestations
        And "Save the world" is the winning essay for Week 1

    # TODO convert to data table
    # TODO do mint, list, and bid on together
    Scenario: Mint winning NFT
        Given The winning is published at "https://testpublish.com/savetheworld.html"
        And the winning essay is written by "George"
        And George has address "0xBABE"
        When I select "mint Essay NFT"
        Then There should be an Essay NFT minted on the Essay NFT contract with token ID
        And the Essay NFT should have token ID of 1
        And the Essay NFT should have Cohort of 1
        And the Essay NFT should have Week of 1
        And the Essay NFT should have Communited-Sourced Attestation Count of 1337
        And the Essay NFT should have Publication URL property of "https://testpublish.com/savetheworld.html"
        And the Essay NFT should have Writer Name property of "George"
        And the Essay NFT should have Writer Address property of "0xBABE"

    Scenario: List Essay NFT

    Scenario: Bid on Essay NFT

    # TODO combine in Distribute funds

    Scenario: Finalize auction, as winner

    Scenario: Finalize auction, as loser

    Scenario: Distribute funds to winning writer
