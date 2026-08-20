import XCTest

final class DSPTests: XCTestCase {
    func testSine440HzPeaksInItsLogBand() {
        let sampleRate = 44_100.0
        let frequency = 440.0
        let samples = sine(frequency: frequency, sampleRate: sampleRate, amplitude: 0.5, count: FFTProcessor.size)
        let fft = FFTProcessor()
        let mapper = BandMapper(sampleRate: sampleRate)
        let normalizer = Normalizer()

        guard let magnitudes = fft.process(samples) else {
            XCTFail("FFTProcessor returned nil for a 2048-sample frame")
            return
        }
        let bands = normalizer.process(mapper.map(magnitudes))

        XCTAssertEqual(bands.count, 32)
        let expected = mapper.bandIndex(containing: frequency)
        let peakIndex = bands.indices.max(by: { bands[$0] < bands[$1] })!
        XCTAssertEqual(peakIndex, expected)

        let peak = bands[peakIndex]
        XCTAssertGreaterThan(peak, 0.5)
        for (index, value) in bands.enumerated() {
            XCTAssertFalse(value.isNaN)
            XCTAssertFalse(value.isInfinite)
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 1)
            if abs(index - peakIndex) >= 8 {
                XCTAssertLessThan(value, 0.2 * peak, "band \(index) should be far below 440 Hz")
            }
        }
    }

    func testSilenceMapsToZeroBands() {
        let zeros = [Float](repeating: 0, count: FFTProcessor.size)
        let fft = FFTProcessor()
        let mapper = BandMapper(sampleRate: 48_000)
        let normalizer = Normalizer()

        guard let magnitudes = fft.process(zeros) else {
            XCTFail("FFTProcessor returned nil for a 2048-sample frame")
            return
        }
        let bands = normalizer.process(mapper.map(magnitudes))
        XCTAssertEqual(bands.count, 32)
        for value in bands {
            XCTAssertEqual(value, 0, accuracy: 1e-6)
            XCTAssertFalse(value.isNaN)
            XCTAssertFalse(value.isInfinite)
        }
    }

    func testBandMapperLogEdges() {
        let mapper = BandMapper(sampleRate: 44_100)
        XCTAssertEqual(mapper.edges.count, 33)
        XCTAssertGreaterThanOrEqual(mapper.edges.first!, 20 - 0.01)
        XCTAssertLessThanOrEqual(mapper.edges.last!, 44_100 / 2)
        for i in 1..<mapper.edges.count {
            XCTAssertGreaterThan(mapper.edges[i], mapper.edges[i - 1])
        }
        let bands = mapper.map([Float](repeating: 0, count: FFTProcessor.binCount))
        XCTAssertEqual(bands.count, 32)
    }

    func testFFTRejectsShortFrames() {
        let fft = FFTProcessor()
        XCTAssertNil(fft.process([Float](repeating: 0, count: 1024)))
    }

    private func sine(frequency: Double, sampleRate: Double, amplitude: Float, count: Int) -> [Float] {
        let omega = 2 * Double.pi * frequency / sampleRate
        return (0..<count).map { i in
            amplitude * Float(sin(omega * Double(i)))
        }
    }
}
