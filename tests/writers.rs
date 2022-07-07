use std::convert::Infallible;

use async_trait::async_trait;
use cucumber::{given, World, WorldInit};


// `World` is your shared, likely mutable state.
#[derive(Debug, WorldInit)]
pub struct WriterWorld {

}

// `World` needs to be implemented, so Cucumber knows how to construct it
// for each scenario.
#[async_trait(?Send)]
impl World for WriterWorld {
    // We do require some error type.
    type Error = Infallible;

    async fn new() -> Result<Self, Infallible> {
        Ok(Self {
            // init stuff here
            // cat: Cat { hungry: false },
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