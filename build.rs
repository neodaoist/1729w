use ethers::prelude::*;
//use ethers_contract::*;

fn main() {
    println!("cargo:rerun-if-changed=out/1729Essay.sol/OneSevenTwoNineEssay.json");
    Abigen::new("OneSevenTwoNineEssay", "./out/1729Essay.sol/OneSevenTwoNineEssay.json").expect("Failed to create new abigen")
        .generate().expect("Failed to generate")
        .write_to_file("target/OneSevenTwoNineEssay.rs").expect("Failed to write to file");
    // FIXME: Where should the output go?
}

