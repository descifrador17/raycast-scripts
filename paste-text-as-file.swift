#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Paste Text As File
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 📄
// @raycast.argument1 { "type": "text", "placeholder": "filename (optional)", "optional": true }
// @raycast.packageName Clipboard

// Documentation:
// @raycast.description Writes clipboard text to a temp file and puts the file on the clipboard, so pasting in Finder/Slack/Mail yields a file.
// @raycast.author Descifrador
// @raycast.authorURL ud.codes

import AppKit
import Foundation

let pasteboard = NSPasteboard.general

guard let text = pasteboard.string(forType: .string), !text.isEmpty else {
    print("No text in clipboard")
    exit(0)
}

func defaultFilename() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd-HHmmss"
    return "paste-\(formatter.string(from: Date())).txt"
}

func resolveFilename(_ raw: String?) -> String {
    guard let raw = raw?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else {
        return defaultFilename()
    }
    let leaf = (raw as NSString).lastPathComponent
    guard !leaf.isEmpty else { return defaultFilename() }
    let ext = (leaf as NSString).pathExtension
    return ext.isEmpty ? "\(leaf).txt" : leaf
}

let argFilename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil
let filename = resolveFilename(argFilename)

let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)

do {
    try text.write(to: url, atomically: true, encoding: .utf8)
} catch {
    print("Failed to write file: \(error.localizedDescription)")
    exit(1)
}

pasteboard.clearContents()
guard pasteboard.writeObjects([url as NSURL]) else {
    print("Failed to write file URL to clipboard")
    exit(1)
}

print("OK: \(filename) ready to paste")
