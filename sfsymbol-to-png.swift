#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title SF Symbol → PNG
// @raycast.mode fullOutput

// Optional parameters:
// @raycast.icon 🖼️
// @raycast.argument1 { "type": "text", "placeholder": "symbol name (e.g. heart.fill)" }
// @raycast.argument2 { "type": "dropdown", "placeholder": "size", "data": [{ "title": "200 × 200", "value": "200" }, { "title": "100 × 100", "value": "100" }, { "title": "400 × 400", "value": "400" }, { "title": "512 × 512", "value": "512" }, { "title": "1024 × 1024", "value": "1024" }] }
// @raycast.packageName dev utils

// Documentation:
// @raycast.description Renders an SF Symbol as a high-fidelity black-on-transparent PNG saved to the Desktop.
// @raycast.author Descifrador
// @raycast.authorURL ud.codes

import AppKit
import Foundation

// MARK: - Arguments

let args = CommandLine.arguments
let symbolName = args.count > 1 ? args[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
let sizeArg = args.count > 2 ? args[2].trimmingCharacters(in: .whitespacesAndNewlines) : "200"

guard !symbolName.isEmpty else {
    print("❌ Enter an SF Symbol name (e.g. heart.fill)")
    exit(1)
}

// Default to 200 for empty/unrecognized dropdown values, clamp to a sane range.
let size = min(max(Int(sizeArg) ?? 200, 1), 4096)
let pixels = CGFloat(size)

// MARK: - Load the symbol

guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
    print("❌ No SF Symbol named '\(symbolName)'")
    exit(1)
}

// Configure at a large point size so the vector rasterizes with full detail.
let config = NSImage.SymbolConfiguration(pointSize: pixels, weight: .regular, scale: .large)
let configured = symbol.withSymbolConfiguration(config) ?? symbol
configured.isTemplate = true

// MARK: - Render into an exact N×N transparent bitmap

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    print("❌ Could not create bitmap")
    exit(1)
}
rep.size = NSSize(width: pixels, height: pixels)

guard let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
    print("❌ Could not create graphics context")
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = ctx
ctx.imageInterpolation = .high

// Aspect-fit the glyph with ~8% padding, centered — keeps wide/tall symbols from clipping.
let inset = pixels * 0.08
let maxSide = pixels - inset * 2
let glyphSize = configured.size
let scale = glyphSize.width > 0 && glyphSize.height > 0
    ? min(maxSide / glyphSize.width, maxSide / glyphSize.height)
    : 1
let drawSize = NSSize(width: glyphSize.width * scale, height: glyphSize.height * scale)
let origin = NSPoint(x: (pixels - drawSize.width) / 2, y: (pixels - drawSize.height) / 2)
configured.draw(in: NSRect(origin: origin, size: drawSize), from: .zero, operation: .sourceOver, fraction: 1.0)

// Tint black: fill black only where the glyph has alpha, preserving antialiased edges.
NSColor.black.setFill()
NSRect(x: 0, y: 0, width: pixels, height: pixels).fill(using: .sourceAtop)

NSGraphicsContext.restoreGraphicsState()

// MARK: - Encode PNG

guard let png = rep.representation(using: .png, properties: [:]) else {
    print("❌ Could not encode PNG")
    exit(1)
}

// MARK: - Write to Desktop (never overwrite)

let home = FileManager.default.homeDirectoryForCurrentUser
let desktop = home.appendingPathComponent("Desktop")
let safeName = symbolName
    .replacingOccurrences(of: "/", with: "-")
    .replacingOccurrences(of: ":", with: "-")
let base = "\(safeName)@\(size)"

var url = desktop.appendingPathComponent("\(base).png")
var counter = 1
while FileManager.default.fileExists(atPath: url.path) {
    url = desktop.appendingPathComponent("\(base) -\(counter).png")
    counter += 1
}

do {
    try png.write(to: url)
    let shownPath = url.path.replacingOccurrences(of: home.path, with: "~")
    print("✅ Saved \(base) (\(size)×\(size)) → \(shownPath)")
} catch {
    print("❌ Could not write file: \(error.localizedDescription)")
    exit(1)
}
