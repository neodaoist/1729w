Feature: Address bad behavior
    As the 1729 Writers admin
    So that I can handle potential fraud and other types of bad behavior
    I want the ability to take down Essay NFTs or Proof of Contribution SBTs

    Scenario: Burn Essay NFT
        Given Winning Essay #3 is determined to have been plagiarized
        When I burn Essay NFT #3
        Then There should be no NFT with Token ID of 3 on the Essay NFT contract
    # TODO should we then mint the 2nd-place essay from that week ?

    Scenario: Revoke Proof of Contribution SBT
        Given Writer BadBoy with address 0xBADB01 is determined to have plagiarized Essay #3
        And they own the Winning Essay Writer SBT for Essay #3
        When I revoke the Winning Essay Writer Proof of Contribution SBT for Essay #3
        Then There should be no Winning Essay Writer SBT for Essay #3 on the Proof of Contribution SBT contract
        And they should not own the Winning Essay Writer SBT for Essay #3

# TODO might we also need to revoke full and change to partial? or partial to nothing? or, simply ban them bc they're bad?
# (we can probably kick this can down the road for the Cohort 2 MVP)
# TODO will we add contract methods to search, or would we rely on events ?\
# TODO in this instance, should we do all actions at once? i.e., burn, revoke, re-issue, etc. ?
# TODO decide on right terminology — Redeem/Revoke/Pull back/Destroy/Burn ?
# TODO can we handle this feature (for now) with onlyOwner burn() method on both contracts ?
