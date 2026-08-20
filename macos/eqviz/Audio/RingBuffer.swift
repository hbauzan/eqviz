import Foundation

/// Mutex-backed Float32 ring. Capture thread writes; processing queue reads.
final class RingBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [Float]
    private let capacity: Int
    private var writeIndex = 0
    private var readIndex = 0
    private var filled = 0

    init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        self.storage = [Float](repeating: 0, count: capacity)
    }

    func write(_ samples: UnsafeBufferPointer<Float>) {
        lock.lock()
        defer { lock.unlock() }
        guard let src = samples.baseAddress, !samples.isEmpty else { return }
        for i in 0..<samples.count {
            storage[writeIndex] = src[i]
            writeIndex += 1
            if writeIndex == capacity { writeIndex = 0 }
            if filled < capacity {
                filled += 1
            } else {
                readIndex += 1
                if readIndex == capacity { readIndex = 0 }
            }
        }
    }

    /// Consuming read, oldest-first. Advances the read pointer (hop without overlap).
    func read(_ count: Int) -> [Float]? {
        lock.lock()
        defer { lock.unlock() }
        guard count > 0, filled >= count else { return nil }
        var out = [Float](repeating: 0, count: count)
        for i in 0..<count {
            out[i] = storage[readIndex]
            readIndex += 1
            if readIndex == capacity { readIndex = 0 }
        }
        filled -= count
        return out
    }

    /// Most recent `count` samples, oldest-first. Nil if not enough data yet. Peek; does not consume.
    func readLatest(_ count: Int) -> [Float]? {
        lock.lock()
        defer { lock.unlock() }
        guard count > 0, filled >= count else { return nil }
        var out = [Float](repeating: 0, count: count)
        var idx = writeIndex - count
        if idx < 0 { idx += capacity }
        for i in 0..<count {
            out[i] = storage[idx]
            idx += 1
            if idx == capacity { idx = 0 }
        }
        return out
    }
}
