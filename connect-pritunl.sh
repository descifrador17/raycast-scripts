#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title connect pritunl
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔑
# @raycast.packageName pritunl

# Documentation:
# @raycast.author Descifrador
# @raycast.authorURL https://raycast.com/descifrador

# to save authentication key to keychain if not already present. run this command once
# security add-generic-password -a "$USER" -s "key_name" -w


# Get current 2FA code from authentication key
# Read authentication key from keychain
AUTH_KEY=$(security find-generic-password -a "$USER" -s "pritunl-auth-key" -w 2>/dev/null)
PIN=$(security find-generic-password -a "$USER" -s "pritunl-vpn-pin" -w 2>/dev/null)

if [ -z "$AUTH_KEY" ]; then
    echo "Authentication key not found in keychain"
    exit 1
fi

TOTP_CODE=$(oathtool --totp -b "$AUTH_KEY")

if [ -z "$TOTP_CODE" ]; then
    echo "Failed to generate 2FA code"
    exit 1
fi

PRITUNL_PATH="/Applications/Pritunl.app/Contents/Resources/pritunl-client"
PROFILE_ID="<profile_id>"

$PRITUNL_PATH start $PROFILE_ID -p $PIN$TOTP_CODE
echo "Connecting..."
