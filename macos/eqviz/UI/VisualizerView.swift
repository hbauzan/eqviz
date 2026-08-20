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

/// Placeholder palette (08). Five named styles land in 09.
private enum VisualizerPlaceholder {
    static let lit = Color(.sRGB, red: 1, green: 0.15, blue: 0.1, opacity: 1)
    static let unlit = Color(.sRGB, red: 0.12, green: 0.02, blue: 0.02, opacity: 1)
}

/// Segmented bars drawn in one Canvas. Host must tick peaks once per display frame; this view only copies and paints.
struct VisualizerView: View {
    let peaks: [Float]

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
            let layout = VisualizerLayout.fitting(in: size)
            guard layout.cell > 0 else { return }
            let local = peaks
            for band in 0..<layout.bandCount {
                let peak: Float = band < local.count ? local[band] : 0
                let lit = VisualizerLayout.litCount(peak: peak, segments: layout.segmentCount)
                for segment in 0..<layout.segmentCount {
                    let color = segment < lit ? VisualizerPlaceholder.lit : VisualizerPlaceholder.unlit
                    context.fill(
                        Path(roundedRect: layout.rect(band: band, segment: segment), cornerRadius: 0),
                        with: .color(color)
                    )
                }
            }
        }
    }
}
