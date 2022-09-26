// This is here to make Cargo happy, for now
use ethers::utils::{Anvil, AnvilInstance};
use ethers_contract::abigen;
use ethers_middleware::signer::SignerMiddleware;
use ethers_providers::{Provider, Http, Middleware};
use ethers::signers::Signer;
use ethers::prelude::Wallet;
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

    /*
    let total_supply_call = nft_contract.total_supply();
    let pending_receipt = total_supply_call.send().await.expect("Failed to call mint function");
    let receipt = pending_receipt.confirmations(1).await.expect("Failet to get confirmation");
    println!("Receipt: {}", receipt.unwrap());
*/

    /*
    let factory = ethers::contract::ContractFactory::new(
        SEVENTEENTWENTYNINEESSAY_ABI.clone(),
        SEVENTEENTWENTYNINEESSAY_BYTECODE.clone().into(),
        client,
    );
    let deployer_result = factory.deploy(multisig);
    let deployer = match deployer_result {
        Ok(deployer) => deployer,
        Err(error) => panic!("Error result from deploy: {:?}", error),
    };
*/
//    let deployer: ethers::contract::ContractDeployer<SignerMiddleware<ethers_providers::Provider<Http>, Wallet<ethers::core::k256::ecdsa::SigningKey>>, ethers::contract::Contract<SignerMiddleware<ethers_providers::Provider<Http>, Wallet<ethers::core::k256::ecdsa::SigningKey>>>> = ethers::contract::ContractDeployer::new(deployer);


    println!("Hello, world!");


}
