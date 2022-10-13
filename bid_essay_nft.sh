#!/bin/bash
. ./.env
TOKEN_ID=$1;
BID_FINNEY=$(expr $BID_AMOUNT / 1000000000000000)
export TOKEN_ID
echo "Will use endpoint $RPC_URL with address $MULTISIG_ADDRESS to bid on NFT contract $TOKEN_ADDRESS"
echo "Zora contract addresses:"
echo "  Auction house: $AUCTION_HOUSE_ADDRESS"
echo "  Module manager: $MODULE_MANAGER_ADDRESS"
echo "  Transfer helper: $TRANSFER_HELPER_ADDRESS"
echo ""
echo "Bid details:"
echo "  Token Id: $TOKEN_ID"
echo "  Bid Amount (in Wei): $BID_AMOUNT"
echo "  Bid Amount (in Finney -- Eth/1000): $BID_FINNEY"
echo ""
read -p "Continue?  ( y/n ): " SANITY_CHECK
if ! [[ "$SANITY_CHECK" == "y" ]]
then
  exit 2
fi
# Unlock private key
PRIVATE_KEY=$(gpg -d /tmp/privkey.gpg)

echo "Placing bid..."
forge script script/BidEssay.s.sol:ListEssayScript --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --broadcast --slow --ffi
