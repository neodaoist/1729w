Feature: Publish Essay NFT for the weekly winning essay
    As the 1729 Writers admin
    So that I can reward the winning writer and create a lasting on-chain body of work for 1729
    I want to mint, list, bid on, and distribute funds for an NFT of the winning essay for the week

    Background: Winning essay for the week
        Given The Essay NFT contract is deployed
        And there are no NFTs minted on the contract
        And the Cohort is 2
        And the Week is 1
    #        And the winning essay is 'Save the World'
    #        And the essay content is 'XYZ ABC 345'
    #        And the writer's name is 'Susmitha87539319' and address is '0xCAFE'
    #        And the publication URL is 'https://testpublish.com/savetheworld'
    #        And the winning essay received 1337 votes

    @blockchain
    Scenario: Publish winning Essay NFT
        When I mint, list, and bid on the Essay NFT
        Then There should be an Essay NFT with token ID 1 and URL 'https://test.com/test'
        And there should be an auction listing on Zora for token ID 1 with a minimum bid amount of 10 Finney
        And there should be a bid placed for token ID 1 of 100 Finney by the 1729w multisig account
# TODO decide if we should add Zora auction field checks, including duration ?

# NOTE settling will be done manual for the time being
#    Scenario: Settle auction as winning bidder
#        Given The auction is complete
#        And the 1729 writers union's bid of 0.1 ETH won
#        And address 0xCAFE has 0.3 ETH
#        When I settle the auction and distribute the funds
#        Then The Essay NFT should be owned by the 1729 writers union multisig
#        And address 0xCAFE should have 0.4 ETH

#    Scenario: Settle auction as losing bidder
#        Given The auction is complete
#        And address 0xBEEF bid of 0.42 ETH won
#        And address 0xCAFE has 0.3 ETH
#        When I settle the auction and distribute the funds
#        Then The Essay NFT should be owned address 0xBEEF
#        And address 0xCAFE should have 0.72 ETH

# TODO add Scenario for secondary sales royalty, 10% (use a 0% network state tax rate)
