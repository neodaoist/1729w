#!/bin/bash
. ./.env
echo "Will use endpoint $RPC_URL with address $MULTISIG_ADDRESS to mint on NFT contract $TOKEN_ADDRESS"
read -p "Enter SBT Token ID: " TOKEN_ID
read -p "Enter Recipients (raw eth addresses, separated by commas: " SBT_RECIPIENTS

echo ""
echo "Issuing PoC SBTs with:"
echo "  Token ID: $TOKEN_ID";
echo "  Recipients: $SBT_RECIPIENTS"
echo ""
read -p "Continue?  ( y/n ): " SANITY_CHECK
if ! [[ "$SANITY_CHECK" == "y" ]]
then
  exit 2
fi
# Unlock private key
PRIVATE_KEY=$(gpg -d /tmp/privkey.gpg)

# Call forge script to do the minting
export TOKEN_ID
export SBT_RECIPIENTS
echo "Issuing..."
forge script script/IssueSBT.s.sol:IssueSBTScript --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --broadcast --ffi
echo "Done"
