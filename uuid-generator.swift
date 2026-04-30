#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Generate UUID
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🆔
// @raycast.packageName dev utils

// Documentation:
// @raycast.description Generates a UUID and copies it to the clipboard
// @raycast.author Descifrador
// @raycast.authorURL ud.codes

import AppKit
import Foundation

let uuid = UUID().uuidString

let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(uuid, forType: .string)

print("Copied: \(uuid)")
