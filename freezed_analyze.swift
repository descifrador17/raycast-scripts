#!/usr/bin/env swift
// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Freezed Analyze
// @raycast.mode fullOutput
//
// Optional parameters:
// @raycast.icon 🤡
// @raycast.packageName Dev Utils
// @raycast.argument1 { "type": "text", "placeholder": "Output CSV (optional)", "optional": true }
// @raycast.argument2 { "type": "text", "placeholder": "Directory path (optional)", "optional": true }
// @raycast.argument3 { "type": "text", "placeholder": "Aggregate per directory true/false", "optional": true }
// @raycast.needsConfirmation false
//
// Documentation:
// @raycast.description Create a CSV of .freezed.dart files with sizes (MB) in the current directory.
// @raycast.author Descifrador
// @raycast.authorURL ud.codes
//

import Foundation

let fm = FileManager.default

// Args: [script, output, dir, bool]
let argOutput = CommandLine.arguments.dropFirst().first?.trimmingCharacters(in: .whitespacesAndNewlines)
let argDir = CommandLine.arguments.dropFirst(2).first?.trimmingCharacters(in: .whitespacesAndNewlines)
let argBool = CommandLine.arguments.dropFirst(3).first?.trimmingCharacters(in: .whitespacesAndNewlines)

let cwd = argDir?.isEmpty == false ? NSString(string: argDir!).expandingTildeInPath : fm.currentDirectoryPath
let outputPath = argOutput?.isEmpty == false ? argOutput! : "freezed_sizes.csv"
let aggregatePerDir = (argBool == "true" || argBool == "1")

let bytesPerMB = 1024.0 * 1024.0

guard let enumerator = fm.enumerator(atPath: cwd) else {
    fputs("❌ Could not enumerate directory: \(cwd)\n", stderr)
    exit(1)
}

let numberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.locale = Locale(identifier: "en_US_POSIX")
    nf.minimumFractionDigits = 2
    nf.maximumFractionDigits = 2
    nf.numberStyle = .decimal
    return nf
}()

func isDirectory(_ path: String) -> Bool {
    var isDir: ObjCBool = false
    fm.fileExists(atPath: path, isDirectory: &isDir)
    return isDir.boolValue
}

if aggregatePerDir {
    // Directory-wise aggregation
    var dirSizes: [String: Double] = [:]

    for case let rel as String in enumerator {
        if rel.hasSuffix(".freezed.dart") {
            let fullPath = (cwd as NSString).appendingPathComponent(rel)
            if isDirectory(fullPath) { continue }
            do {
                let attrs = try fm.attributesOfItem(atPath: fullPath)
                let bytes = (attrs[.size] as? NSNumber)?.doubleValue ?? 0.0
                let mb = bytes / bytesPerMB
                let dirPath = (rel as NSString).deletingLastPathComponent
                dirSizes[dirPath, default: 0.0] += mb
            } catch { continue }
        }
    }

    var rows: [String] = []
    rows.append("directory | total size | path")
    for (dir, size) in dirSizes.sorted(by: { $0.key < $1.key }) {
        let sizeText = numberFormatter.string(from: NSNumber(value: size)) ?? "0.00"
        rows.append("\((dir as NSString).lastPathComponent) | \(sizeText) | \(dir)")
    }

    let csv = rows.joined(separator: "\n") + "\n"
    let finalOutputPath = (cwd as NSString).appendingPathComponent(outputPath)
    try? csv.write(to: URL(fileURLWithPath: finalOutputPath), atomically: true, encoding: .utf8)
    print("✅ Aggregated per directory. Wrote \(rows.count - 1) rows to \(finalOutputPath)")
    for line in rows.prefix(10) { print(line) }
    if rows.count > 10 { print("… (\(rows.count - 10) more lines)") }

} else {
    // File-wise output
    var rows: [String] = []
    rows.append("file name | size | filepath")

    for case let rel as String in enumerator {
        if rel.hasSuffix(".freezed.dart") {
            let fullPath = (cwd as NSString).appendingPathComponent(rel)
            if isDirectory(fullPath) { continue }
            do {
                let attrs = try fm.attributesOfItem(atPath: fullPath)
                let bytes = (attrs[.size] as? NSNumber)?.doubleValue ?? 0.0
                let mb = bytes / bytesPerMB
                let sizeText = numberFormatter.string(from: NSNumber(value: mb)) ?? "0.00"
                let fileName = URL(fileURLWithPath: fullPath).lastPathComponent
                rows.append("\(fileName) | \(sizeText) | \(rel)")
            } catch {
                let fileName = URL(fileURLWithPath: fullPath).lastPathComponent
                rows.append("\(fileName) | 0.00 | \(rel)")
            }
        }
    }

    let csv = rows.joined(separator: "\n") + "\n"
    let finalOutputPath = (cwd as NSString).appendingPathComponent(outputPath)
    try? csv.write(to: URL(fileURLWithPath: finalOutputPath), atomically: true, encoding: .utf8)
    print("✅ File split. Wrote \(rows.count - 1) rows to \(finalOutputPath)")
    for line in rows.prefix(10) { print(line) }
    if rows.count > 10 { print("… (\(rows.count - 10) more lines)") }
}
