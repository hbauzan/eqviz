import Foundation

/// Instant attack, optional peak hold, then linear gravity (display clock `dt`, not audio hop).
final class PeakDecay {
    static let bandCount = 32
    static let gravity: Float = 1.2
    /// Sony VFD-style: slower fall after hold.
    static let sony90sGravity: Float = 0.5
    static let sony90sHold: CFTimeInterval = 0.5

    let bandCount: Int
    private(set) var gravity: Float
    private(set) var holdDuration: CFTimeInterval
    private var peaks: [Float]
    private var holdRemaining: [CFTimeInterval]

    init(
        bandCount: Int = PeakDecay.bandCount,
        gravity: Float = PeakDecay.gravity,
        holdDuration: CFTimeInterval = 0
    ) {
        self.bandCount = bandCount
        self.gravity = gravity
        self.holdDuration = holdDuration
        self.peaks = [Float](repeating: 0, count: bandCount)
        self.holdRemaining = [CFTimeInterval](repeating: 0, count: bandCount)
    }

    func configure(gravity: Float, holdDuration: CFTimeInterval) {
        self.gravity = gravity
        self.holdDuration = holdDuration
    }

    func tick(bands: [Float], dt: CFTimeInterval) -> [Float] {
        let step = gravity * Float(max(0, dt))
        let holdStep = max(0, dt)
        let incoming = bands.count
        for i in 0..<bandCount {
            let instant = i < incoming ? sanitize(bands[i]) : 0
            if instant >= peaks[i] {
                peaks[i] = instant
                holdRemaining[i] = holdDuration
            } else if holdDuration > 0, holdRemaining[i] > 0 {
                holdRemaining[i] = max(0, holdRemaining[i] - holdStep)
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
