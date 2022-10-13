#!/bin/bash
# Initialize 1729 writers
# Checks for dependencies.  Securely caches private key
if ! command -v sha256sum &> /dev/null
then
  echo "sha256sum is not installed or not in the path"
fi

if ! command -v gpg &> /dev/null
then
  echo "gpg is not installed or not in the path"
fi

if ! command -v forge &> /dev/null
then
  echo "forge is not installed or not in the path"
fi

. ./.env
read -p "Paste private key for address $MULTISIG_ADDRESS (will be encrypted and stored in /tmp/privkey.gpg)"$'\n' -s PRIVKEY
echo "Encrypting private key with gpg..."
echo "$PRIVKEY" | gpg -ac > /tmp/privkey.gpg


