Feature: Address bad behavior
    As the 1729 writers union admin
    So that I can handle potential fraud and other types of bad behavior
    I want the ability to take down Essay NFTs or Proof of Contribution SBTs

    Scenario: Burn Essay NFT
        Given Winning Essay #42 is determined to be plagiarized
        When I burn Essay NFT #42
        Then There should be no NFT with Token ID of 42 on the Essay NFT contract
    # TODO should we mint the 2nd-place essay from that week ?

    Scenario: Revoke Proof of Contribution SBT
        Given Writer BadBoyBluff is determined to have plagiarized Essay #42
        When I burn the Proof of Contribution SBT for winning Essay #42
        Then There should be no NFT with XYZ on the Proof of Contribution NFT contract
# TODO will we add contract methods to search, or would we rely on events ?

# TODO in this instance, should we do all actions at once? i.e., burn, revoke, re-issue, etc. ?
# TODO decide on right terminology — Redeem/Revoke/Pull back/Destroy/Burn ?
# TODO can we handle this feature (for now) with onlyOwner burn() method on both contracts ?
