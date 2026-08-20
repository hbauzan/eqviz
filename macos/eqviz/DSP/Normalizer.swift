import Foundation

/// Instant attack to a new spectrum peak; release 0.99 per audio hop (not display).
final class Normalizer {
    private var peak: Float = 0
    private let release: Float = 0.99

    func process(_ bands: [Float]) -> [Float] {
        var maxBand: Float = 0
        for band in bands {
            let value = sanitize(band)
            if value > maxBand { maxBand = value }
        }
        peak = max(peak * release, maxBand)
        if peak <= 0 {
            return [Float](repeating: 0, count: bands.count)
        }
        return bands.map { band in
            let scaled = sanitize(band) / peak
            if scaled.isNaN || scaled.isInfinite { return 0 }
            return min(1, max(0, scaled))
        }
    }

    private func sanitize(_ value: Float) -> Float {
        if value.isNaN || value.isInfinite { return 0 }
        return max(0, value)
    }
}
