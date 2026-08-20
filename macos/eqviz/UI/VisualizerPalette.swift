import CoreGraphics
import SwiftUI

struct VisualizerRGB: Equatable {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat

    func color() -> Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

enum VisualizerPalette {
    static let unlitBrightness: CGFloat = 0.12

    static func color(style: VisualizerStyle, band: Int, segment: Int, lit: Bool) -> Color {
        rgb(style: style, band: band, segment: segment, lit: lit).color()
    }

    static func rgb(style: VisualizerStyle, band: Int, segment: Int, lit: Bool) -> VisualizerRGB {
        let litRGB = litColor(style: style, band: band, segment: segment)
        if lit { return litRGB }
        return unlitColor(style: style, lit: litRGB)
    }

    private static func litColor(style: VisualizerStyle, band: Int, segment: Int) -> VisualizerRGB {
        switch style {
        case .retroRed:
            return VisualizerRGB(r: 1.0, g: 0.12, b: 0.08)
        case .whiteMatrix:
            return VisualizerRGB(r: 1, g: 1, b: 1)
        case .rainbowSpectrum:
            let hue = CGFloat(max(0, band)) / CGFloat(VisualizerGrid.bandCount)
            return hsv(h: hue, s: 1, v: 1)
        case .fireGradient:
            return fire(segment: segment)
        case .cyberNeon:
            return cyber(segment: segment)
        }
    }

    private static func unlitColor(style: VisualizerStyle, lit: VisualizerRGB) -> VisualizerRGB {
        switch style {
        case .retroRed:
            return VisualizerRGB(r: 0.12, g: 0.02, b: 0.02)
        case .whiteMatrix:
            return VisualizerRGB(r: 0, g: 0, b: 0)
        case .rainbowSpectrum, .fireGradient, .cyberNeon:
            let hsv = rgbToHsv(lit)
            return Self.hsv(h: hsv.h, s: hsv.s, v: unlitBrightness)
        }
    }

    private static func fire(segment: Int) -> VisualizerRGB {
        let t = CGFloat(max(0, segment)) / CGFloat(max(1, VisualizerGrid.segmentCount - 1))
        let green = VisualizerRGB(r: 0.05, g: 0.85, b: 0.12)
        let yellow = VisualizerRGB(r: 1, g: 0.92, b: 0.05)
        let red = VisualizerRGB(r: 1, g: 0.08, b: 0.02)
        if t < 0.5 {
            return lerp(green, yellow, t: t / 0.5)
        }
        return lerp(yellow, red, t: (t - 0.5) / 0.5)
    }

    private static func cyber(segment: Int) -> VisualizerRGB {
        let t = CGFloat(max(0, segment)) / CGFloat(max(1, VisualizerGrid.segmentCount - 1))
        let cyan = VisualizerRGB(r: 0.0, g: 1.0, b: 1.0)
        let blue = VisualizerRGB(r: 0.15, g: 0.35, b: 1.0)
        let magenta = VisualizerRGB(r: 1.0, g: 0.0, b: 0.85)
        if t < 0.5 {
            return lerp(cyan, blue, t: t / 0.5)
        }
        return lerp(blue, magenta, t: (t - 0.5) / 0.5)
    }

    private static func lerp(_ a: VisualizerRGB, _ b: VisualizerRGB, t: CGFloat) -> VisualizerRGB {
        let t = min(1, max(0, t))
        return VisualizerRGB(
            r: a.r + (b.r - a.r) * t,
            g: a.g + (b.g - a.g) * t,
            b: a.b + (b.b - a.b) * t
        )
    }

    static func hsv(h: CGFloat, s: CGFloat, v: CGFloat) -> VisualizerRGB {
        let wrapped = h.truncatingRemainder(dividingBy: 1)
        let hue = wrapped < 0 ? wrapped + 1 : wrapped
        let h6 = hue * 6
        let i = Int(h6)
        let f = h6 - CGFloat(i)
        let p = v * (1 - s)
        let q = v * (1 - s * f)
        let t = v * (1 - s * (1 - f))
        switch i % 6 {
        case 0: return VisualizerRGB(r: v, g: t, b: p)
        case 1: return VisualizerRGB(r: q, g: v, b: p)
        case 2: return VisualizerRGB(r: p, g: v, b: t)
        case 3: return VisualizerRGB(r: p, g: q, b: v)
        case 4: return VisualizerRGB(r: t, g: p, b: v)
        default: return VisualizerRGB(r: v, g: p, b: q)
        }
    }

    static func rgbToHsv(_ rgb: VisualizerRGB) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let maxC = max(rgb.r, rgb.g, rgb.b)
        let minC = min(rgb.r, rgb.g, rgb.b)
        let delta = maxC - minC
        var h: CGFloat = 0
        if delta > 0 {
            if maxC == rgb.r {
                h = (rgb.g - rgb.b) / delta + (rgb.g < rgb.b ? 6 : 0)
            } else if maxC == rgb.g {
                h = (rgb.b - rgb.r) / delta + 2
            } else {
                h = (rgb.r - rgb.g) / delta + 4
            }
            h /= 6
        }
        let s = maxC == 0 ? 0 : delta / maxC
        return (h, s, maxC)
    }
}
