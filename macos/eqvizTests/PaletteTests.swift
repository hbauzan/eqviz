import XCTest

final class PaletteTests: XCTestCase {
    func testSixLockedStyles() {
        XCTAssertEqual(VisualizerStyle.allCases.count, 6)
        XCTAssertEqual(VisualizerStyle.allCases.map(\.title), [
            "Retro Red",
            "White Matrix",
            "Rainbow Spectrum",
            "Fire Gradient",
            "Cyber Neon",
            "90s Sony",
        ])
    }

    func testWhiteMatrixIsWhiteOnBlack() {
        let lit = VisualizerPalette.rgb(style: .whiteMatrix, band: 0, segment: 0, lit: true)
        let unlit = VisualizerPalette.rgb(style: .whiteMatrix, band: 0, segment: 0, lit: false)
        XCTAssertEqual(lit.r, 1, accuracy: 1e-6)
        XCTAssertEqual(lit.g, 1, accuracy: 1e-6)
        XCTAssertEqual(lit.b, 1, accuracy: 1e-6)
        XCTAssertEqual(unlit.r, 0, accuracy: 1e-6)
        XCTAssertEqual(unlit.g, 0, accuracy: 1e-6)
        XCTAssertEqual(unlit.b, 0, accuracy: 1e-6)
    }

    func testFireRisesGreenToRed() {
        let base = VisualizerPalette.rgb(style: .fireGradient, band: 0, segment: 0, lit: true)
        let top = VisualizerPalette.rgb(style: .fireGradient, band: 0, segment: 15, lit: true)
        XCTAssertGreaterThan(base.g, base.r)
        XCTAssertGreaterThan(top.r, top.g)
    }

    func testLitDiffersFromUnlitForEveryStyle() {
        for style in VisualizerStyle.allCases {
            for band in [0, 15, 31] {
                for segment in [0, 8, 15] {
                    let lit = VisualizerPalette.rgb(style: style, band: band, segment: segment, lit: true)
                    let unlit = VisualizerPalette.rgb(style: style, band: band, segment: segment, lit: false)
                    let same = abs(lit.r - unlit.r) < 1e-6
                        && abs(lit.g - unlit.g) < 1e-6
                        && abs(lit.b - unlit.b) < 1e-6
                    XCTAssertFalse(same, "\(style) band \(band) segment \(segment)")
                }
            }
        }
    }

    func testRainbowHueFollowsBandNotSegment() {
        let low = VisualizerPalette.rgb(style: .rainbowSpectrum, band: 0, segment: 0, lit: true)
        let lowTop = VisualizerPalette.rgb(style: .rainbowSpectrum, band: 0, segment: 15, lit: true)
        XCTAssertEqual(low.r, lowTop.r, accuracy: 1e-6)
        XCTAssertEqual(low.g, lowTop.g, accuracy: 1e-6)
        XCTAssertEqual(low.b, lowTop.b, accuracy: 1e-6)
        XCTAssertGreaterThan(low.r, low.g)
        XCTAssertGreaterThan(low.r, low.b)
    }

    func testUniformStylesIgnoreBandAndSegment() {
        for style in [VisualizerStyle.retroRed, .whiteMatrix] {
            let origin = VisualizerPalette.rgb(style: style, band: 0, segment: 0, lit: true)
            let far = VisualizerPalette.rgb(style: style, band: 31, segment: 15, lit: true)
            XCTAssertEqual(origin.r, far.r, accuracy: 1e-6)
            XCTAssertEqual(origin.g, far.g, accuracy: 1e-6)
            XCTAssertEqual(origin.b, far.b, accuracy: 1e-6)
        }
    }

    func testFireAndCyberAreConstantAcrossBands() {
        for style in [VisualizerStyle.fireGradient, .cyberNeon] {
            let a = VisualizerPalette.rgb(style: style, band: 0, segment: 8, lit: true)
            let b = VisualizerPalette.rgb(style: style, band: 31, segment: 8, lit: true)
            XCTAssertEqual(a.r, b.r, accuracy: 1e-6)
            XCTAssertEqual(a.g, b.g, accuracy: 1e-6)
            XCTAssertEqual(a.b, b.b, accuracy: 1e-6)
        }
    }

    func testSony90sTurquoiseBodyAndOverloadTop() {
        let body = VisualizerPalette.rgb(style: .sony90s, band: 0, segment: 0, lit: true)
        let mid = VisualizerPalette.rgb(style: .sony90s, band: 0, segment: 13, lit: true)
        let overload = VisualizerPalette.rgb(style: .sony90s, band: 0, segment: 14, lit: true)
        let top = VisualizerPalette.rgb(style: .sony90s, band: 31, segment: 15, lit: true)

        XCTAssertGreaterThan(body.g, body.r)
        XCTAssertGreaterThan(body.b, body.r)
        XCTAssertEqual(body.r, mid.r, accuracy: 1e-6)
        XCTAssertEqual(body.g, mid.g, accuracy: 1e-6)
        XCTAssertEqual(body.b, mid.b, accuracy: 1e-6)

        XCTAssertGreaterThan(overload.r, overload.g)
        XCTAssertEqual(overload.r, top.r, accuracy: 1e-6)
        XCTAssertEqual(overload.g, top.g, accuracy: 1e-6)
        XCTAssertEqual(overload.b, top.b, accuracy: 1e-6)
    }

    func testSony90sPeakProfile() {
        XCTAssertEqual(VisualizerStyle.sony90s.peakHoldDuration, PeakDecay.sony90sHold, accuracy: 1e-9)
        XCTAssertEqual(VisualizerStyle.sony90s.peakGravity, PeakDecay.sony90sGravity, accuracy: 1e-6)
        XCTAssertEqual(VisualizerStyle.retroRed.peakHoldDuration, 0, accuracy: 1e-9)
        XCTAssertEqual(VisualizerStyle.retroRed.peakGravity, PeakDecay.gravity, accuracy: 1e-6)
    }
}
