import Foundation

struct ProfileRepository: Sendable {
    let apiClient: APIClient
    let mapper: UserMapper

    func profiles(query: String) async throws -> [User] {
        let endpoint = Endpoint(
            path: "/api/profiles",
            query: ["q": query, "page": "0", "size": "50"]
        )
        let response: PageResponseDTO<PublicProfileDTO> = try await apiClient.request(endpoint)
        return try (response.content ?? []).map { try mapper.map($0) }
    }

    func profile(userID: Int) async throws -> User {
        async let profileResponse: PublicProfileDTO = apiClient.request(
            Endpoint(path: "/api/users/\(userID)/profile")
        )
        async let summaryResponse: FollowSummaryDTO? = try? apiClient.request(
            Endpoint(path: "/api/users/\(userID)/follow-summary")
        )
        return try mapper.map(try await profileResponse, follow: await summaryResponse)
    }

    func currentProfile() async throws -> User {
        let response: ProfileDTO = try await apiClient.request(Endpoint(path: "/api/me/profile"))
        let initial = try mapper.map(response)
        let summary: FollowSummaryDTO? = try? await apiClient.request(
            Endpoint(path: "/api/users/\(initial.id)/follow-summary")
        )
        return try mapper.map(response, follow: summary)
    }

    func updateCurrentProfile(_ update: ProfileUpdate) async throws -> User {
        let endpoint = Endpoint(path: "/api/me/profile", method: .put)
        let response: ProfileDTO = try await apiClient.request(
            endpoint,
            body: UpdateProfileRequest(
                firstName: update.firstName,
                lastName: update.lastName,
                phoneNumber: update.phoneNumber,
                city: update.city,
                state: update.state,
                country: update.country,
                bio: update.bio,
                diveCount: update.diveCount,
                profileImageUrl: update.profileImageUrl
            )
        )
        return try mapper.map(response)
    }

    func follow(userID: Int, shouldFollow: Bool) async throws -> FollowSummary {
        let endpoint = Endpoint(
            path: "/api/users/\(userID)/follow",
            method: shouldFollow ? .post : .delete
        )
        let response: FollowSummaryDTO = try await apiClient.request(endpoint)
        return mapper.mapFollowSummary(response)
    }
}
