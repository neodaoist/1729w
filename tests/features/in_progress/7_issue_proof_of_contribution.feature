Feature: Issue Proof of Contribution SBT
    As the 1729 Writers administrator
    So that the 1729 Writers community can grow and the contributors can be recognized for their work
    I want to issue Proof of Contribution Soulbound Token (SBT)s to contributors

    # QUESTION so do we have 6 user populations and 5 levels of contribution?
    # participating members
    # total writers (not an explicit level of contribution)
    # fully participating writers
    # partially participating writers
    # participating readers/voters
    # winning writers

    Background: Member participation as writers and readers/voters
        Given There are 150 participating members in 1729 Writers
        And There are 15 total writers in 1729 Writers Cohort 2

    # Data table test from https://cucumber-rs.github.io/cucumber/current/writing/data_tables.html
    Scenario: Data table test — If we feed a hungry animal it will no longer be hungry
        Given a hungry animal
            | animal |
            | cat    |
            | dog    |
            | 🦀     |
        When I feed the animal multiple times
            | animal | times |
            | cat    | 2     |
            | dog    | 3     |
            | 🦀     | 4     |
        Then the animal is not hungry

    Scenario: Issue initial 1729 Writers Proof of Contribution SBTs to participating members
        When I issue SBTs to the 150 participating members for reader/voter participation
        Then All 150 applicants should own an SBT
        And the SBT should have the following properties:
            | property name     | property value             |
            | Token ID          | 0                          |
            | Name              | 1729 Writers Participation |
            | Image             | XYZ                        |
            | Description       | ABC                        |
            | Cohort            | 2                          |
            | Contribution Date | 2022 August                |
        And the SBT should not be transferrable

    # NOTE we're going to have to figure out how to best assert metadata properties (and if they're on-chain, off-chain, or hybrid)
    # NOTE we could define 0x001 through 0x150 as the 150 participating members' addresses, and 0xA1, 0xA2, ... 0xA15 as the 15 writers
    # ^ this is bad hex lol but just an idea, there might be a more elegant way to do it

    Scenario: Issue 1729 Writers Proof of Contribution SBTs to writers for full participation
        Given There are 10 writers who submitted a valid essay all 4 weeks
        And their account balances are:
            | account name | account balance |
            | 0xB1         | 0.1 ether       |
            | 0xB2         | 0.2 ether       |
            | 0xB3         | 0.3 ether       |
            | 0xB4         | 0.4 ether       |
            | 0xB5         | 0.5 ether       |
            | 0xB6         | 0.6 ether       |
            | 0xB7         | 0.7 ether       |
            | 0xB8         | 0.8 ether       |
            | 0xB9         | 0.9 ether       |
            | 0xB0         | 1.0 ether       |
        When I issue SBTs for full writer participation
        Then The fully participating writers should own an SBT
        And the SBT should have the following properties:
            | property name     | property value                           |
            | Token ID          | 1                                        |
            | Name              | 1729 Writers – Writer Full Participation |
            | Image             | XYZ                                      |
            | Description       | ABC                                      |
            | Cohort            | 2                                        |
            | Contribution Date | 2022 August                              |
        And the SBT should not be transferrable
        And their account balances should be:
            | account name | account balance |
            | 0xB1         | 0.16 ether      |
            | 0xB2         | 0.26 ether      |
            | 0xB3         | 0.36 ether      |
            | 0xB4         | 0.46 ether      |
            | 0xB5         | 0.56 ether      |
            | 0xB6         | 0.66 ether      |
            | 0xB7         | 0.76 ether      |
            | 0xB8         | 0.86 ether      |
            | 0xB9         | 0.96 ether      |
            | 0xB0         | 1.06 ether      |
    # QUESTION split 0.6 ETH between 10 fully participating writers, after 0.4 ETH goes to 4 winning writers?
    # or how do we do the math if the multisig doesn't win every auction (i.e., more ETH in treasury than 0.6 ETH)

    Scenario: Issue 1729 Writers Proof of Contribution SBTs to writers for partial participation
        Given There are 5 writers who submitted a valid essay in at least 1 week
        But they did not submit a valid essay all 4 weeks
        When I issue SBTs for partial writer participation
        Then The partially participating writers should own an SBT
        And the SBT should have the following properties:
            | property name     | property value                              |
            | Token ID          | 1                                           |
            | Name              | 1729 Writers – Writer Partial Participation |
            | Image             | XYZ                                         |
            | Description       | ABC                                         |
            | Cohort            | 2                                           |
            | Contribution Date | 2022 August                                 |
        And the SBT should not be transferrable

    Scenario: Issue 1729 Writers Proof of Contribution SBTs to members for voting
        Given There are 135 members who voted for a winning essay at least 1 week
        When I issue SBTs for reader/voter participation
        Then The participating readers/voters should own an SBT
        And the SBT should have the following properties:
            | property name     | property value                            |
            | Token ID          | 1                                         |
            | Name              | 1729 Writers – Reader/Voter Participation |
            | Image             | XYZ                                       |
            | Description       | ABC                                       |
            | Cohort            | 2                                         |
            | Contribution Date | 2022 August                               |
        And the SBT should not be transferrable

    Scenario: Issue 1729 Writers Proof of Contribution SBTs to the winning writers
        Given There are 4 writers who submitted a winning essay
        And their account balances are:
            | account name | account balance |
            | 0xA1         | 0.1 ether       |
            | 0xA2         | 0 ether         |
            | 0xA3         | 1.0 ether       |
            | 0xA4         | 0.8 ether       |
        When I issue SBTs for the winning essays
        Then The winning writers should own an SBT
        And the SBT should have the following properties:
            | property name     | property value                      |
            | Token ID          | 1                                   |
            | Name              | 1729 Writers – Winning Essay Writer |
            | Image             | XYZ                                 |
            | Description       | ABC                                 |
            | Cohort            | 2                                   |
            | Contribution Date | 2022 August                         |
        And the SBT should not be transferrable
        And their account balances should be:
            | account name | account balance |
            | 0xA1         | 0.2 ether       |
            | 0xA2         | 0.1 ether       |
            | 0xA3         | 1.1 ether       |
            | 0xA4         | 0.9 ether       |

# TODO update this feature and feature 4 to clarify we'll use Juicebox ERC20 as voting token for MVP
