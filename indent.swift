#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title indentIt
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🔪
// @raycast.argument1 { "type": "text", "placeholder": "raw string" }
// @raycast.packageName dev utils

// Documentation:
// @raycast.description indents raw sting based on brackets, commas and semicolons
// @raycast.author Descifrador
// @raycast.authorURL https://raycast.com/descifrador

import AppKit
import Foundation

let input = CommandLine.arguments[1]
print("Indenting: " + input)

let openBrackets: Set<Character> = ["{", "[", "("]
let closeBrackets: Set<Character> = ["}", "]", ")"]
let breakChars: Set<Character> = openBrackets.union(closeBrackets).union([";", ","])

let indentUnit = "    " // 4 spaces
var indentLevel = 0

var buffer = ""
var resultLines: [String] = []

func flushBuffer() {
    let trimmed = buffer.trimmingCharacters(in: .whitespaces)
    if trimmed.isEmpty { buffer = ""; return }

    let startsWithClose = trimmed.first.map { closeBrackets.contains($0) } ?? false
    if startsWithClose {
        indentLevel = max(indentLevel - 1, 0)
    }

    let indent = String(repeating: indentUnit, count: indentLevel)
    resultLines.append("\(indent)\(trimmed)")

    let opens = trimmed.filter { openBrackets.contains($0) }.count
    let closes = trimmed.filter { closeBrackets.contains($0) }.count
    indentLevel += opens - closes
    indentLevel = max(indentLevel, 0)

    buffer = ""
}

for char in input {
    buffer.append(char)

    if breakChars.contains(char) {
        flushBuffer()
    }
}

flushBuffer()

// Wrap in Swift triple-quoted string
let formatted = """
\"\"\"
\(resultLines.joined(separator: "\n"))
\"\"\"
"""

// Copy to clipboard
let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(formatted, forType: .string)
