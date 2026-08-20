import Foundation

protocol AudioCapturing: AnyObject {
    var sampleRate: Double { get }
    func start() throws
    func stop()
    /// Called on capture thread. Implementation MUST copy; caller does not retain the buffer.
    var onSamples: ((UnsafeBufferPointer<Float>, Double) -> Void)? { get set }
}
