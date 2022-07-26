Feature: 1729 member votes on the best essay of the week
    As a 1729 member
    So that I contribute to the selection of the best essay
    I want to vote for my favorite essay

    Background: Essay submissions for Cohort 2 Week 3
        Given There are 15 essay submissions for Cohort 2 Week 3

    Scenario: Read essay submissions
        When I navigate to the 1729 Writers recent essays feed
        Then I should see 15 essay submissions for Cohort 2 Week 3

    Scenario: Vote for best essay
        Given I navigate to the 1729 Writers Snapshot page
        And there is an active essay competition for Cohort 2 Week 3
        And I login with Ethereum using the 0xBABE account
        And I hold a 1729 Writers Participation SBT as of block 1337000
        When I vote for the essay titled 'Save the World'
        Then I should see the 0xBABE account voted 1 for the essay titled 'Save the World'
