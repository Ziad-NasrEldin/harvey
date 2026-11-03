import AppKit
let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
NSColor.clear.setFill(); NSRect(x: 0, y: 0, width: size, height: size).fill()
let tile = NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896), xRadius: 198, yRadius: 198)
NSColor(calibratedRed: 0.12, green: 0.29, blue: 0.87, alpha: 1).setFill(); tile.fill()
NSColor.white.setFill()
NSBezierPath(roundedRect: NSRect(x: 280, y: 270, width: 112, height: 484), xRadius: 22, yRadius: 22).fill()
NSBezierPath(roundedRect: NSRect(x: 632, y: 270, width: 112, height: 484), xRadius: 22, yRadius: 22).fill()
NSBezierPath(roundedRect: NSRect(x: 370, y: 458, width: 284, height: 108), xRadius: 20, yRadius: 20).fill()
NSColor(calibratedRed: 0.48, green: 0.87, blue: 0.82, alpha: 1).setFill()
NSBezierPath(ovalIn: NSRect(x: 730, y: 754, width: 80, height: 80)).fill()
image.unlockFocus()
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
