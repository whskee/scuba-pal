import XCTest
@testable import Scuba_Pal

final class APIEnumTests: XCTestCase {
    func testVisibilityStatusCodableUsesBackendRawValues() throws {
        let data = try JSONEncoder().encode(
            CreatePostRequest(
                caption: "Blue water",
                visibilityStatus: .publicStatus,
                mediaUrls: []
            )
        )

        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(json.contains(#""visibilityStatus":"PUBLIC""#))

        let decoded = try JSONDecoder().decode(FeedPostDTO.self, from: Data(#"{"visibilityStatus":"PRIVATE"}"#.utf8))
        XCTAssertEqual(decoded.visibilityStatus, .privateStatus)
    }

    func testUserRoleCodableUsesBackendRawValues() throws {
        let decoded = try JSONDecoder().decode(CurrentUserDTO.self, from: Data(#"{"role":"SHOP_OWNER"}"#.utf8))

        XCTAssertEqual(decoded.role, .shopOwner)
        XCTAssertEqual(UserRole.moderator.rawValue, "MODERATOR")
    }

    func testMappersPreserveTypedBackendEnums() throws {
        let user = try UserMapper().map(
            CurrentUserDTO(
                id: 7,
                username: "reefwatcher",
                role: .admin
            )
        )
        XCTAssertEqual(user.role, .admin)

        let profile = try UserMapper().map(
            ProfileDTO(
                profileId: 10,
                userId: 7,
                username: "reefwatcher",
                visibilityStatus: .privateStatus
            )
        )
        XCTAssertEqual(profile.visibilityStatus, .privateStatus)

        let post = try PostMapper(
            mediaURLResolver: MediaURLResolver(baseURL: URL(string: "https://api.scubapal.test")!)
        ).map(
            FeedPostDTO(
                postId: 1,
                userId: 7,
                username: "reefwatcher",
                visibilityStatus: .publicStatus,
                createdAt: "2026-06-04T12:00:00Z"
            )
        )
        XCTAssertEqual(post.visibilityStatus, .publicStatus)
    }
}
