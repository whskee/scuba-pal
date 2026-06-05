import XCTest
@testable import Scuba_Pal

final class AppConfigTests: XCTestCase {
    func testConfigStoresBaseURLAndEnvironmentName() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://api.scubapal.test"))

        let config = AppConfig(baseURL: baseURL, environmentName: "staging")

        XCTAssertEqual(config.baseURL, baseURL)
        XCTAssertEqual(config.environmentName, "staging")
    }

    func testBlankEnvironmentNameFallsBackToDevelopment() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://api.scubapal.test"))

        let config = AppConfig(baseURL: baseURL, environmentName: "   ")

        XCTAssertEqual(config.environmentName, "development")
    }
}
