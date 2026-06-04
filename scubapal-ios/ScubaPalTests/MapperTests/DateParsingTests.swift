import XCTest
@testable import Scuba_Pal

final class DateParsingTests: XCTestCase {
    func testParsesOffsetTimestamp() throws {
        let date = try DateParsing.fromAPI("2026-06-04T12:00:00Z", field: "createdAt")
        XCTAssertEqual(date.timeIntervalSince1970, 1_780_574_400)
    }

    func testParsesServerLocalTimestampAsUTC() throws {
        let date = try DateParsing.fromAPI("2026-06-04T12:00:00", field: "createdAt")
        XCTAssertEqual(date.timeIntervalSince1970, 1_780_574_400)
    }

    func testParsesFractionalServerLocalTimestampAsUTC() throws {
        let date = try DateParsing.fromAPI("2026-06-04T12:00:00.123456", field: "createdAt")
        XCTAssertEqual(date.timeIntervalSince1970, 1_780_574_400.123456, accuracy: 0.000_001)
    }
}
