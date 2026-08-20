import AVFoundation
import Foundation
import Observation

/// UI-facing audio facade. Publishes only low-frequency state; PCM stays off the SwiftUI graph.
@Observable
final class AudioEngine {
    private(set) var isRunning = false
    private(set) var lastError: String?
    private(set) var permissionDenied = false
#if DEBUG
    private(set) var hasSignal = false
#endif

    @ObservationIgnored private let capturer: InputNodeCapture
    @ObservationIgnored private let ring: RingBuffer
    @ObservationIgnored private let processQueue = DispatchQueue(label: "eqviz.audio", qos: .userInitiated)
    @ObservationIgnored private var pendingSignal = false
    @ObservationIgnored private var lastSignalPublish: CFAbsoluteTime = 0

    init() {
        let ring = RingBuffer(capacity: 8192)
        let capturer = InputNodeCapture()
        self.ring = ring
        self.capturer = capturer
        capturer.onSamples = { [weak self] samples, _ in
            self?.handleSamples(samples)
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
#if DEBUG
        hasSignal = false
#endif
    }

    private func handleSamples(_ samples: UnsafeBufferPointer<Float>) {
        ring.write(samples)
        var peak: Float = 0
        for sample in samples {
            let magnitude = abs(sample)
            if magnitude > peak { peak = magnitude }
        }
        let loud = peak > 0.001
        processQueue.async { [weak self] in
            self?.noteSignal(loud)
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
        DispatchQueue.main.async { [weak self] in
            self?.hasSignal = flag
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
