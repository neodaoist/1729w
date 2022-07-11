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

    competition_cohort_number: String,
    competition_week_number: String,

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
            competition_cohort_number: String::from(""),
            competition_week_number: String::from(""),

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
//                  Step Defs – Publish Essay
////////////////////////////////////////////////////////////////

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
    world.competition_cohort_number = cohort_number;
}

#[given(regex = r"^the Week is ([\d]*)$")]
fn week_number_is_x(world: &mut WriterWorld, week_number: String) {
    world.competition_week_number = week_number;
}

#[given(regex = r"^the winning essay is '([^']*)'$")]
fn winning_essay_title(world: &mut WriterWorld, essay_title: String) {
    world.winning_essay_title = essay_title;
}

#[given(regex = r"^the essay content is '([^']*)'$")]
fn winning_essay_content(world: &mut WriterWorld, essay_content: String) {
    world.winning_essay_content = essay_content;
}

#[given(regex = r"^the writer's name is '([^']*)' and address is '(0x[0-9A-F]*)'$")]
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
