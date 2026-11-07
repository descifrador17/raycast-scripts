#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Convert Timestamp to IST
// @raycast.mode fullOutput

// Optional parameters:
// @raycast.icon 🕒
// @raycast.packageName dev utils
// @raycast.argument1 { "type": "text", "placeholder": "ISO 8601 timestamp" }

// Documentation:
// @raycast.description Converts an ISO 8601 UTC timestamp into a human-readable IST time and copies it to the clipboard.
// @raycast.author Descifrador
// @raycast.authorURL ud.codes

import AppKit
import Foundation

guard CommandLine.arguments.count > 1 else {
    print("Error: pass an ISO 8601 timestamp as an argument.")
    exit(1)
}

let input = CommandLine.arguments[1].trimmingCharacters(in: .whitespacesAndNewlines)

// ISO8601DateFormatter only supports up to millisecond precision, so collapse any
// higher-precision fractional seconds (e.g. nanoseconds) down to 3 digits.
func normalize(_ s: String) -> String {
    let pattern = #"(\.\d{1,9})(?=Z|[+-]\d{2}:?\d{2}|$)"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return s }
    let range = NSRange(s.startIndex..., in: s)
    let trimmed = NSMutableString(string: s)
    regex.enumerateMatches(in: s, range: range) { match, _, _ in
        guard let m = match, let r = Range(m.range(at: 1), in: s) else { return }
        let frac = String(s[r])
        let truncated = String(frac.prefix(4)) // "." + up to 3 digits
        trimmed.replaceCharacters(in: m.range(at: 1), with: truncated)
    }
    return trimmed as String
}

let normalized = normalize(input)

let parsers: [ISO8601DateFormatter] = {
    let withFrac = ISO8601DateFormatter()
    withFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let plain = ISO8601DateFormatter()
    plain.formatOptions = [.withInternetDateTime]
    return [withFrac, plain]
}()

let date: Date? = parsers.lazy.compactMap { $0.date(from: normalized) }.first

guard let date else {
    print("Error: could not parse timestamp '\(input)'.")
    exit(1)
}

let out = DateFormatter()
out.locale = Locale(identifier: "en_US_POSIX")
out.timeZone = TimeZone(identifier: "Asia/Kolkata")
out.dateFormat = "EEE, d MMM yyyy, h:mm:ss a 'IST'"
let formatted = out.string(from: date)

let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(formatted, forType: .string)

print("UTC: \(input)")
print("IST: \(formatted)")
print("(copied to clipboard)")
