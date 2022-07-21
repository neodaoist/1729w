use std::convert::Infallible;

use async_trait::async_trait;
use cucumber::{given, when, then, World, WorldInit};

// 

// TODO: Refactor into structs as needed
/*
#[derive(Debug)]
pub struct Essay {
    title: String,
    url: String,
    author_addr: String
}
 */

// `World` is your shared, likely mutable state.
#[derive(Debug, WorldInit)]
pub struct WriterWorld {

    // TODO: Refactor into structs as needed

    writer_name: String,
    writer_address: String,

    cohort_number: String,
    week_number: String,

    essay_title: String,
    essay_number: String,

    essay_submission_count: String,

    voter_account: String,
    snapshot_block_number: String,

    winning_essay_title: String,
    winning_essay_content: String,
    winning_essay_publication_url: String,
    winning_essay_votes: String,

    winning_writer_name: String,
    winning_writer_address: String,
}

// `World` needs to be implemented, so Cucumber knows how to construct it
// for each scenario.
#[async_trait(?Send)]
impl World for WriterWorld {
    // We do require some error type.
    type Error = Infallible;

    async fn new() -> Result<Self, Infallible> {
        Ok(Self {
            writer_name: String::from(""),
            writer_address: String::from(""),

            cohort_number: String::from(""),
            week_number: String::from(""),

            essay_title: String::from(""),
            essay_number: String::from(""),

            essay_submission_count: String::from(""),

            voter_account: String::from(""),
            snapshot_block_number: String::from(""),

            winning_essay_title: String::from(""),
            winning_essay_content: String::from(""),
            winning_essay_publication_url: String::from(""),
            winning_essay_votes: String::from(""),

            winning_writer_name: String::from(""),
            winning_writer_address: String::from(""),
        })
    }
}

// Test runner
fn main() {
    // You may choose any executor you like (`tokio`, `async-std`, etc.).
    // You may even have an `async` main, it doesn't matter. The point is that
    // Cucumber is composable. :)
    futures::executor::block_on(WriterWorld::run("tests/features"));
}

////////////////////////////////////////////////////////////////
//                  Step Defs TEMPLATES
////////////////////////////////////////////////////////////////

// #[given("XYZ")]
// fn XYZ(world: &mut WriterWorld) {
//     // TODO: not implemented yet
// }

// #[given(regex = r"^XYZ$")]
// fn XYZ(world: &mut WriterWorld, ABC: String) {
//     // TODO: not implemented yet
//     world.XYZ = ABC;
// }

// #[when("XYZ")]
// fn XYZ(world: &mut WriterWorld) {
//     // TODO: not implemented yet
// }

// #[when(regex = r"^XYZ$")]
// fn XYZ(world: &mut WriterWorld, ABC: String) {
//     // TODO: not implemented yet
// }

// #[then("XYZ")]
// fn XYZ(world: & mut WriterWorld) {
//     // TODO: not implemented yet
//     panic!("STEPDEF not implemented yet");
// }

// #[then(regex = r"^XYZ$")]
// fn XYZ(world: &mut WriterWorld, ABC: String) {
//     // TODO: not implemented yet
//     panic!("STEPDEF not implemented yet");
// }

////////////////////////////////////////////////////////////////
//                  Step Defs – Deploy Smart Contracts
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//                  Step Defs – Apply to 1729 Writers
////////////////////////////////////////////////////////////////

#[given("The 1729 Writers application form is live")]
fn apply_given_1(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given(regex = r"^my name is ([^\s]+) and my address is (0x[0-9A-Fa-f]+)$")]
fn apply_given_2(world: &mut WriterWorld, writer_name: String, writer_address: String) {
    world.writer_name = writer_name;
    world.writer_address = writer_address;
}

#[when("I apply to 1729 Writers")]
fn apply_when_1(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[then(regex = r"^There should be a new writer application with name ([^\s]+) and address (0x[0-9A-Fa-f]+)$")]
fn apply_then_1(world: &mut WriterWorld, writer_name: String, writer_address: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}

////////////////////////////////////////////////////////////////
//                  Step Defs – Submit Essay
////////////////////////////////////////////////////////////////

#[given(regex = r"^I wrote an essay titled '([^']+)' for Cohort (\d+) Week (\d+)$")]
fn submit_given_1(world: &mut WriterWorld, essay_title: String, cohort_number: String, week_number: String) {
    world.essay_title = essay_title;
    world.cohort_number = cohort_number;
    world.week_number = week_number;
}

#[given("I self-attest to essay originality")]
fn submit_given_2(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given("I self-attest that this will be the first time it's been published")]
fn submit_given_3(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given("I self-attest it meets the minimum length requirement")]
fn submit_given_4(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given("I self-attest it meets the minimum viable publication requirement on a publicly-accessible URL")]
fn submit_given_5(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given("I self-attest I've done the minimum viable promotion on social media")]
fn submit_given_6(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given("TODO I confirm that I retain all copyright while also authorizing 1729 Writers to publish")]
fn submit_given_7(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[when("I submit my essay")]
fn submit_when_1(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[then(regex = r"^I should see an essay titled '([^']+)' in the TODO for Cohort (\d+) Week (\d+)$")]
fn submit_then_1(world: &mut WriterWorld, ABC: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}

////////////////////////////////////////////////////////////////
//                  Step Defs – Vote for Essay
////////////////////////////////////////////////////////////////

#[given(regex = r"^There are (\d+) essay submissions for Cohort (\d+) Week (\d+)$")]
fn vote_given_1(world: &mut WriterWorld, essay_submission_count: String, cohort_number: String, week_number: String) {
    world.essay_submission_count = essay_submission_count;
    world.cohort_number = cohort_number;
    world.week_number = week_number;
}

#[when("I navigate to the 1729 Writers recent essays feed")]
fn vote_when_1(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[then(regex = r"^I should see (\d+) essay submissions for Cohort (\d+) Week (\d+)$")]
fn vote_then_1(world: &mut WriterWorld, essay_submission_count: String, cohort_number: String, week_number: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}

#[given("I navigate to the 1729 Writers Snapshot page")]
fn vote_scenario_2_given_1(world: &mut WriterWorld) {
    // TODO: not implemented yet
}

#[given(regex = r"^there is an active essay competition for Cohort (\d+) Week (\d+)$")]
fn vote_scenario_2_given_2(world: &mut WriterWorld, cohort_number: String, week_number: String) {
    // TODO: not implemented yet
    world.cohort_number = cohort_number;
    world.week_number = week_number;
}

#[given(regex = r"^I login with Ethereum using the (0x[0-9A-Fa-f]+) account$")]
fn vote_scenario_2_given_3(world: &mut WriterWorld, voter_account: String) {
    // TODO: not implemented yet
    world.voter_account = voter_account;
}

#[given(regex = r"^I hold a 1729 Writers Participation SBT as of block (\d+)$")]
fn vote_scenario_2_given_4(world: &mut WriterWorld, snapshot_block_number: String) {
    // TODO: not implemented yet
    world.snapshot_block_number = snapshot_block_number;
}

#[when(regex = r"^I vote for the essay titled '([^']+)'$")]
fn vote_scenario_2_when_1(world: &mut WriterWorld, essay_title: String) {
    // TODO: not implemented yet
    world.essay_title = essay_title;
}

#[then(regex = r"^I should see the (0x[0-9A-Fa-f]+) account voted (\d) for the essay titled '([^']+)'$")]
fn vote_scenario_2_then_1(world: &mut WriterWorld, ABC: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}

////////////////////////////////////////////////////////////////
//                  Step Defs – Determine Winning Essay
////////////////////////////////////////////////////////////////

// TODO, uses data tables

////////////////////////////////////////////////////////////////
//                  Step Defs – Publish Winning Essay
////////////////////////////////////////////////////////////////

// TODO, uses data tables

#[given(regex = r"^The Essay NFT contract is deployed$")]
fn essay_contract_is_deployed(world: &mut WriterWorld) {
    // TODO: deploy contract
}

#[given(regex = r"^there are no NFTs minted on the contract$")]
fn essay_contract_has_no_nfts_minted(world: &mut WriterWorld) {
    // TODO: just for clarity
}

#[given(regex = r"^the Cohort is ([\d]*)$")]
fn cohort_number_is_x(world: &mut WriterWorld, cohort_number: String) {
    world.cohort_number = cohort_number;
}

#[given(regex = r"^the Week is ([\d]*)$")]
fn week_number_is_x(world: &mut WriterWorld, week_number: String) {
    world.week_number = week_number;
}

#[given(regex = r"^the winning essay is '([^']*)'$")]
fn winning_essay_title(world: &mut WriterWorld, essay_title: String) {
    world.winning_essay_title = essay_title;
}

#[given(regex = r"^the essay content is '([^']*)'$")]
fn winning_essay_content(world: &mut WriterWorld, essay_content: String) {
    world.winning_essay_content = essay_content;
}

#[given(regex = r"^the writer's name is '([^']*)' and address is '(0x[0-9A-Fa-f]*)'$")]
fn winning_writer(world: &mut WriterWorld, writer_name: String, writer_address: String) {
    world.winning_writer_name = writer_name;
    world.winning_writer_address = writer_address;
}

#[given(regex = r"^the publication URL is '(https://[^']*)'$")]
fn winning_essay_publication_url(world: &mut WriterWorld, essay_publication_url: String) {
    world.winning_essay_publication_url = essay_publication_url;
}

#[given(regex = r"^the winning essay received ([\d]*) votes$")]
fn winning_essay_votes(world: &mut WriterWorld, essay_votes: String) {
    world.winning_essay_votes = essay_votes;
}

#[when("I mint, list, and bid on the Essay NFT")]
fn mint_list_bid_on_nft(world: &mut WriterWorld) {
    // TODO: Unimplemented
}

#[then("There should be PLACEHOLDER STEP XYZ")]
fn check_contract_type(world: & mut WriterWorld) {
    // assert!(false, "Essay NFT bid is not found");
    panic!("STEPDEF not implemented yet");
}

////////////////////////////////////////////////////////////////
//                  Step Defs – Issue Proof of Contribution
////////////////////////////////////////////////////////////////

// TODO, uses data tables

////////////////////////////////////////////////////////////////
//                  Step Defs – Address Bad Behavior
////////////////////////////////////////////////////////////////

#[given(regex = r"^Winning Essay #(\d+) is determined to have been plagiarized$")]
fn address_given_1(world: &mut WriterWorld, essay_number: String) {
    world.essay_number = essay_number;
}

#[when(regex = r"^I burn Essay NFT #(\d+)$")]
fn address_when_1(world: &mut WriterWorld, essay_number: String) {
    // TODO: not implemented yet
}

#[then(regex = r"^There should be no NFT with Token ID of (\d+) on the Essay NFT contract$")]
fn address_then_1(world: &mut WriterWorld, essay_number: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}

#[given(regex = r"^Writer ([^\s]+) with address (0x[0-9A-Fa-f]+) is determined to have plagiarized Essay #(\d+)$")]
fn address_scenario_2_given_1(world: &mut WriterWorld, writer_name: String, writer_address: String, essay_number: String) {
    world.writer_name = writer_name;
    world.writer_address = writer_address;
    world.essay_number = essay_number;
}

#[given(regex = r"^they own the Winning Essay Writer SBT for Essay #(\d+)$")]
fn address_scenario_2_given_2(world: &mut WriterWorld, essay_number: String) {
    // TODO: not implemented yet
    world.essay_number = essay_number;
}

#[when(regex = r"^I revoke the Winning Essay Writer Proof of Contribution SBT for Essay #(\d+)$")]
fn address_scenario_2_when_1(world: &mut WriterWorld, essay_number: String) {
    // TODO: not implemented yet
}

#[then(regex = r"^There should be no Winning Essay Writer SBT for Essay #(\d+) on the Proof of Contribution SBT contract$")]
fn address_scenario_2_then_1(world: &mut WriterWorld, essay_number: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}

#[then(regex = r"^they should not own the Winning Essay Writer SBT for Essay #(\d+)$")]
fn address_scenario_2_then_2(world: &mut WriterWorld, essay_number: String) {
    // TODO: not implemented yet
    panic!("STEPDEF not implemented yet");
}
