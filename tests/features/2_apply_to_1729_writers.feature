Feature: Apply to 1729 Writers
    As a 1729 member
    So that I can contribute to growing the 1729 community and spreading the Network State ideas
    I want to apply to write essays in 1729 Writers

    Scenario: Apply to 1729 writers union
        Given The 1729 Writers application form is live
        And my name is Susmitha87539319 and my address is 0xCAFE
        When I apply to 1729 Writers
        Then There should be a new writer application with name Susmitha87539319 and address 0xCAFE
