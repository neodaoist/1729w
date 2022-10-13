#!/bin/bash
. ./.env
TOKEN_ID=$1;
RESERVE_FINNEY=$(expr $AUCTION_RESERVE_PRICE / 1000000000000000)
export TOKEN_ID
echo "Will use endpoint $RPC_URL with address $MULTISIG_ADDRESS to list NFT contract $TOKEN_ADDRESS"
echo "Zora contract addresses:"
echo "  Auction house: $AUCTION_HOUSE_ADDRESS"
echo "  Module manager: $MODULE_MANAGER_ADDRESS"
echo "  Transfer helper: $TRANSFER_HELPER_ADDRESS"
echo ""
echo "Listing details:"
echo "  Token Id: $TOKEN_ID"
echo "  Auction Duration (in seconds): $AUCTION_DURATION"
echo "  Reserve Amount (in Wei): $AUCTION_RESERVE_PRICE"
echo "  Reserve Amount (in Finney -- Eth/1000): $RESERVE_FINNEY"
echo ""
read -p "Continue?  ( y/n ): " SANITY_CHECK
if ! [[ "$SANITY_CHECK" == "y" ]]
then
  exit 2
fi
# Unlock private key
PRIVATE_KEY=$(gpg -d /tmp/privkey.gpg)

echo "Listing essay for auction..."
forge script script/ListEssay.s.sol:ListEssayScript --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --broadcast --slow --ffi
echo "Done"