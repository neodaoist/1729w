// This is here to make Cargo happy, for now
use ethers::utils::{Anvil};
use ethers_contract::abigen;
use ethers_middleware::signer::SignerMiddleware;
use ethers_providers::{Provider, Http};
use ethers::signers::Signer;
use ethers::prelude::LocalWallet;
use std::sync::Arc;
use std::time::Duration;
use async_std::task;
use ethers::abi::Uint;


abigen!(SevenTeenTwentyNineEssay, "out/1729Essay.sol/SevenTeenTwentyNineEssay.json");

#[tokio::main]
async fn main() {
    let anvil = Anvil::new().spawn();
    let endpoint = anvil.endpoint();
    println!("Anvil running at `{}`", endpoint);

    // Set up anvil
    let provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));

    let wallet: LocalWallet = anvil.keys()[0].clone().into();
    let multisig = wallet.address();
    let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));

    // Deploy contract
    let nft_contract = task::block_on(SevenTeenTwentyNineEssay::deploy(client, multisig).expect("Failed to deploy").send()).expect("Failed to send");

    // Mint Essay NFT
    let mint_call = nft_contract.mint(multisig, "Test Essay".to_string());
    task::block_on(mint_call.send()).expect("Failed to send mint transaction");

    let total_supply = nft_contract.method::<_, Uint>("totalSupply", ()).expect("Error finding method").call().await.expect("Error sending total supply call");
    println!("Total supply: {}", total_supply);
    

    println!("Done.");

}
