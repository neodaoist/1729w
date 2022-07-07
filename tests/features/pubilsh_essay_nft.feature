Feature: Create an NFT for the weekly winning essay
  As the admin for the writers guild
  So that I can reward the winning essay author and create a lasting record of the essay
  I want to mint, list, bid on, and distribute funds for an NFT corresponding to the winning essay for the week

  Scenario: Create winning NFT
    Given Essay "Save the world" is the winning essay for the week
    And The winning is published at https://testpublish.com/savetheworld.html
    And The winning essay is authored by George
    And George has address 0xTBD
    When I select "mint NFT"
    Then there should be a contract created of type ...
    And the contract should have URL https://testpublish.com/savetheworld.html
    And the contract should be owned by address 0xTBD


  Scenario: Not enough gas

  Scenario: