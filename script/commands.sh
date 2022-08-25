# ERC20
forge create SevenTeenTwentyNineWritersCohort2 --rpc-url="https://mainnet.infura.io/v3/16782efe80f345afbd6eb65a60ab4146" --private-key=$PRIVATE_KEY
cast send --rpc-url="https://mainnet.infura.io/v3/16782efe80f345afbd6eb65a60ab4146" --private-key=$PRIVATE_KEY <contractAddress> "mint(address, 1)" <eoaAddress> <amount>

# ERC721 Essay NFT
forge create SevenTeenTwentyNineEssay --constructor-args "0xE5849cEccE98D5A434fFbA41E834277cb266398C" --rpc-url="https://rinkeby.infura.io/v3/16782efe80f345afbd6eb65a60ab4146" --private-key=$PRIVATE_KEY
forge verify-contract --compiler-version v0.8.15+commit.e14f2714 0x3fb9418f5b25ff0113d3d9da98f15d040b453a7f src/1729Essay.sol:SevenTeenTwentyNineEssay "$ETHERSCAN_API_KEY" --chain-id=4
forge verify-check "uumtzh1ag5jrpjai9hsmrv2yepszf6kbdcdjss9mqurbrk3c3j" "$ETHERSCAN_API_KEY"

cast send --rpc-url="https://rinkeby.infura.io/v3/16782efe80f345afbd6eb65a60ab4146" --private-key=$PRIVATE_KEY 0xfda78b7a8be64110447eb596dcff53fcc49bf74c "mint(uint256)" 1

# ERC1155 ProofOfContribution SBT
