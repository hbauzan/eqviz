import Accelerate
import Foundation

/// Real FFT (vDSP) → linear magnitude spectrum. Not dB: dB compresses the EQ look in v1.
final class FFTProcessor {
    static let size = 2048
    static let log2n: vDSP_Length = 11
    static let binCount = 1024

    private let setup: FFTSetup
    private let window: [Float]
    private var windowed: [Float]
    private var realp: [Float]
    private var imagp: [Float]
    private var magnitudes: [Float]

    init() {
        guard let setup = vDSP_create_fftsetup(Self.log2n, FFTRadix(kFFTRadix2)) else {
            preconditionFailure("vDSP_create_fftsetup failed")
        }
        self.setup = setup
        var window = [Float](repeating: 0, count: Self.size)
        vDSP_hann_window(&window, vDSP_Length(Self.size), Int32(vDSP_HANN_NORM))
        self.window = window
        self.windowed = [Float](repeating: 0, count: Self.size)
        self.realp = [Float](repeating: 0, count: Self.binCount)
        self.imagp = [Float](repeating: 0, count: Self.binCount)
        self.magnitudes = [Float](repeating: 0, count: Self.binCount)
    }

    deinit {
        vDSP_destroy_fftsetup(setup)
    }

    /// Linear magnitudes, length 1024 (DC … bin 1023). Nil unless `samples.count == 2048`.
    func process(_ samples: [Float]) -> [Float]? {
        guard samples.count == Self.size else { return nil }

        window.withUnsafeBufferPointer { win in
            samples.withUnsafeBufferPointer { src in
                windowed.withUnsafeMutableBufferPointer { dst in
                    vDSP_vmul(
                        src.baseAddress!, 1,
                        win.baseAddress!, 1,
                        dst.baseAddress!, 1,
                        vDSP_Length(Self.size)
                    )
                }
            }
        }

        realp.withUnsafeMutableBufferPointer { realBuf in
            imagp.withUnsafeMutableBufferPointer { imagBuf in
                var split = DSPSplitComplex(
                    realp: realBuf.baseAddress!,
                    imagp: imagBuf.baseAddress!
                )
                windowed.withUnsafeBytes { raw in
                    let complexSrc = raw.bindMemory(to: DSPComplex.self).baseAddress!
                    vDSP_ctoz(complexSrc, 2, &split, 1, vDSP_Length(Self.binCount))
                }
                vDSP_fft_zrip(setup, &split, 1, Self.log2n, FFTDirection(kFFTDirection_Forward))
                // Packed real FFT stores Nyquist in imagp[0]; zero it so bin 0 is DC only.
                split.imagp[0] = 0
                magnitudes.withUnsafeMutableBufferPointer { magBuf in
                    vDSP_zvmags(&split, 1, magBuf.baseAddress!, 1, vDSP_Length(Self.binCount))
                    var n = Int32(Self.binCount)
                    vvsqrtf(magBuf.baseAddress!, magBuf.baseAddress!, &n)
                }
            }
        }

        return Array(magnitudes)
    }
}
