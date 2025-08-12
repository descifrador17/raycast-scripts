#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title disconnect pritunl
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔑
# @raycast.packageName pritunl

# Documentation:
# @raycast.author Descifrador
# @raycast.authorURL https://raycast.com/descifrador

/Applications/Pritunl.app/Contents/Resources/pritunl-client stop <profile_id>
echo "Disconnecting..."
