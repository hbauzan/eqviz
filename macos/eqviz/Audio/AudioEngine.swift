import AVFoundation
import Foundation
import Observation

/// Lock-protected 32-band snapshot. SwiftUI must copy(), not observe the array.
final class SpectrumSnapshot: @unchecked Sendable {
    private let lock = NSLock()
    private var bands = [Float](repeating: 0, count: 32)

    func write(_ src: [Float]) {
        lock.lock()
        bands = src
        lock.unlock()
    }

    func copy() -> [Float] {
        lock.lock()
        defer { lock.unlock() }
        return bands
    }
}

/// UI-facing audio facade. Publishes only low-frequency state; PCM stays off the SwiftUI graph.
@Observable
final class AudioEngine {
    private(set) var isRunning = false
    private(set) var lastError: String?
    private(set) var permissionDenied = false
#if DEBUG
    private(set) var hasSignal = false
    private(set) var debugBandMax: Float = 0
#endif

    @ObservationIgnored let spectrum = SpectrumSnapshot()
    @ObservationIgnored let peaks = SpectrumSnapshot()
    @ObservationIgnored private let capturer: InputNodeCapture
    @ObservationIgnored private let ring: RingBuffer
    @ObservationIgnored private let processQueue = DispatchQueue(label: "eqviz.audio", qos: .userInitiated)
    @ObservationIgnored private let fft = FFTProcessor()
    @ObservationIgnored private let normalizer = Normalizer()
    @ObservationIgnored private let peakDecay = PeakDecay()
    @ObservationIgnored private var mapper: BandMapper?
    @ObservationIgnored private var pendingSignal = false
    @ObservationIgnored private var lastSignalPublish: CFAbsoluteTime = 0
    @ObservationIgnored private var lastPeakTick: Date?

    init() {
        let ring = RingBuffer(capacity: 8192)
        let capturer = InputNodeCapture()
        self.ring = ring
        self.capturer = capturer
        capturer.onSamples = { [weak self] samples, sampleRate in
            self?.handleSamples(samples, sampleRate: sampleRate)
        }
        capturer.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.lastError = error.localizedDescription
                self?.isRunning = false
            }
        }
    }

    @MainActor
    func start() async {
        lastError = nil
        let granted = await Self.requestMicrophone()
        if !granted {
            permissionDenied = true
            lastError = "Microphone permission denied"
            isRunning = false
            return
        }
        permissionDenied = false
        do {
            try capturer.start()
            isRunning = true
        } catch {
            lastError = error.localizedDescription
            isRunning = false
        }
    }

    @MainActor
    func stop() {
        capturer.stop()
        isRunning = false
        lastPeakTick = nil
#if DEBUG
        hasSignal = false
        debugBandMax = 0
#endif
    }

    /// Display-clock tick. Gravity uses real `dt`; do not call from the audio queue.
    @MainActor
    func tickPeaks(at date: Date) {
        let dt: CFTimeInterval
        if let last = lastPeakTick {
            dt = max(0, date.timeIntervalSince(last))
        } else {
            dt = DisplayClock.frameDuration
        }
        lastPeakTick = date
        peaks.write(peakDecay.tick(bands: spectrum.copy(), dt: dt))
    }

    private func handleSamples(_ samples: UnsafeBufferPointer<Float>, sampleRate: Double) {
        ring.write(samples)
        var peak: Float = 0
        for sample in samples {
            let magnitude = abs(sample)
            if magnitude > peak { peak = magnitude }
        }
        let loud = peak > 0.001
        processQueue.async { [weak self] in
            self?.analyze(sampleRate: sampleRate, loud: loud)
        }
    }

    private func analyze(sampleRate: Double, loud: Bool) {
        noteSignal(loud)
        while let frame = ring.read(FFTProcessor.size) {
            guard let magnitudes = fft.process(frame) else { continue }
            let mapper: BandMapper
            if let current = self.mapper, current.sampleRate == sampleRate {
                mapper = current
            } else {
                mapper = BandMapper(sampleRate: sampleRate)
                self.mapper = mapper
            }
            spectrum.write(normalizer.process(mapper.map(magnitudes)))
        }
    }

    private func noteSignal(_ loud: Bool) {
        if loud { pendingSignal = true }
        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastSignalPublish >= 0.25 else { return }
        lastSignalPublish = now
        let flag = pendingSignal
        pendingSignal = false
#if DEBUG
        let maxBand = spectrum.copy().max() ?? 0
        DispatchQueue.main.async { [weak self] in
            self?.hasSignal = flag
            self?.debugBandMax = maxBand
        }
#endif
    }

    private static func requestMicrophone() async -> Bool {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            break
        @unknown default:
            break
        }
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
