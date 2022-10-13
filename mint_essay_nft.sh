#!/bin/bash
. ./.env
echo "Will use endpoint $RPC_URL with address $MULTISIG_ADDRESS to mint on NFT contract $TOKEN_ADDRESS"
read -p "Enter writer Eth address: " AUTHOR_ADDRESS
read -p "Enter IPFS URI for the Essay Metadata: " ESSAY_URL
read -p "Enter essay Markdown file path: " MARKDOWN_PATH
if ! [ -f "$MARKDOWN_PATH" ]
then
  echo "File not found"
  exit 1
fi
CONTENT_HASH=$(sha256sum $MARKDOWN_PATH | cut -d " " -f 1)
#echo "Computed content hash: $CONTENT_HASH"
echo ""
echo "Minting Essay NFT with:"
echo "  Writer address: $AUTHOR_ADDRESS";
echo "  Metadata URI: $ESSAY_URL"
echo "  Content hash: $CONTENT_HASH"
echo ""
read -p "Continue?  ( y/n ): " SANITY_CHECK
if ! [[ "$SANITY_CHECK" == "y" ]]
then
  exit 2
fi
# Unlock private key
PRIVATE_KEY=$(gpg -d /tmp/privkey.gpg)

# Call forge script to do the minting
export AUTHOR_ADDRESS
export ESSAY_URL
export CONTENT_HASH
echo "Minting..."
forge script script/MintEssay.s.sol:MintEssayScript --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --broadcast --ffi
echo "Done"