import XCTest
@testable import Scuba_Pal

final class APIClientRefreshTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.setHandler(nil)
        super.tearDown()
    }

    func testUnauthorizedRequestRefreshesAndRetriesOnce() async throws {
        let baseURL = URL(string: "https://api.scubapal.test")!
        let tokenStore = InMemoryTokenStore(
            TokenPair(accessToken: "expired-access", refreshToken: "refresh-token")
        )
        let apiClient = APIClient(
            config: AppConfig(baseURL: baseURL),
            tokenStore: tokenStore,
            session: makeMockSession()
        )
        await apiClient.setTokenPair(try tokenStore.load())

        let protectedRequestCount = LockedCounter()
        MockURLProtocol.setHandler { request in
            switch request.url?.path {
            case "/api/auth/refresh":
                let data = Data(#"{"accessToken":"new-access","refreshToken":"new-refresh"}"#.utf8)
                return (makeHTTPResponse(url: request.url!, statusCode: 200), data)
            case "/api/me":
                let count = protectedRequestCount.increment()
                if count == 1 {
                    return (makeHTTPResponse(url: request.url!, statusCode: 401), Data())
                }
                XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer new-access")
                let data = Data(#"{"id":7,"username":"reefdiver"}"#.utf8)
                return (makeHTTPResponse(url: request.url!, statusCode: 200), data)
            default:
                throw URLError(.unsupportedURL)
            }
        }

        let response: CurrentUserDTO = try await apiClient.request(Endpoint(path: "/api/me"))

        XCTAssertEqual(response.id, 7)
        XCTAssertEqual(protectedRequestCount.current(), 2)
        XCTAssertEqual(
            try tokenStore.load(),
            TokenPair(accessToken: "new-access", refreshToken: "new-refresh")
        )
    }
}
