Feature: Issue Proof of Contribution SBT
    As the 1729 Writers admin
    So that the 1729 Writers community can grow and the contributors can be recognized for their work
    I want to issue Proof of Contribution Soulbound Token (SBT)s to contributors

    Background: Member participation as writers and readers/voters
        Given There are 150 participating members that hold a 1729 Writers ERC20 participation token
        And There are 15 total writers in 1729 Writers Cohort 2

    # TODO figure out how to best assert off-chain JSON metadata properties
    Scenario: Issue 1729 Writers Proof of Contribution SBTs to writers for full participation
        Given There are 10 writers who submitted a valid essay all 4 weeks
        When I issue SBTs for full writer participation
        Then The fully participating writers should own an SBT
        And the SBT should have the following properties:
            | property name | property value |
            | Token ID      | 1              |
        #            | Name              | 1729 Writers - Writer Full Participation |
        #            | Image             | XYZ                                      |
        #            | Description       | ABC                                      |
        #            | Cohort            | 2                                        |
        #            | Contribution Date | 2022 August                              |
        And the SBT should not be transferrable

    Scenario: Person can only receive 1 SBT per contribution
        Given Address 0xCAFE has 1 Fully Participating Writer SBT
        When I issue a Fully Participating Writer SBT to address 0xCAFE
        Then I should receive an "SBT: a person can only receive one SBT per contribution" error

# Scenario: Issue 1729 Writers Proof of Contribution SBTs to writers for partial participation
#     Given There are 5 writers who submitted a valid essay in at least 1 week
#     But they did not submit a valid essay all 4 weeks
#     When I issue SBTs for partial writer participation
#     Then The partially participating writers should own an SBT
#     And the SBT should have the following properties:
#         | property name     | property value                              |
#         | Token ID          | 2                                           |
#         | Name              | 1729 Writers - Writer Partial Participation |
#         | Image             | XYZ                                         |
#         | Description       | ABC                                         |
#         | Cohort            | 2                                           |
#         | Contribution Date | 2022 August                                 |
#     And the SBT should not be transferrable

# Scenario: Issue 1729 Writers Proof of Contribution SBTs to the winning writers
#     Given There are 4 writers who submitted a winning essay
#     When I issue SBTs for the winning essays
#     Then The winning writers should own an SBT
#     And the SBT should have the following properties:
#         | property name     | property value                      |
#         | Token ID          | 3                                   |
#         | Name              | 1729 Writers - Winning Essay Writer |
#         | Image             | XYZ                                 |
#         | Description       | ABC                                 |
#         | Cohort            | 2                                   |
#         | Contribution Date | 2022 August                         |
#     And the SBT should not be transferrable

# Scenario: Issue 1729 Writers Proof of Contribution SBTs to members for voting
#     Given There are 135 members who voted for a winning essay at least 1 week
#     When I issue SBTs for reader/voter participation
#     Then The participating readers/voters should own an SBT
#     And the SBT should have the following properties:
#         | property name     | property value                            |
#         | Token ID          | 4                                         |
#         | Name              | 1729 Writers - Reader/Voter Participation |
#         | Image             | XYZ                                       |
#         | Description       | ABC                                       |
#         | Cohort            | 2                                         |
#         | Contribution Date | 2022 August                               |
#     And the SBT should not be transferrable

# Scenario: Issue 1729 Writers Proof of Contribution SBTs to members for bidding
#     Given There are 15 members who bidding on an Essay NFT in at least 1 auction
#     When I issue SBTs for bidder participation
#     Then The participating bidders should own an SBT
#     And the SBT should have the following properties:
#         | property name     | property value                      |
#         | Token ID          | 5                                   |
#         | Name              | 1729 Writers - bidder Participation |
#         | Image             | XYZ                                 |
#         | Description       | ABC                                 |
#         | Cohort            | 2                                   |
#         | Contribution Date | 2022 August                         |
#     And the SBT should not be transferrable
