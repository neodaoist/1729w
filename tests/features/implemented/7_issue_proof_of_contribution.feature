Feature: Issue Proof of Contribution SBT
    As the 1729 Writers admin
    So that the 1729 Writers community can grow and the contributors can be recognized for their work
    I want to issue Proof of Contribution Soulbound Token (SBT)s to contributors

    Background: Member participation as writers and readers/voters
        Given The Proof of Contribution SBT contract is deployed
    # Given There are 150 participating members that hold a 1729 Writers ERC20 participation token
    # And There are 15 total writers in 1729 Writers Cohort 2

    Scenario: Admin can issue single SBT with value
        Given Address 0xCAFE has a balance of 1 ETH
        When I issue a Full Completion SBT to address 0xCAFE with 0.1 ETH
        Then Address 0xCAFE should own 1 Full Completion SBT
        And the SBT should have the following properties:
            | property name | property value |
            | Token ID      | 1              |
        And address 0xCAFE should have 1.1 ETH

    Scenario: Admin can issue multiple SBTs with value
        Given There are 10 writers who submitted a valid essay all weeks, with balances:
            | account address | account balance |
            | 0xCAFE          | 1 ETH           |
            | 0xA             | 0 ETH           |
            | 0xB             | 1.2 ETH         |
        When I batch issue SBTs for Full Completion with 0.3 ETH
        Then The 10 Full Completion writers should own 1 Full Completion SBT
        And the SBT should have the following properties:
            | property name | property value |
            | Token ID      | 1              |
        And the Full Completion writers ether balance should be:
            | account address | account balance |
            | 0xCAFE          | 1.1 ETH         |
            | 0xA             | 0.1 ETH         |
            | 0xB             | 1.3 ETH         |

    Scenario: Admin can issue single SBT without value
        When I issue a Participation SBT to Address1
        Then Address1 should own 1 Participation SBT

    Scenario: Admin can issue multiple SBTs without value
        Given There are 5 writers who submitted a valid essay in at least 1, but not all, weeks
        When I batch issue SBTs for Participation
        Then The 5 Participation writers should own 1 Participation SBT
        And the SBT should have the following properties:
            | property name | property value |
            | Token ID      | 1              |

    Scenario: Admin can issue 100 SBTs
        When I issue Reader/Voter SBTs to 100 Reader/Voter addresses
        Then Address 0xCAFE should own 1 Participation SBT

    Scenario: Admin can not issue more than 100 SBTs
        When I issue Reader/Voter SBTs to 101 Reader/Voter addresses
        Then I should receive an "SBT: can not issue more than 100 SBTs in a single transaction" error

    Scenario: Contributor can not transfer SBT
        Given Address 0xCAFE has 1 Full Completion SBT
        When They attempt to transfer it to address 0xABCD
        Then The SBT should be nontransferable

    Scenario: Contributor can not batch transfer SBT
        Given Address 0xCAFE has 1 Full Completion SBT
        And Address 0xCAFE has 1 Winning Writer SBT
        And Address 0xCAFE has 1 Reader/Voter SBT
        When They attempt to batch transfer all 3 SBTs to address 0xABCD
        Then The SBTs should be nontransferable

    Scenario: Contributor can receive only 1 SBT per contribution
        Given Address 0xCAFE has 1 Full Completion Writer SBT
        When I issue a Full Completion SBT to address 0xCAFE
        Then I should receive an "SBT: a person can only receive one SBT per contribution" error

    Scenario: Contributor can reject SBT
        Given Address 0xCAFE has 1 Full Completion SBT
        When They reject this Proof of Contribution
        Then Address 0xCAFE should have 0 Full Completion SBTs
