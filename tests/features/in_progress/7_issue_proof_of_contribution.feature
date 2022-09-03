Feature: Issue Proof of Contribution SBT
    As the 1729 Writers admin
    So that the 1729 Writers community can grow and the contributors can be recognized for their work
    I want to issue Proof of Contribution Soulbound Token (SBT)s to contributors

    Background: Member participation as writers and readers/voters
        Given There are 150 participating members that hold a 1729 Writers ERC20 participation token
        And There are 15 total writers in 1729 Writers Cohort 2

    Scenario: Issue 1729 Writers Proof of Contribution SBTs to writers for full participation
        Given There are 10 writers who submitted a valid essay all 4 weeks
        When I issue SBTs for full writer participation
        Then The fully participating writers should own an SBT
        And the SBT should have the following properties:
            | property name | property value |
            | Token ID      | 1              |
    # TODO figure out how to best assert off-chain JSON metadata properties
    # | Name          | Cohort 2 - Writer Full Participation |
    # | Image         | XYZ                                  |
    # | Description   | ABC                                  |
    # | Cohort        | 2                                    |
    # | Contribution  | Writer Full Participation            |

    Scenario: Contributor can not transfer SBT
        Given Address 0xCAFE has 1 Fully Participating Writer SBT
        When They attempt to transfer it to address 0xABCD
        Then The SBT should be nontransferable

    # QUESTION should we include batch functionality in our behavior tests?
    Scenario: Contributor can not batch transfer SBT
        Given Address 0xCAFE has 1 Fully Participating Writer SBT
        And Address 0xCAFE has 1 Winning Writer SBT
        And Address 0xCAFE has 1 Reader/Voter SBT
        When They attempt to batch transfer all 3 SBTs to address 0xABCD
        Then The SBTs should be nontransferable

    Scenario: Contributor can receive only 1 SBT per contribution
        Given Address 0xCAFE has 1 Fully Participating Writer SBT
        When I issue a Fully Participating Writer SBT to address 0xCAFE
        Then I should receive an "SBT: a person can only receive one SBT per contribution" error

    Scenario: Contributor can reject SBT
        Given Address 0xCAFE has 1 Fully Participating Writer SBT
        When They reject this Proof of Contribution
        Then Address 0xCAFE should have 0 Fully Participating Writer SBTs
