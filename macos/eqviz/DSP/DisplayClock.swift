import Foundation

/// Display-clock rate. Gravity uses real `dt`; this is only the tick cadence.
enum DisplayClock {
    static let framesPerSecond: Double = 60
    static let frameDuration: CFTimeInterval = 1.0 / 60.0
}
