import XCTest
@testable import Scuba_Pal

final class UserMapperTests: XCTestCase {
    func testMapResolvesRelativeProfileImageURLForDisplay() throws {
        let mapper = UserMapper(
            mediaURLResolver: MediaURLResolver(baseURL: URL(string: "https://api.scubapal.test")!)
        )
        let dto = PublicUserDTO(
            id: 7,
            username: "reefwatcher",
            firstName: "Reef",
            lastName: "Watcher",
            city: "Kailua",
            country: "US",
            diveCount: 42,
            bio: "Warm water fan",
            profileImageUrl: "/media/profiles/reef.jpg"
        )

        let user = try mapper.map(dto)

        XCTAssertEqual(user.profileImageUrl, "/media/profiles/reef.jpg")
        XCTAssertEqual(user.profileImageURL?.absoluteString, "https://api.scubapal.test/media/profiles/reef.jpg")
    }
}
