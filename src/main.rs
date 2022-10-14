// This is here to make Cargo happy, for now
use ethers::utils::{Anvil};
use ethers_contract::{abigen, Contract};
use ethers_middleware::signer::SignerMiddleware;
use ethers_providers::{Provider, Http, Middleware};
use ethers::signers::{Signer, Wallet};
use ethers::prelude::LocalWallet;
use ethers_core::types::{Address, H160};
use std::sync::Arc;
use std::time::Duration;
use async_std::task;
use ethers::abi::Uint;
use std::env;
use ethers_core::utils::hex;

// Generate Rust bindings for all required contracts
abigen!(SevenTeenTwentyNineEssay, "out/1729Essay.sol/SevenTeenTwentyNineEssay.json");
abigen!(ListBidEssayScript, "out/ListEssay.s.sol/ListEssayScript.json");
abigen!(ReserveAuctionCoreETH, "out/ListEssay.s.sol/ReserveAuctionCoreETH.json");
abigen!(ModuleManager, "out/ListEssay.s.sol/ModuleManager.json");



#[tokio::main]
async fn main() {
    let fork_endpoint = env::var("ETH_NODE_URL").expect("Environment variable ETH_NODE_URL should be defined and be a valid API URL");
    let anvil = Anvil::new()
        .fork(fork_endpoint)
        .chain_id(31337_u64)
        .spawn();
    let endpoint = anvil.endpoint();
    println!("Anvil running at `{}` with chain_id `{}`", endpoint, anvil.chain_id());

    // Set up anvil
    let provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));

    let wallet: LocalWallet = anvil.keys()[0].clone().into();
    let multisig = wallet.address();
    let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));
    let block_provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));

    let block = block_provider.get_block_number().await.expect("Couldn't get block height");
    let block_uint256 = ethers::prelude::U256::from(block.as_u64());
    println!("Forked from block {}", block);

    // Deploy contract
    let nft_contract = task::block_on(SevenTeenTwentyNineEssay::deploy(client, multisig).expect("Failed to deploy").send()).expect("Failed to send");

    // Mint Essay NFT
    const SHA_SUM:[u8; 32] = [0xb1,0x67,0x41,0x91,0xa8,0x8e,0xc5,0xcd,0xd7,0x33,0xe4,0x24,0x0a,0x81,0x80,0x31,0x05,
        0xdc,0x41,0x2d,0x6c,0x67,0x08,0xd5,0x3a,0xb9,0x4f,0xc2,0x48,0xf4,0xf5,0x53];
    let mint_call = nft_contract.mint(multisig, SHA_SUM, "https://test.com/test".to_string());
    task::block_on(mint_call.send()).expect("Failed to send mint transaction");

    // Query Total Supply
    let total_supply = nft_contract.method::<_, Uint>("totalSupply", ())
        .expect("Error finding method").call().await.expect("Error sending total supply call");
    println!("Total supply: {}", total_supply);

    // Query royalty info
    let token_id = ethers::core::types::U256::from_dec_str("1").expect("Couldn't convert 1 to U256");
    let sale_price = ethers::core::types::U256::from_dec_str("5000000000000000000").expect("Couldn't convert 5*10^18 to U256");
    let royalty_info = nft_contract.method::<_, (ethers::core::types::Address, ethers::core::types::U256)>("royaltyInfo", (token_id, sale_price))
        .expect("Error finding royaltyInfo method").call().await.expect("Error sending royaltyInfo call");


    println!("Royalty info: address: {}, amount: {}", royalty_info.0, royalty_info.1);

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

    // Create auction
    println!("Creating listing");
    let auction_duration: ethers::prelude::U256 = ethers::core::types::U256::from(3*24*3600); // 3 days
    let auction_reserve_price: ethers::prelude::U256 = ethers::core::types::U256::from_dec_str("10000000000000000").expect("Reserve price should be a valid number");

    reserve_auction_contract.method::<_, ()>("createAuction", (nft_contract.address(), token_id, auction_duration, auction_reserve_price, multisig, block_uint256))
        .expect("Error finding createAuction method").send().await.expect("Error calling createAuction");

    // Verify listing
        //(address seller, uint256 reservePrice, address fundsRecipient,,, uint256 duration,,) =
          //  auctionHouse.auctionForNFT(address(nft), 1);
    let auction_info = reserve_auction_contract.method::<_, (ethers::core::types::Address, // seller
                                                             u128,  // reserve price
                                                             ethers::core::types::Address,  // sellerFundsRecipient
                                                             u128, // highestBid
                                                             ethers::core::types::Address, // highest bidder
                                                             u32, // duration
                                                             u32, // start time
                                                             u32, // first bid time
    )>("auctionForNFT", (nft_contract.address(), token_id))
        .expect("auctionForNFT method should resolve").call().await.expect("auctionForNFT call should complete");

      println!("Auction info: seller={} reserve_price={} seller_funds_recipient={} highest_bid={} highest_bidder={} duration={} start_time={} first_bid_time={}",
               auction_info.0, auction_info.1, auction_info.2, auction_info.3,
               auction_info.4, auction_info.5, auction_info.6, auction_info.7);

    // Place bid
    println!("Placing bid");
    let bid_value = ethers::types::U256::from_dec_str("20000000000000000").expect("Value should parse");
    reserve_auction_contract.method::<_, ()>("createBid", (nft_contract.address(), token_id))
        .expect("Error finding createAuction method")
        .value(bid_value)
        .send().await.expect("Error calling createAuction");

    // Verify listing
    let auction_info = reserve_auction_contract.method::<_, (ethers::core::types::Address, // seller
                                                             u128,  // reserve price
                                                             ethers::core::types::Address,  // sellerFundsRecipient
                                                             u128, // highestBid
                                                             ethers::core::types::Address, // highest bidder
                                                             u32, // duration
                                                             u32, // start time
                                                             u32, // first bid time
    )>("auctionForNFT", (nft_contract.address(), token_id))
        .expect("auctionForNFT method should resolve").call().await.expect("auctionForNFT call should complete");

      println!("Auction info: seller={} reserve_price={} seller_funds_recipient={} highest_bid={} highest_bidder={} duration={} start_time={} first_bid_time={}",
               auction_info.0, auction_info.1, auction_info.2, auction_info.3,
               auction_info.4, auction_info.5, auction_info.6, auction_info.7);

    // List/Bid
    /*
    let provider = Provider::<Http>::try_from(anvil.endpoint()).expect("Failed to connect to Anvil").interval(Duration::from_millis(10u64));
    let wallet: LocalWallet = anvil.keys()[0].clone().into();
    let client = Arc::new(SignerMiddleware::new(provider, wallet.with_chain_id(anvil.chain_id())));
    let list_bid_script = task::block_on(ListBidEssayScript::deploy(client, multisig).expect("Failed to deploy").send()).expect("Failed to send");

    let script_call = list_bid_script.run();
    script_call.send().await.expect("Failed to run script");
*/


    println!("Done.");

}
