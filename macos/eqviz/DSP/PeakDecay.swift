import Foundation

/// Instant attack, linear gravity in amplitude units per second (display clock `dt`, not audio hop).
final class PeakDecay {
    static let bandCount = 32
    static let gravity: Float = 1.2

    let bandCount: Int
    let gravity: Float
    private var peaks: [Float]

    init(bandCount: Int = PeakDecay.bandCount, gravity: Float = PeakDecay.gravity) {
        self.bandCount = bandCount
        self.gravity = gravity
        self.peaks = [Float](repeating: 0, count: bandCount)
    }

    func tick(bands: [Float], dt: CFTimeInterval) -> [Float] {
        let step = gravity * Float(max(0, dt))
        let incoming = bands.count
        for i in 0..<bandCount {
            let instant = i < incoming ? sanitize(bands[i]) : 0
            if instant >= peaks[i] {
                peaks[i] = instant
            } else {
                peaks[i] = max(0, peaks[i] - step)
            }
        }
        return Array(peaks)
    }

    private func sanitize(_ value: Float) -> Float {
        if value.isNaN || value.isInfinite { return 0 }
        return min(1, max(0, value))
    }
}
