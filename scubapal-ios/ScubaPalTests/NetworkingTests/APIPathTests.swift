import XCTest
@testable import Scuba_Pal

final class APIPathTests: XCTestCase {
    func testStaticPathsMatchBackendRoutes() {
        XCTAssertEqual(APIPath.currentUser, "/api/me")
        XCTAssertEqual(APIPath.currentUserProfile, "/api/me/profile")
        XCTAssertEqual(APIPath.login, "/api/auth/login")
        XCTAssertEqual(APIPath.refreshToken, "/api/auth/refresh")
        XCTAssertEqual(APIPath.posts, "/api/posts")
        XCTAssertEqual(APIPath.profiles, "/api/profiles")
    }

    func testDynamicPathsMatchBackendRoutes() {
        XCTAssertEqual(APIPath.post(id: 42), "/api/posts/42")
        XCTAssertEqual(APIPath.postLike(postID: 42), "/api/posts/42/like")
        XCTAssertEqual(APIPath.postComments(postID: 42), "/api/posts/42/comments")
        XCTAssertEqual(APIPath.userProfile(userID: 7), "/api/users/7/profile")
        XCTAssertEqual(APIPath.userFollowSummary(userID: 7), "/api/users/7/follow-summary")
        XCTAssertEqual(APIPath.messages(conversationID: 11), "/api/messages/11")
    }

    func testPageRequestBuildsPageAndSizeQueryParameters() {
        XCTAssertEqual(
            PageRequest(page: 2, size: 30).queryParameters,
            ["page": "2", "size": "30"]
        )
    }

    func testPageRequestCanAddFeatureQueryParameters() {
        XCTAssertEqual(
            PageRequest(size: 50).queryParameters(adding: ["q": "reef"]),
            ["page": "0", "size": "50", "q": "reef"]
        )
    }
}
