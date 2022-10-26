#!/bin/bash
. ./.env
echo "Will use endpoint $RPC_URL with address $MULTISIG_ADDRESS to mint on NFT contract $TOKEN_ADDRESS"
read -p "Enter SBT Title: " SBT_TITLE
read -p "Enter IPFS URI for the Essay Image: " IMAGE_URI

echo ""
echo "Minting PoC SBT with:"
echo "  Title: $SBT_TITLE";
echo "  Image URI: $IMAGE_URI"
echo ""
read -p "Continue?  ( y/n ): " SANITY_CHECK
if ! [[ "$SANITY_CHECK" == "y" ]]
then
  exit 2
fi
# Unlock private key
PRIVATE_KEY=$(gpg -d /tmp/privkey.gpg)

# Call forge script to do the minting
export SBT_TITLE
export IMAGE_URI
echo "Minting..."
forge script script/CreateSBT.s.sol:CreateSBTScript --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --broadcast --ffi
echo "Done"
