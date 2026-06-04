import XCTest
@testable import Scuba_Pal

final class PostMapperTests: XCTestCase {
    private let mapper = PostMapper(
        mediaURLResolver: MediaURLResolver(baseURL: URL(string: "https://api.scubapal.test")!)
    )

    func testMapRejectsMissingPostID() {
        let dto = FeedPostDTO(
            postId: nil,
            userId: 42,
            username: "oceanfriend",
            caption: "Blue water",
            createdAt: "2026-06-04T12:00:00Z"
        )

        XCTAssertThrowsError(try mapper.map(dto)) { error in
            XCTAssertEqual(error as? MappingError, .missingRequiredField("postId"))
        }
    }

    func testMapRejectsInvalidDateInsteadOfUsingNow() {
        let dto = FeedPostDTO(
            postId: 1,
            userId: 42,
            username: "oceanfriend",
            caption: "Blue water",
            createdAt: "not-a-date"
        )

        XCTAssertThrowsError(try mapper.map(dto)) { error in
            XCTAssertEqual(
                error as? MappingError,
                .invalidValue(field: "post.createdAt", value: "not-a-date")
            )
        }
    }

    func testMapResolvesRelativeMediaURL() throws {
        let dto = FeedPostDTO(
            postId: 1,
            userId: 42,
            username: "oceanfriend",
            caption: "Blue water",
            imageUrl: "/media/reef.jpg",
            createdAt: "2026-06-04T12:00:00Z"
        )

        let post = try mapper.map(dto)

        XCTAssertEqual(post.imageUrl?.absoluteString, "https://api.scubapal.test/media/reef.jpg")
        XCTAssertEqual(post.mediaUrls, [URL(string: "https://api.scubapal.test/media/reef.jpg")!])
    }
}
