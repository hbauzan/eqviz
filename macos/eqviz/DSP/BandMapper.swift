import Foundation

struct BandMapper {
    static let bandCount = 32
    static let fMin: Double = 20
    static let fMax: Double = 20_000

    let sampleRate: Double
    let fftSize: Int
    let binCount: Int
    /// 33 log edges, 20 Hz … min(20 kHz, Nyquist).
    let edges: [Double]

    init(
        sampleRate: Double,
        fftSize: Int = FFTProcessor.size,
        binCount: Int = FFTProcessor.binCount
    ) {
        self.sampleRate = sampleRate
        self.fftSize = fftSize
        self.binCount = binCount
        let nyquist = sampleRate / 2
        let fMax = min(Self.fMax, nyquist)
        let ratio = fMax / Self.fMin
        var edges: [Double] = []
        edges.reserveCapacity(Self.bandCount + 1)
        for i in 0...Self.bandCount {
            edges.append(Self.fMin * pow(ratio, Double(i) / Double(Self.bandCount)))
        }
        self.edges = edges
    }

    /// Mean linear magnitude per log band. Always 32 values; never NaN/Inf.
    func map(_ magnitudes: [Float]) -> [Float] {
        var bands = [Float](repeating: 0, count: Self.bandCount)
        let n = min(magnitudes.count, binCount)
        guard n > 0, sampleRate > 0 else { return bands }

        for i in 0..<Self.bandCount {
            let lo = edges[i]
            let hi = edges[i + 1]
            let start = clampBin(Int((lo * Double(fftSize) / sampleRate).rounded(.up)))
            let end = clampBin(Int((hi * Double(fftSize) / sampleRate).rounded(.up)))
            let hiBin = min(end, n)
            let loBin = min(start, n)

            if loBin >= hiBin {
                // No FFT bin centre falls in this log band (common at the bottom
                // when bin width > band width). Nearest bin; do not leave 0/NaN.
                let center = sqrt(lo * hi)
                let nearest = min(n - 1, max(0, Int((center * Double(fftSize) / sampleRate).rounded())))
                bands[i] = sanitize(magnitudes[nearest])
            } else {
                var sum: Float = 0
                for bin in loBin..<hiBin {
                    sum += sanitize(magnitudes[bin])
                }
                bands[i] = sum / Float(hiBin - loBin)
            }
        }
        return bands
    }

    func bandIndex(containing frequency: Double) -> Int {
        for i in 0..<Self.bandCount {
            if frequency >= edges[i] && frequency < edges[i + 1] {
                return i
            }
        }
        if frequency >= edges[Self.bandCount] {
            return Self.bandCount - 1
        }
        return 0
    }

    private func clampBin(_ value: Int) -> Int {
        min(binCount, max(0, value))
    }

    private func sanitize(_ value: Float) -> Float {
        if value.isNaN || value.isInfinite { return 0 }
        return max(0, value)
    }
}
