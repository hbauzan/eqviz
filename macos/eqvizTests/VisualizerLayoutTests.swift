import CoreGraphics
import XCTest

final class VisualizerLayoutTests: XCTestCase {
    func testLitCountFloorsPeakTimesSixteen() {
        XCTAssertEqual(VisualizerLayout.litCount(peak: 0), 0)
        XCTAssertEqual(VisualizerLayout.litCount(peak: 1), VisualizerGrid.segmentCount)
        XCTAssertEqual(VisualizerLayout.litCount(peak: 0.5), 8)
        XCTAssertEqual(VisualizerLayout.litCount(peak: 1.0 / 16.0), 1)
        XCTAssertEqual(VisualizerLayout.litCount(peak: (1.0 / 16.0) - 0.0001), 0)
        XCTAssertEqual(VisualizerLayout.litCount(peak: 2), VisualizerGrid.segmentCount)
        XCTAssertEqual(VisualizerLayout.litCount(peak: -0.3), 0)
        XCTAssertEqual(VisualizerLayout.litCount(peak: .nan), 0)
        XCTAssertEqual(VisualizerLayout.litCount(peak: .infinity), VisualizerGrid.segmentCount)
    }

    func testCellsAreSquareAndLetterboxedInWideWindow() {
        let size = CGSize(width: 800, height: 240)
        let layout = VisualizerLayout.fitting(in: size)

        XCTAssertEqual(layout.bandCount, 32)
        XCTAssertEqual(layout.segmentCount, 16)
        XCTAssertGreaterThan(layout.cell, 0)
        XCTAssertEqual(layout.rect(band: 0, segment: 0).width, layout.cell, accuracy: 1e-6)
        XCTAssertEqual(layout.rect(band: 0, segment: 0).height, layout.cell, accuracy: 1e-6)

        let grid = layout.gridSize
        XCTAssertEqual(grid.height, size.height, accuracy: 1e-4)
        XCTAssertLessThan(grid.width, size.width)
        XCTAssertEqual(layout.origin.y, 0, accuracy: 1e-4)
        XCTAssertGreaterThan(layout.origin.x, 0)
    }

    func testSegmentZeroSitsAtTheBottom() {
        let layout = VisualizerLayout.fitting(in: CGSize(width: 800, height: 240))
        let base = layout.rect(band: 0, segment: 0)
        let top = layout.rect(band: 0, segment: VisualizerGrid.segmentCount - 1)
        XCTAssertGreaterThan(base.minY, top.minY)
        XCTAssertEqual(base.maxY, layout.origin.y + layout.gridSize.height, accuracy: 1e-4)
        XCTAssertEqual(top.minY, layout.origin.y, accuracy: 1e-4)
    }

    func testRectsStayInsideTheCanvas() {
        let size = CGSize(width: 400, height: 120)
        let layout = VisualizerLayout.fitting(in: size)
        let bounds = CGRect(origin: .zero, size: size)
        for band in 0..<layout.bandCount {
            for segment in 0..<layout.segmentCount {
                let rect = layout.rect(band: band, segment: segment)
                XCTAssertTrue(bounds.insetBy(dx: -1e-4, dy: -1e-4).contains(rect), "band \(band) segment \(segment)")
            }
        }
    }
}
