Feature: Determine the winning essay
    As the 1729 writers guild administrator
    So that I can know which essay won the competition for a given week
    I want to determine the winning essay

    Background: Essay submissions for Week 1
        Given There are 17 essay submissions for Week 1
        And there are the 1729 membership NFT is minted and distributed

    Scenario: Create and share competition
        Given All 17 essays pass the quality requirements of length, originality, and subject matter
        When I create a new Snapshot poll with 17 options
        Then There should be a new Snapshot poll
        And there should be 17 essay options
        And the poll should be token-gated to 1729 members

    Scenario: Handle essay that doesn't pass the quality requirements

    Scenario: Run essay competition
        Given The Snapshot poll for Week 1 is finished
        When The essays received the following (51) votes:
            | essay number | vote count |
            | 1            | 3          |
            | 2            | 0          |
            | 3            | 2          |
            | 4            | 1          |
            | 5            | 0          |
            | 6            | 2          |
            | 7            | 17         |
            | 8            | 0          |
            | 9            | 3          |
            | 10           | 5          |
            | 11           | 8          |
            | 12           | 0          |
            | 13           | 1          |
            | 14           | 3          |
            | 15           | 2          |
            | 16           | 0          |
            | 17           | 4          |
        Then The winning essay should be Essay #7 with 17 votes

# DECISION Use Snapshot
# DECISION Final decisions of voting fraud, etc will be done manually
