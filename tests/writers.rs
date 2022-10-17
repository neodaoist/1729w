use std::borrow::Borrow;
use std::convert::Infallible;
use async_trait::async_trait;
use cucumber::{gherkin::Step, given, when, then, World, Cucumber, WorldInit, writer};
use std::collections::HashMap;
use std::fmt::Formatter;
use std::panic::AssertUnwindSafe;
use std::sync::Arc;
use std::time::Duration;
use std::{env, fs};
use async_std::task;
use ethers::prelude::{Address, H160, LocalWallet};
use futures::FutureExt;
use log::{info, warn};
use tokio::time;
use ethers::utils::{Anvil, AnvilInstance};
use ethers_contract::{abigen, Contract};
use ethers_middleware::signer::SignerMiddleware;
use ethers_providers::{Provider, Http, Middleware};
use ethers::signers::Signer;
use ethers::prelude::Wallet;
use ethers::abi::Uint;


abigen!(SevenTeenTwentyNineEssay, "out/1729Essay.sol/SevenTeenTwentyNineEssay.json");
abigen!(ListBidEssayScript, "out/ListEssay.s.sol/ListEssayScript.json");
abigen!(ReserveAuctionCoreETH, "out/ListEssay.s.sol/ReserveAuctionCoreETH.json");
abigen!(ModuleManager, "out/ListEssay.s.sol/ModuleManager.json");

// `World` is your shared, likely mutable state.
//#[derive(Debug, WorldInit)]
#[derive(WorldInit)]
pub struct WriterWorld {

    // only here for data table test
    animals: HashMap<String, Animal>,

    // TODO: Refactor into structs as needed

    writer_name: String,
    writer_address: String,

    cohort_number: String,
    week_number: String,

    essay_title: String,
    essay_number: String,

    essay_submission_count: String,

    participating_member_count: String,
    total_writer_count: String,

    voter_account: String,
    snapshot_block_number: String,

    winning_essay_title: String,
    winning_essay_content: String,
    winning_essay_publication_url: String,
    winning_essay_votes: String,

    winning_writer_name: String,
    winning_writer_address: String,

    anvil: Option<AnvilConnection>,
    nft_contract: Option<SevenTeenTwentyNineEssay<SignerMiddleware<ethers_providers::Provider<Http>, Wallet<ethers::core::k256::ecdsa::SigningKey>>>>,
}

// #[derive(Debug)]
pub struct AnvilConnection {
    anvil: AnvilInstance,
    //wallet: LocalWallet,
    client: Arc<SignerMiddleware<ethers_providers::Provider<Http>, Wallet<ethers::core::k256::ecdsa::SigningKey>>>,
}

// TODO: Incomplete
// Necessary because AnvilInstance doesn't implement Debug so can't derive
impl std::fmt::Debug for WriterWorld {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("WriterWorld")
            .field("writer_name", &self.writer_name)
            .field("anvil initialized", &self.anvil.is_some())
            .finish()
    }
}

// `World` needs to be implemented, so Cucumber knows how to construct it
// for each scenario.
#[async_trait(?Send)]
impl World for WriterWorld {
    // We do require some error type.
    type Error = Infallible;

    async fn new() -> Result<Self, Infallible> {
        Ok(Self {
            // only here for data table test
            animals: HashMap::new(),

            writer_name: String::from(""),
            writer_address: String::from(""),

            cohort_number: String::from(""),
            week_number: String::from(""),

            essay_title: String::from(""),
            essay_number: String::from(""),

            essay_submission_count: String::from(""),

            participating_member_count: String::from(""),
            total_writer_count: String::from(""),

            voter_account: String::from(""),
            snapshot_block_number: String::from(""),

            winning_essay_title: String::from(""),
            winning_essay_content: String::from(""),
            winning_essay_publication_url: String::from(""),
            winning_essay_votes: String::from(""),

            winning_writer_name: String::from(""),
            winning_writer_address: String::from(""),

            anvil: Option::None, // Anvil is started and stopped in before/after hooks. Better way to do this?
            nft_contract: Option::None,
        })
    }
}

pub trait AnvilUtil {
    fn get_writer_wallet(&self) -> LocalWallet;
}

impl AnvilUtil for WriterWorld {
    fn get_writer_wallet(&self) -> LocalWallet {
        let anvil = self.anvil.as_ref().unwrap().anvil.borrow();
        let wallet: LocalWallet = anvil.keys()[0].clone().into();
        wallet
    }
}



#[tokio::main]
// Test runner
async fn main() //-> eyre::Result<()>
{
    let file = fs::File::create(dbg!(format!("{}/junit.xml", env!("OUT_DIR")))).expect("File should be found");
    //let world =
    WriterWorld::cucumber()
        // Start a fresh anvil before each scenario
        .before(move |_, _, _, world| {
            async move {
                let fork_endpoint = env::var("ETH_NODE_URL").expect("Environment variable ETH_NODE_URL should be defined and be a valid API URL");
                let anvil = Anvil::new()
//                    .fork(fork_endpoint)
                    .chain_id(31337_u64)
                    .spawn();
                let endpoint = anvil.endpoint();
                println!("Anvil running at `{}` with chain_id `{}`", endpoint, anvil.chain_id());

                let provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));

                let wallet: LocalWallet = anvil.keys()[0].clone().into();
                let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));
                let connection = AnvilConnection{
                    anvil: anvil,
                    client: client
                };
                world.anvil = Option::Some(connection);
            }.boxed()
        })
        //.cli()
        .with_writer(writer::JUnit::new(file,0))
        //.run_and_exit("tests/features/implemented")
        .run("tests/features/implemented")
        .await;

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
fn submit_then_1(world: &mut WriterWorld, essay_title: String, cohort_number: String, week_number: String) {
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
fn vote_scenario_2_then_1(world: &mut WriterWorld, voter_account: String, vote_count: String, essay_title: String) {
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
fn publish_given_1(world: &mut WriterWorld) {


    // Deploy contract
    let anvil = world.anvil.as_ref().unwrap().anvil.borrow();
    let provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));

    let wallet: LocalWallet = anvil.keys()[0].clone().into();
    let multisig = wallet.address();
    let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));

    let nft_contract = task::block_on(SevenTeenTwentyNineEssay::deploy(client, multisig).expect("Failed to deploy").send()).expect("Failed to send");
    world.nft_contract = Option::Some(nft_contract);

}

#[given(regex = r"^there are no NFTs minted on the contract$")]
async fn publish_given_2(world: &mut WriterWorld) {
        // Query Total Supply
    let nft_contract = world.nft_contract.as_ref().unwrap();
    let total_supply = nft_contract.method::<_, Uint>("totalSupply", ())
        .expect("Error finding method").call().await.expect("Error sending total supply call");
    assert_eq!(Uint::from(0), total_supply);
}

#[given(regex = r"^the Cohort is ([\d]+)$")]
fn publish_given_3(world: &mut WriterWorld, cohort_number: String) {
    world.cohort_number = cohort_number;
}

#[given(regex = r"^the Week is ([\d]+)$")]
fn publish_given_4(world: &mut WriterWorld, week_number: String) {
    world.week_number = week_number;
}

#[given(regex = r"^the winning essay is '([^']+)'$")]
fn publish_given_5(world: &mut WriterWorld, essay_title: String) {
    world.winning_essay_title = essay_title;
}

#[given(regex = r"^the essay content is '([^']+)'$")]
fn publish_given_6(world: &mut WriterWorld, essay_content: String) {
    world.winning_essay_content = essay_content;
}

#[given(regex = r"^the writer's name is '([^']+)' and address is '(0x[0-9A-Fa-f]+)'$")]
fn publish_given_7(world: &mut WriterWorld, writer_name: String, writer_address: String) {
    world.winning_writer_name = writer_name;
    world.winning_writer_address = writer_address;
}

#[given(regex = r"^the publication URL is '(https://[^']+)'$")]
fn publish_given_8(world: &mut WriterWorld, essay_publication_url: String) {
    world.winning_essay_publication_url = essay_publication_url;
}

#[given(regex = r"^the winning essay received ([\d]+) votes$")]
fn publish_given_9(world: &mut WriterWorld, essay_votes: String) {
    world.winning_essay_votes = essay_votes;
}

#[when("I mint, list, and bid on the Essay NFT")]
async fn publish_when_1(world: &mut WriterWorld) {

    // Mint Essay NFT
    let anvil = world.anvil.as_ref().unwrap().anvil.borrow();
    let client = world.anvil.as_ref().unwrap().client.clone();
    let wallet: LocalWallet = anvil.keys()[0].clone().into();
    let multisig = wallet.address();

    let nft_contract = world.nft_contract.as_ref().unwrap();
    const SHA_SUM:[u8; 32] = [0xb1,0x67,0x41,0x91,0xa8,0x8e,0xc5,0xcd,0xd7,0x33,0xe4,0x24,0x0a,0x81,0x80,0x31,0x05,
        0xdc,0x41,0x2d,0x6c,0x67,0x08,0xd5,0x3a,0xb9,0x4f,0xc2,0x48,0xf4,0xf5,0x53];
    let mint_call = nft_contract.mint(multisig, SHA_SUM, "https://test.com/test".to_string());  // TO-DO: Parameterize the URL and content hash
    task::block_on(mint_call.send()).expect("Failed to send mint transaction");

        // List
    let provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));
    let wallet: LocalWallet = anvil.keys()[0].clone().into();
    let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));
    let zora_address: ethers::core::types::Address = "0x5f7072E1fA7c01dfAc7Cf54289621AFAaD2184d0".parse::<Address>().expect("Couldn't parse zora address");
    let transfer_helper_address: H160 = "0x909e9efE4D87d1a6018C2065aE642b6D0447bc91".parse::<Address>().expect("Couldn't parse transfer helper address");
    let module_manager_address: H160 = "0x850A7c6fE2CF48eea1393554C8A3bA23f20CC401".parse::<Address>().expect("Couldn't parse transfer helper address");


    // Approve
    let reserve_auction_contract :Contract<SignerMiddleware<ethers_providers::Provider<Http>, Wallet<ethers::core::k256::ecdsa::SigningKey>>> = Contract::new(zora_address, RESERVEAUCTIONCOREETH_ABI.clone(), client.clone());
    let approve_call = nft_contract.set_approval_for_all(transfer_helper_address, true);
    task::block_on(approve_call.send()).expect("Failed to send approve transaction");

    let module_manager_contract :Contract<SignerMiddleware<ethers_providers::Provider<Http>, Wallet<ethers::core::k256::ecdsa::SigningKey>>> = Contract::new(module_manager_address, MODULEMANAGER_ABI.clone(), client.clone());
    module_manager_contract.method::<_, ()>("setApprovalForModule", (zora_address, true))
        .expect("Error finding setApprovalForModule method").send().await.expect("Error calling approval for module");

    let token_id = ethers::core::types::U256::from_dec_str("1").expect("Couldn't convert 1 to U256");

    // Look up block number for auction start
    let block_provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));
    let block = block_provider.get_block_number().await.expect("Couldn't get block height");
    let block_uint256 = ethers::prelude::U256::from(block.as_u64());

    // Create listing
    let auction_duration: ethers::prelude::U256 = ethers::core::types::U256::from(3*24*3600); // 3 days
    let auction_reserve_price: ethers::prelude::U256 = ethers::core::types::U256::from_dec_str("10000000000000000").expect("Reserve price should be a valid number");

    reserve_auction_contract.method::<_, ()>("createAuction", (nft_contract.address(), token_id, auction_duration, auction_reserve_price, multisig, block_uint256))
        .expect("Error finding createAuction method").send().await.expect("Error calling createAuction");

        // Place bid
    let bid_value = ethers::types::U256::from_dec_str("20000000000000000").expect("Value should parse");
    reserve_auction_contract.method::<_, ()>("createBid", (nft_contract.address(), token_id))
        .expect("Error finding createAuction method")
        .value(bid_value)
        .send().await.expect("Error calling createAuction");



}

#[then("There should be PLACEHOLDER STEP XYZ")]
fn publish_then_1(world: & mut WriterWorld) {
    // assert!(false, "Essay NFT bid is not found");
    panic!("STEPDEF not implemented yet");
}

////////////////////////////////////////////////////////////////
//                  Step Defs – Issue Proof of Contribution
////////////////////////////////////////////////////////////////

// TODO, uses data tables

#[given(regex = r"^There are ([\d]+) participating members in 1729 Writers$")]
fn issue_given_1(world: &mut WriterWorld, participating_member_count: String) {
    world.participating_member_count = participating_member_count;
}

#[given(regex = r"^There are ([\d]+) total writers in 1729 Writers Cohort ([\d]+)$")]
fn issue_given_2(world: &mut WriterWorld, total_writer_count: String, cohort_number: String) {
    world.total_writer_count = total_writer_count;
    world.cohort_number = cohort_number;
}

// data table test

#[given(regex = r"^a (hungry|satiated) animal$")]
fn hungry_animal(world: &mut WriterWorld, step: &Step, state: String) {
    let state = match state.as_str() {
        "hungry" => true,
        "satiated" => false,
        _ => unreachable!(),
    };

    if let Some(table) = step.table.as_ref() {
        for row in table.rows.iter().skip(1) { // skip header
            let animal = &row[0];

            world
                .animals
                .entry(animal.clone())
                .or_insert(Animal::default())
                .hungry = state;
        }
    }
}

#[when("I feed the animal multiple times")]
fn feed_animal(world: &mut WriterWorld, step: &Step) {
    if let Some(table) = step.table.as_ref() {
        for row in table.rows.iter().skip(1) { // skip dat header
            let animal = &row[0];
            let times = row[1].parse::<usize>().unwrap();

            for _ in 0..times {
                world.animals.get_mut(animal).map(Animal::feed);
            }
        }
    }
}

#[then("the animal is not hungry")]
fn animal_is_fed(world: &mut WriterWorld) {
    for animal in world.animals.values() {
        assert!(!animal.hungry); // aaaah — state is changed and saved in the one action step (When)
    }
}

#[derive(Debug, Default)]
struct Animal {
    pub hungry: bool,
}

impl Animal {
    fn feed(&mut self) {
        self.hungry = false;
    }
}

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
