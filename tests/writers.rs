use std::convert::Infallible;

use async_trait::async_trait;
use cucumber::{given, when, then, World, WorldInit};



// TODO: Refactor Essay into its own struct
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
    // TODO: Refactor into an Essay struct
    winning_essay_title: String,
    winning_essay_url: String,
    winning_essay_address: String,
}

// `World` needs to be implemented, so Cucumber knows how to construct it
// for each scenario.
#[async_trait(?Send)]
impl World for WriterWorld {
    // We do require some error type.
    type Error = Infallible;

    async fn new() -> Result<Self, Infallible> {
        Ok(Self {
            winning_essay_title: String::from(""),
            winning_essay_url: String::from(""),
            winning_essay_address: String::from(""),
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

/////////////// STEPDEFS ////////////////////

// Given Essay "Save the world" is the winning essay for the week
#[given(regex = r"^Essay (.*) is the winning essay for the week$")]
fn winning_essay_title(world: &mut WriterWorld, essay_title: String) {
    world.winning_essay_title = essay_title;
}

// The winning is published at https://testpublish.com/savetheworld.html
#[given(regex = r"^The winning essay is published at (.*)$")]
fn winning_essay_url(world: &mut WriterWorld, essay_url: String) {
    world.winning_essay_url = essay_url;
}

// The winning essay is authored by Matt, with address 0xTBD
#[given(regex = r"^The winning essay is authored by (.*), with address (.*)$")]
fn winning_essay_address(world: &mut WriterWorld, author_name: String, essay_address: String) {
    world.winning_essay_address = essay_address;
    // TODO: Do something with author name, or drop it
}

#[when("I select 'mint NFT'")]
fn mint_nft(world: &mut WriterWorld) {
    // TODO: Unimplemented
}

// there should be a contract created of type WriterNFT
#[then("there should be a contract created of type WriterNFT")]
fn check_contract_type(world: &mut WriterWorld) {
    // TODO: Stubbed
    panic!("NFT Contract isn't found");
}