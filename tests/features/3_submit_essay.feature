Feature: Submit an essay
    As a 1729 writer
    So that I contribute to the 1729 community and receive credit for contributing
    I want to submit my essay for the weekly essay competition

    Scenario: Submit essay
        Given I wrote an essay titled 'Save the World' for Cohort 2 Week 1
        And I self-attest to essay originality
        And I self-attest that this will be the first time it's been published
        And I self-attest it meets the minimum length requirement
        And I self-attest it meets the minimum viable publication requirement on a publicly-accessible URL
        And I self-attest I've done the minimum viable promotion on social media
        And TODO I confirm that I retain all copyright while also authorizing 1729 Writers to publish
        When I submit my essay
        Then I should see an essay titled 'Save the World' in the TODO for Cohort 2 Week 1
