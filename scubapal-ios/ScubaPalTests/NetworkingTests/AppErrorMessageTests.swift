import XCTest
@testable import Scuba_Pal

final class AppErrorMessageTests: XCTestCase {
    func testServerErrorUsesCleanUserFacingMessage() {
        let error = APIError.server(
            message: "SQL failed password=secret-token Bearer abc.def.ghi",
            status: 500
        )

        XCTAssertEqual(error.userFacingMessage, "ScubaPal is having trouble right now. Please try again soon.")
        XCTAssertFalse(error.userFacingMessage.contains("secret-token"))
        XCTAssertFalse(error.userFacingMessage.localizedCaseInsensitiveContains("sql"))
    }

    func testDiagnosticMessageRedactsSensitiveValues() {
        let diagnostic = APIError.server(
            message: "Authorization: Bearer abc.def.ghi accessToken=secret refreshToken=also-secret password=hunter2",
            status: 401
        ).diagnosticMessage

        XCTAssertFalse(diagnostic.contains("abc.def.ghi"))
        XCTAssertFalse(diagnostic.contains("secret"))
        XCTAssertFalse(diagnostic.contains("hunter2"))
        XCTAssertTrue(diagnostic.contains("<redacted>"))
    }

    func testNetworkErrorsUseStableUserMessage() {
        XCTAssertEqual(URLError(.notConnectedToInternet).userFacingMessage, "Check your connection and try again.")
        XCTAssertEqual(URLError(.badServerResponse).userFacingMessage, "The network request could not be completed.")
    }
}
