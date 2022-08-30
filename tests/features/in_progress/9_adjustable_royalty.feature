Feature: Adjustable Royalty
  As the contract owner
  In order to be able to handle changing requirements and market conditions in the future without deploying a new smart contract
  I want to be able to adjust the royalty information on the deployed contract

  Background:
    Given the NFT contract is deployed

    # NOTE: The following three scenarios are mutually exclusive.  Let's discuss and pick one

  Scenario: Option A -- Adjustable Per TokenId (OpenZepplin implementation
    Given tokenId 1 is minted with 10% royalty
    And tokenId 2 is minted with 10% royalty
    When I change the royalty amount on tokedId 1 to 5%
    Then tokenId 1 should have 5% royalty
    And tokenId 2 should have 10% royalty
    # Pros: more flexible (e.g. different royalties in different cohorts
    # Cons: uses a bit more storage, harder to keep track of

  Scenario: Option B -- Adjustable, but uniform for entire contract
    Given tokenId 1 has 10% royalty
    And tokenId 2 has 10% royalty
    When I change the royalty amount on the contract to 5%
    Then tokenId 1 should have 5% royalty
    And tokenId 2 should have 5% royalty
    # Pros: storage-efficient, easy to manage
    # Cons: all tokenIds must have the same royalty, any changes impact previously-issued tokens

  Scenario: Option C -- Adjustable, but fixed at mint time
    When I set the royalty amount for the contract to 10%
    And I mint tokenId 1
    And I set the royalty amount for the contract to 5%
    And I mint tokenId 2
    Then Then tokenId 1 should have 5% royalty
    And tokenId 2 should have 10% royalty
    And the royalty amounts for existing tokenIds cannot be changed
    # Pros: easy to manage, more credibly neutral
    # Cons: least storage efficient ( uint256*(N+1) ), cannot change royalty amount after minting, even in the case of a mistake

