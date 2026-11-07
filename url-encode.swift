#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title urlEncode
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔗
// @raycast.argument1 { "type": "text", "placeholder": "raw string" }
// @raycast.packageName dev utils

// Documentation:
// @raycast.description percent-encodes a string (RFC 3986 unreserved) and copies it to the clipboard
// @raycast.author Descifrador
// @raycast.authorURL ud.codes

import AppKit
import Foundation

let input = CommandLine.arguments[1]

// unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"; everything else gets encoded
let unreserved = CharacterSet(charactersIn: "-._~").union(.alphanumerics)
let encoded = input.addingPercentEncoding(withAllowedCharacters: unreserved)!

let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(encoded, forType: .string)

print("Copied: " + encoded)
