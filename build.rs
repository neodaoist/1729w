use ethers::prelude::*;
//use ethers_contract::*;

fn main() {
    println!("cargo:rerun-if-changed=out/1729Essay.sol/SevenTeenTwentyNineEssay.json");
    Abigen::new("SevenTeenTwentyNineEssay", "./out/1729Essay.sol/SevenTeenTwentyNineEssay.json").expect("Failed to create new abigen")
        .generate().expect("Failed to generate")
        .write_to_file("target/SevenTeenTwentyNineEssay.rs").expect("Failed to write to file");
    // FIXME: Where should the output go?

    println!("cargo:rerun-if-changed=out/ListEssay.s.sol/ModuleManager.json");
    Abigen::new("ModuleManager", "out/ListEssay.s.sol/ModuleManager.json").expect("Failed to create new abigen")
        .generate().expect("Failed to generate")
        .write_to_file("target/ModuleManager.rs").expect("Failed to write to file");

    println!("cargo:rerun-if-changed=out/ListEssay.s.sol/ReserveAuctionCoreETH.json");
        Abigen::new("ModuleManager", "out/ListEssay.s.sol/ReserveAuctionCoreETH.json").expect("Failed to create new abigen")
        .generate().expect("Failed to generate")
        .write_to_file("target/ReserveAuctionCoreETH.rs").expect("Failed to write to file");

}
