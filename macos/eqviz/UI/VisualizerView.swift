import SwiftUI

enum VisualizerGrid {
    static let bandCount = 32
    static let segmentCount = 16
    static let gap: CGFloat = 2
}

/// Square-cell grid centered in the canvas. Cells stay square; leftover space is letterboxed.
struct VisualizerLayout: Equatable {
    let origin: CGPoint
    let cell: CGFloat
    let gap: CGFloat
    let bandCount: Int
    let segmentCount: Int

    var gridSize: CGSize {
        CGSize(
            width: CGFloat(bandCount) * cell + CGFloat(max(0, bandCount - 1)) * gap,
            height: CGFloat(segmentCount) * cell + CGFloat(max(0, segmentCount - 1)) * gap
        )
    }

    static func fitting(
        in size: CGSize,
        bandCount: Int = VisualizerGrid.bandCount,
        segmentCount: Int = VisualizerGrid.segmentCount,
        gap: CGFloat = VisualizerGrid.gap
    ) -> VisualizerLayout {
        let gapsX = CGFloat(max(0, bandCount - 1))
        let gapsY = CGFloat(max(0, segmentCount - 1))
        let cellX = bandCount > 0 ? (size.width - gapsX * gap) / CGFloat(bandCount) : 0
        let cellY = segmentCount > 0 ? (size.height - gapsY * gap) / CGFloat(segmentCount) : 0
        let cell = max(0, min(cellX, cellY))
        let gridW = CGFloat(bandCount) * cell + gapsX * gap
        let gridH = CGFloat(segmentCount) * cell + gapsY * gap
        return VisualizerLayout(
            origin: CGPoint(x: (size.width - gridW) / 2, y: (size.height - gridH) / 2),
            cell: cell,
            gap: gap,
            bandCount: bandCount,
            segmentCount: segmentCount
        )
    }

    /// Segment 0 is the base of the bar (bottom of the canvas).
    func rect(band: Int, segment: Int) -> CGRect {
        let x = origin.x + CGFloat(band) * (cell + gap)
        let y = origin.y + CGFloat(segmentCount - 1 - segment) * (cell + gap)
        return CGRect(x: x, y: y, width: cell, height: cell)
    }

    /// Half-height tip sitting on the lower half of the peak cell (same band color).
    func tipHalfRect(band: Int, segment: Int) -> CGRect {
        let full = rect(band: band, segment: segment)
        let height = full.height * 0.5
        return CGRect(x: full.minX, y: full.maxY - height, width: full.width, height: height)
    }

    static func litCount(peak: Float, segments: Int = VisualizerGrid.segmentCount) -> Int {
        let clamped: Float
        if peak.isNaN {
            clamped = 0
        } else if peak.isInfinite {
            clamped = peak > 0 ? 1 : 0
        } else {
            clamped = min(1, max(0, peak))
        }
        return min(segments, max(0, Int(clamped * Float(segments))))
    }
}

/// Segmented bars drawn in one Canvas. Host must tick peaks once per display frame; this view only copies and paints.
struct VisualizerView: View {
    let peaks: [Float]
    /// Held tip heights for 90s Sony; `nil` for styles without a separate tip track.
    var tipPeaks: [Float]? = nil
    var style: VisualizerStyle = .retroRed

    var body: some View {
        Canvas(opaque: true) { context, size in
            VisualizerPainter.paint(
                peaks: peaks,
                tipPeaks: tipPeaks,
                style: style,
                context: context,
                size: size
            )
        }
    }
}

/// Lit cells only. Unlit stays the opaque canvas (black, or smoked for 90s Sony).
enum VisualizerPainter {
    static func paint(
        peaks: [Float],
        tipPeaks: [Float]? = nil,
        style: VisualizerStyle,
        context: GraphicsContext,
        size: CGSize
    ) {
        let backdrop: Color
        switch style {
        case .sony90s:
            backdrop = VisualizerPalette.sony90sSmoked.color()
        default:
            backdrop = .black
        }
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(backdrop))
        let layout = VisualizerLayout.fitting(in: size)
        guard layout.cell > 0 else { return }
        switch style {
        case .retroRed, .whiteMatrix:
            paintUniform(peaks: peaks, style: style, layout: layout, context: context)
        case .rainbowSpectrum:
            paintByBand(peaks: peaks, style: style, layout: layout, context: context)
        case .fireGradient, .cyberNeon:
            paintBySegment(peaks: peaks, style: style, layout: layout, context: context)
        case .sony90s:
            paintSony90s(
                bodyPeaks: peaks,
                tipPeaks: tipPeaks ?? peaks,
                layout: layout,
                context: context
            )
        }
    }

    /// Fast body (legacy gravity) + held half-square tip; muted icy LED phosphor.
    private static func paintSony90s(
        bodyPeaks: [Float],
        tipPeaks: [Float],
        layout: VisualizerLayout,
        context: GraphicsContext
    ) {
        let color = VisualizerPalette.color(style: .sony90s, band: 0, segment: 0, lit: true)
        let glowPad = max(1.0, layout.cell * 0.12)
        var bodyGlow = Path()
        var bodyLit = Path()
        var tipGlow = Path()
        var tipLit = Path()

        for band in 0..<layout.bandCount {
            let bodyCount = VisualizerLayout.litCount(
                peak: peak(bodyPeaks, band),
                segments: layout.segmentCount
            )
            let tipCount = VisualizerLayout.litCount(
                peak: peak(tipPeaks, band),
                segments: layout.segmentCount
            )
            let bodyEnd: Int
            if tipCount > 0, tipCount == bodyCount {
                bodyEnd = max(0, bodyCount - 1)
            } else {
                bodyEnd = bodyCount
            }
            for segment in 0..<bodyEnd {
                let rect = layout.rect(band: band, segment: segment)
                bodyGlow.addRect(rect.insetBy(dx: -glowPad, dy: -glowPad))
                bodyLit.addRect(rect)
            }
            guard tipCount > 0 else { continue }
            let tip = layout.tipHalfRect(band: band, segment: tipCount - 1)
            tipGlow.addRect(tip.insetBy(dx: -glowPad * 0.5, dy: -glowPad * 0.5))
            tipLit.addRect(tip)
        }

        if !bodyGlow.isEmpty {
            context.fill(bodyGlow, with: .color(color.opacity(0.22)))
        }
        if !bodyLit.isEmpty {
            context.fill(bodyLit, with: .color(color))
        }
        if !tipGlow.isEmpty {
            context.fill(tipGlow, with: .color(color.opacity(0.22)))
        }
        if !tipLit.isEmpty {
            context.fill(tipLit, with: .color(color))
        }
    }

    private static func paintUniform(
        peaks: [Float],
        style: VisualizerStyle,
        layout: VisualizerLayout,
        context: GraphicsContext
    ) {
        var litPath = Path()
        for band in 0..<layout.bandCount {
            let lit = VisualizerLayout.litCount(peak: peak(peaks, band), segments: layout.segmentCount)
            for segment in 0..<lit {
                litPath.addRect(layout.rect(band: band, segment: segment))
            }
        }
        context.fill(litPath, with: .color(VisualizerPalette.color(style: style, band: 0, segment: 0, lit: true)))
    }

    private static func paintByBand(
        peaks: [Float],
        style: VisualizerStyle,
        layout: VisualizerLayout,
        context: GraphicsContext
    ) {
        for band in 0..<layout.bandCount {
            let lit = VisualizerLayout.litCount(peak: peak(peaks, band), segments: layout.segmentCount)
            guard lit > 0 else { continue }
            var litPath = Path()
            for segment in 0..<lit {
                litPath.addRect(layout.rect(band: band, segment: segment))
            }
            context.fill(
                litPath,
                with: .color(VisualizerPalette.color(style: style, band: band, segment: 0, lit: true))
            )
        }
    }

    private static func paintBySegment(
        peaks: [Float],
        style: VisualizerStyle,
        layout: VisualizerLayout,
        context: GraphicsContext
    ) {
        for segment in 0..<layout.segmentCount {
            var litPath = Path()
            for band in 0..<layout.bandCount {
                let lit = VisualizerLayout.litCount(peak: peak(peaks, band), segments: layout.segmentCount)
                if segment < lit {
                    litPath.addRect(layout.rect(band: band, segment: segment))
                }
            }
            context.fill(
                litPath,
                with: .color(VisualizerPalette.color(style: style, band: 0, segment: segment, lit: true))
            )
        }
    }

    private static func peak(_ peaks: [Float], _ band: Int) -> Float {
        band < peaks.count ? peaks[band] : 0
    }
}
