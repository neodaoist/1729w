Feature: Apply to 1729 writers union
    As a 1729 member
    So that I can contribute to growing the 1729 community and spreading the ideas
    I want to apply to write essays in the 1729 writers union

    Scenario: Apply to 1729 writers union
        Given The 1729 writers union application form is live
        And my name is Susmitha87539319 and my address is 0xCAFE
        When I apply to the 1729 writers union
        Then There should be a new writer application with name Susmitha87539319 and address 0xCAFE
