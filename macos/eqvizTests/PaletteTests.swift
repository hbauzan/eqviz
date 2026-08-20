import XCTest

final class PaletteTests: XCTestCase {
    func testFiveLockedStyles() {
        XCTAssertEqual(VisualizerStyle.allCases.count, 5)
        XCTAssertEqual(VisualizerStyle.allCases.map(\.title), [
            "Retro Red",
            "White Matrix",
            "Rainbow Spectrum",
            "Fire Gradient",
            "Cyber Neon",
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
}
