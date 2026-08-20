import XCTest

final class DisplayClockTests: XCTestCase {
    func testDisplayClockIsSixtyHertz() {
        XCTAssertEqual(DisplayClock.framesPerSecond, 60)
        XCTAssertEqual(DisplayClock.frameDuration, 1.0 / 60.0, accuracy: 1e-12)
    }
}
