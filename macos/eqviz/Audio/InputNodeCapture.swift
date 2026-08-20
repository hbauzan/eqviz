import AVFoundation
import Foundation

enum CaptureError: LocalizedError {
    case invalidInputFormat
    case converterUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidInputFormat:
            return "Default input is not ready (sample rate or channel count is 0)."
        case .converterUnavailable:
            return "Could not convert input audio to Float32."
        }
    }
}

/// v1 adapter: macOS default input via `AVAudioEngine.inputNode`. No device picker.
final class InputNodeCapture: AudioCapturing {
    var onSamples: ((UnsafeBufferPointer<Float>, Double) -> Void)?
    var onError: ((Error) -> Void)?

    var sampleRate: Double {
        engine.inputNode.inputFormat(forBus: 0).sampleRate
    }

    private let engine = AVAudioEngine()
    private var tapInstalled = false
    private var wantsRunning = false
    private var observer: NSObjectProtocol?
    private var converter: AVAudioConverter?
    private var convertBuffer: AVAudioPCMBuffer?
    private var scratch = [Float]()

    func start() throws {
        wantsRunning = true
        try installTapAndStart()
        observeConfigurationChangesIfNeeded()
    }

    func stop() {
        wantsRunning = false
        removeTapIfNeeded()
        if engine.isRunning {
            engine.stop()
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        stop()
    }

    private func observeConfigurationChangesIfNeeded() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: engine,
            queue: .main
        ) { [weak self] _ in
            self?.handleConfigurationChange()
        }
    }

    private func handleConfigurationChange() {
        guard wantsRunning else { return }
        removeTapIfNeeded()
        do {
            try installTapAndStart()
        } catch {
            onError?(error)
        }
    }

    private func installTapAndStart() throws {
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw CaptureError.invalidInputFormat
        }

        try prepareConverter(from: format)
        removeTapIfNeeded()
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.emitMono(from: buffer)
        }
        tapInstalled = true
        engine.prepare()
        if !engine.isRunning {
            try engine.start()
        }
    }

    private func removeTapIfNeeded() {
        guard tapInstalled else { return }
        engine.inputNode.removeTap(onBus: 0)
        tapInstalled = false
    }

    private func prepareConverter(from format: AVAudioFormat) throws {
        if format.commonFormat == .pcmFormatFloat32 {
            converter = nil
            convertBuffer = nil
            return
        }
        guard
            let dst = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: format.sampleRate,
                channels: format.channelCount,
                interleaved: false
            ),
            let converter = AVAudioConverter(from: format, to: dst)
        else {
            throw CaptureError.converterUnavailable
        }
        self.converter = converter
        convertBuffer = AVAudioPCMBuffer(pcmFormat: dst, frameCapacity: 4096)
    }

    private func emitMono(from buffer: AVAudioPCMBuffer) {
        let floatBuffer: AVAudioPCMBuffer
        if buffer.format.commonFormat == .pcmFormatFloat32 {
            floatBuffer = buffer
        } else {
            guard let converter, let convertBuffer else { return }
            convertBuffer.frameLength = 0
            var error: NSError?
            var provided = false
            let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                if provided {
                    outStatus.pointee = .noDataNow
                    return nil
                }
                provided = true
                outStatus.pointee = .haveData
                return buffer
            }
            converter.convert(to: convertBuffer, error: &error, withInputFrom: inputBlock)
            if error != nil { return }
            floatBuffer = convertBuffer
        }

        let frames = Int(floatBuffer.frameLength)
        guard frames > 0, let channels = floatBuffer.floatChannelData else { return }
        let channelCount = Int(floatBuffer.format.channelCount)
        if scratch.count < frames {
            scratch = [Float](repeating: 0, count: frames)
        }
        if channelCount <= 1 {
            scratch.withUnsafeMutableBufferPointer { dst in
                guard let base = dst.baseAddress else { return }
                base.update(from: channels[0], count: frames)
            }
        } else {
            let inv = 1.0 / Float(channelCount)
            for i in 0..<frames {
                var sum: Float = 0
                for c in 0..<channelCount {
                    sum += channels[c][i]
                }
                scratch[i] = sum * inv
            }
        }
        let rate = floatBuffer.format.sampleRate
        scratch.withUnsafeBufferPointer { ptr in
            onSamples?(UnsafeBufferPointer(start: ptr.baseAddress, count: frames), rate)
        }
    }
}
