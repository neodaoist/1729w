use ethers::prelude::*;
//use ethers_contract::*;

fn main() {
    println!("cargo:rerun-if-changed=out/1729Essay.sol/SevenTeenTwentyNineEssay.json");
    Abigen::new("SevenTeenTwentyNineEssay", "./out/1729Essay.sol/SevenTeenTwentyNineEssay.json").expect("Failed to create new abigen")
        .generate().expect("Failed to generate")
        .write_to_file("target/SevenTeenTwentyNineEssay.rs").expect("Failed to write to file");
    // FIXME: Where should the output go?
}

