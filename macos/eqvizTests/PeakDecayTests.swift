import XCTest

final class PeakDecayTests: XCTestCase {
    func testPeakFallsAndSilentBandsDoNotRise() {
        let decay = PeakDecay()
        var hot = [Float](repeating: 0, count: PeakDecay.bandCount)
        hot[0] = 1
        let zeros = [Float](repeating: 0, count: PeakDecay.bandCount)
        let dt = 1.0 / 120.0

        var peaks = decay.tick(bands: hot, dt: 0)
        XCTAssertEqual(peaks[0], 1, accuracy: 1e-6)
        XCTAssertEqual(peaks[1], 0, accuracy: 1e-6)

        let start = peaks[0]
        for _ in 0..<12 {
            peaks = decay.tick(bands: zeros, dt: dt)
        }
        XCTAssertLessThan(peaks[0], start)
        XCTAssertGreaterThan(peaks[0], 0)
        XCTAssertEqual(peaks[1], 0, accuracy: 1e-6)
        for value in peaks {
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 1)
            XCTAssertFalse(value.isNaN)
            XCTAssertFalse(value.isInfinite)
        }
    }

    func testDecayMatchesAcross60And120Hz() {
        let zeros = [Float](repeating: 0, count: PeakDecay.bandCount)
        var hot = [Float](repeating: 0, count: PeakDecay.bandCount)
        hot[0] = 1

        func fall(ticks: Int, dt: CFTimeInterval) -> Float {
            let decay = PeakDecay()
            _ = decay.tick(bands: hot, dt: 0)
            var peaks = [Float]()
            for _ in 0..<ticks {
                peaks = decay.tick(bands: zeros, dt: dt)
            }
            return peaks[0]
        }

        let at60 = fall(ticks: 60, dt: 1.0 / 60.0)
        let at120 = fall(ticks: 120, dt: 1.0 / 120.0)
        XCTAssertEqual(at60, at120, accuracy: 0.02)

        let mid60 = fall(ticks: 20, dt: 1.0 / 60.0)
        let mid120 = fall(ticks: 40, dt: 1.0 / 120.0)
        XCTAssertEqual(mid60, mid120, accuracy: 0.02)
        XCTAssertEqual(mid60, 1.0 - PeakDecay.gravity / 3.0, accuracy: 0.02)
    }

    func testAttackIsInstant() {
        let decay = PeakDecay()
        var bands = [Float](repeating: 0, count: PeakDecay.bandCount)
        bands[0] = 0.2
        var peaks = decay.tick(bands: bands, dt: 1.0 / 120.0)
        XCTAssertEqual(peaks[0], 0.2, accuracy: 1e-6)
        bands[0] = 0.9
        peaks = decay.tick(bands: bands, dt: 1.0 / 120.0)
        XCTAssertEqual(peaks[0], 0.9, accuracy: 1e-6)
    }
}
