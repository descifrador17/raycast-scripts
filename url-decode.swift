#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title urlDecode
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔗
// @raycast.argument1 { "type": "text", "placeholder": "encoded string" }
// @raycast.packageName dev utils

// Documentation:
// @raycast.description percent-decodes a string and copies it to the clipboard
// @raycast.author Descifrador
// @raycast.authorURL ud.codes

import AppKit
import Foundation

let input = CommandLine.arguments[1]

guard let decoded = input.removingPercentEncoding else {
    print("Invalid percent-encoding")
    exit(1)
}

let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(decoded, forType: .string)

print("Copied: " + decoded)
