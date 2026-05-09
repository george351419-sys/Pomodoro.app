import AppKit
import CoreGraphics

guard CommandLine.arguments.count >= 2 else {
    print("usage: make_icon.swift <output.png>")
    exit(1)
}

let outputPath = CommandLine.arguments[1]
let size: CGFloat = 1024

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    NSColor(red: r, green: g, blue: b, alpha: a).cgColor
}

let bgRect = CGRect(x: 0, y: 0, width: size, height: size)
let bgPath = CGPath(
    roundedRect: bgRect,
    cornerWidth: size * 0.225,
    cornerHeight: size * 0.225,
    transform: nil
)
ctx.saveGState()
ctx.addPath(bgPath)
ctx.clip()
let bgGrad = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        color(1.00, 0.97, 0.94),
        color(1.00, 0.88, 0.82)
    ] as CFArray,
    locations: [0, 1]
)!
ctx.drawLinearGradient(
    bgGrad,
    start: CGPoint(x: 0, y: size),
    end: CGPoint(x: 0, y: 0),
    options: []
)
ctx.restoreGState()

let center = CGPoint(x: size / 2, y: size * 0.44)
let radius = size * 0.305
let tomatoRect = CGRect(
    x: center.x - radius,
    y: center.y - radius,
    width: radius * 2,
    height: radius * 2
)

ctx.saveGState()
ctx.setShadow(
    offset: CGSize(width: 0, height: -size * 0.012),
    blur: size * 0.04,
    color: color(0, 0, 0, 0.18)
)
ctx.addEllipse(in: tomatoRect)
ctx.setFillColor(color(0.93, 0.27, 0.22))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addEllipse(in: tomatoRect)
ctx.clip()
let tomatoGrad = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        color(1.00, 0.55, 0.45),
        color(0.93, 0.27, 0.22),
        color(0.72, 0.15, 0.12)
    ] as CFArray,
    locations: [0, 0.5, 1]
)!
ctx.drawRadialGradient(
    tomatoGrad,
    startCenter: CGPoint(x: center.x - radius * 0.35, y: center.y + radius * 0.35),
    startRadius: 0,
    endCenter: center,
    endRadius: radius * 1.25,
    options: []
)
ctx.restoreGState()

let highlightRect = CGRect(
    x: center.x - radius * 0.55,
    y: center.y + radius * 0.15,
    width: radius * 0.55,
    height: radius * 0.40
)
ctx.saveGState()
ctx.addEllipse(in: highlightRect)
ctx.setFillColor(color(1, 1, 1, 0.22))
ctx.fillPath()
ctx.restoreGState()

let faceRadius = radius * 0.62
let faceRect = CGRect(
    x: center.x - faceRadius,
    y: center.y - faceRadius,
    width: faceRadius * 2,
    height: faceRadius * 2
)

ctx.saveGState()
ctx.setShadow(
    offset: .zero,
    blur: size * 0.015,
    color: color(0, 0, 0, 0.25)
)
ctx.addEllipse(in: faceRect)
ctx.setFillColor(color(0.99, 0.96, 0.92))
ctx.fillPath()
ctx.restoreGState()

ctx.setStrokeColor(color(0.55, 0.10, 0.08))
ctx.setLineWidth(size * 0.012)
ctx.strokeEllipse(in: faceRect)

ctx.setStrokeColor(color(0.40, 0.08, 0.06))
ctx.setLineCap(.round)
for i in 0..<12 {
    let angle = CGFloat(i) * .pi / 6
    let isMajor = (i % 3 == 0)
    let outerR = faceRadius * 0.93
    let innerR = faceRadius * (isMajor ? 0.78 : 0.85)
    let lineW = size * (isMajor ? 0.014 : 0.008)
    ctx.setLineWidth(lineW)
    let outer = CGPoint(
        x: center.x + cos(angle) * outerR,
        y: center.y + sin(angle) * outerR
    )
    let inner = CGPoint(
        x: center.x + cos(angle) * innerR,
        y: center.y + sin(angle) * innerR
    )
    ctx.move(to: inner)
    ctx.addLine(to: outer)
    ctx.strokePath()
}

ctx.setStrokeColor(color(0.20, 0.04, 0.03))
ctx.setLineCap(.round)

let hourAngle = CGFloat.pi / 2 - CGFloat.pi / 6
ctx.setLineWidth(size * 0.022)
ctx.move(to: center)
ctx.addLine(to: CGPoint(
    x: center.x + cos(hourAngle) * faceRadius * 0.50,
    y: center.y + sin(hourAngle) * faceRadius * 0.50
))
ctx.strokePath()

let minuteAngle = CGFloat.pi / 2 + CGFloat.pi / 3
ctx.setLineWidth(size * 0.016)
ctx.move(to: center)
ctx.addLine(to: CGPoint(
    x: center.x + cos(minuteAngle) * faceRadius * 0.72,
    y: center.y + sin(minuteAngle) * faceRadius * 0.72
))
ctx.strokePath()

let pinR = size * 0.018
ctx.setFillColor(color(0.20, 0.04, 0.03))
ctx.fillEllipse(in: CGRect(
    x: center.x - pinR,
    y: center.y - pinR,
    width: pinR * 2,
    height: pinR * 2
))

let stemBase = CGPoint(x: center.x, y: center.y + radius * 0.96)

ctx.saveGState()
ctx.translateBy(x: stemBase.x, y: stemBase.y)
let leafColors = [
    color(0.45, 0.75, 0.35),
    color(0.30, 0.60, 0.25)
]
let leafGrad = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: leafColors as CFArray,
    locations: [0, 1]
)!

for (idx, rotation) in [-0.6, 0.0, 0.6].enumerated() {
    ctx.saveGState()
    ctx.rotate(by: CGFloat(rotation))
    let leaf = CGMutablePath()
    let h = size * (idx == 1 ? 0.13 : 0.10)
    let w = size * 0.045
    leaf.move(to: .zero)
    leaf.addQuadCurve(
        to: CGPoint(x: 0, y: h),
        control: CGPoint(x: w, y: h * 0.55)
    )
    leaf.addQuadCurve(
        to: .zero,
        control: CGPoint(x: -w, y: h * 0.55)
    )
    leaf.closeSubpath()

    ctx.addPath(leaf)
    ctx.clip()
    ctx.drawLinearGradient(
        leafGrad,
        start: CGPoint(x: 0, y: 0),
        end: CGPoint(x: 0, y: h),
        options: []
    )
    ctx.resetClip()

    ctx.addPath(leaf)
    ctx.setStrokeColor(color(0.20, 0.45, 0.18))
    ctx.setLineWidth(size * 0.005)
    ctx.strokePath()
    ctx.restoreGState()
}

ctx.setFillColor(color(0.45, 0.30, 0.12))
let stemW = size * 0.022
let stemH = size * 0.05
ctx.fill(CGRect(
    x: -stemW / 2,
    y: -size * 0.005,
    width: stemW,
    height: stemH
))
ctx.restoreGState()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    print("Failed to encode PNG")
    exit(1)
}

try png.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath)")
